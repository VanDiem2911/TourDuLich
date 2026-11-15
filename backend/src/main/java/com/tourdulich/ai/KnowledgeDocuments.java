package com.tourdulich.ai;

import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.service.TourMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Stream;

/**
 * Dựng các "đoạn" (Document) mà trợ lý AI sẽ đọc: chỉ biến dữ liệu thành văn bản + metadata, KHÔNG biết gì về vector hay embedding
 * (phần đưa vào VectorStore và tìm kiếm là việc của {@link KnowledgeBase}).
 *
 * <p>Ba nguồn: (1) mỗi tour đang mở bán, (2) các "tài liệu tổng quan" tự sinh từ DB (theo điểm đến, loại hành trình, phạm vi),
 * (3) tài liệu .md/.txt trong {@code classpath:ai/knowledge/} và thư mục {@code app.ai.knowledge-dir}.
 * Mỗi nguồn được cắt thành các đoạn ngắn (chunk) kèm metadata để lọc theo tour.
 */
@Slf4j
@Component
public class KnowledgeDocuments {

    public static final String META_TYPE = "type";
    public static final String META_TOUR_ID = "tourId";
    public static final String META_TITLE = "title";
    public static final String TYPE_TOUR = "tour";
    public static final String TYPE_DOC = "doc";
    /** Tài liệu tổng quan tự sinh từ DB (theo điểm đến, phạm vi, loại hành trình). */
    public static final String TYPE_OVERVIEW = "overview";
    /** Danh sách id tour (cách nhau bằng dấu phẩy) mà một tài liệu tổng quan nhắc tới. */
    public static final String META_TOUR_IDS = "tourIds";

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final AppProperties props;
    private final TokenTextSplitter splitter = TokenTextSplitter.builder()
            .withChunkSize(500)
            .withMinChunkSizeChars(100)
            .withMinChunkLengthToEmbed(10)
            .withMaxNumChunks(5)
            .withKeepSeparator(true)
            .build();

    public KnowledgeDocuments(AppProperties props) {
        this.props = props;
    }

    // ------------------------------------------------------------------ Dựng tài liệu từ tour

    List<Document> tourDocuments(Tour t) {
        String id = String.valueOf(t.getId());
        String prefix = "[Tour: " + t.getName() + "] ";
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put(META_TYPE, TYPE_TOUR);
        meta.put(META_TOUR_ID, id);
        meta.put(META_TITLE, t.getName());

        List<Document> out = new ArrayList<>();
        // 1) Thẻ thông tin tổng quan (đoạn quan trọng nhất để tìm theo điểm đến, giá, thời lượng...)
        out.add(Document.builder().id(docId("tour:" + id + ":head"))
                .text(prefix + headline(t)).metadata(meta).build());
        // 2) Lịch trình chi tiết
        addSplit(out, "tour:" + id + ":itin", prefix + "Lịch trình chi tiết:\n" + nz(t.getItinerary()), meta);
        // 3) Giá bao gồm / không bao gồm / hủy / phụ thu (bỏ phần "giấy tờ" dài và giống nhau giữa các tour)
        addSplit(out, "tour:" + id + ":note", prefix + "Giá, dịch vụ và quy định:\n" + usefulNotes(t.getNotes()), meta);
        return out;
    }

    // ------------------------------------------------------------------ Tài liệu tổng quan về tour

    /**
     * Các tài liệu "danh mục tour" tự sinh từ DB để trả lời câu hỏi tổng quát ("có tour nào đi Nhật?", "tour biển nào hợp
     * gia đình?"): một tài liệu cho mỗi điểm đến, mỗi loại hành trình (danh mục) và mỗi phạm vi (trong nước / nước ngoài).
     * Luôn khớp với dữ liệu hiện có và có sẵn liên kết /tours/id. Giá chỉ để tham khảo, giá hiện tại do ChatService bổ sung.
     */
    List<Document> overviewDocuments(List<Tour> tours) {
        List<Document> out = new ArrayList<>();
        if (tours == null || tours.isEmpty()) {
            return out;
        }
        Map<String, List<Tour>> byDestination = new java.util.TreeMap<>();
        Map<String, List<Tour>> byCategory = new java.util.TreeMap<>();
        for (Tour t : tours) {
            byDestination.computeIfAbsent(nz(t.getDestination()).isBlank() ? "Khác" : t.getDestination().strip(),
                    k -> new ArrayList<>()).add(t);
            byCategory.computeIfAbsent(t.getCategory().getName(), k -> new ArrayList<>()).add(t);
        }
        byDestination.forEach((dest, list) -> addOverviewChunks(out, "overview:dest:" + slug(dest),
                "[Tổng quan tour đến " + dest + "] Các tour đi " + dest + " hiện có (" + list.size() + " tour):", list, true));
        byCategory.forEach((cat, list) -> addOverviewChunks(out, "overview:cat:" + slug(cat),
                "[Tổng quan loại hành trình: " + cat + "] Các tour thuộc loại \"" + cat + "\" (" + list.size() + " tour):", list, false));
        for (TourRegion region : TourRegion.values()) {
            List<Tour> list = tours.stream().filter(t -> t.getRegion() == region).toList();
            if (list.isEmpty()) {
                continue;
            }
            Map<String, Long> counts = new java.util.TreeMap<>();
            list.forEach(t -> counts.merge(nz(t.getDestination()).isBlank() ? "Khác" : t.getDestination().strip(), 1L, Long::sum));
            boolean intl = region == TourRegion.INTERNATIONAL;
            String header = (intl ? "[Tổng quan tour nước ngoài] Website có " : "[Tổng quan tour trong nước] Website có ")
                    + list.size() + (intl ? " tour nước ngoài" : " tour trong nước") + ". Các điểm đến: "
                    + String.join(", ", counts.entrySet().stream().map(e -> e.getKey() + " (" + e.getValue() + " tour)").toList()) + ".";
            addOverviewChunks(out, "overview:region:" + region.name().toLowerCase(), header, list, false);
        }
        return out;
    }

    /**
     * Gom các dòng tour thành các đoạn tối đa khoảng 1500 ký tự mà KHÔNG cắt giữa một dòng (tránh cắt đôi số tiền hay tên tour),
     * mỗi đoạn lặp lại tiêu đề và chỉ gắn id của các tour có trong đoạn đó.
     */
    private void addOverviewChunks(List<Document> out, String idPrefix, String header, List<Tour> list, boolean withRoute) {
        final int max = 1500;
        StringBuilder sb = new StringBuilder(header).append('\n');
        List<Tour> in = new ArrayList<>();
        int part = 0;
        for (Tour t : list) {
            String line = tourLine(t, withRoute);
            if (!in.isEmpty() && sb.length() + line.length() > max) {
                emitOverview(out, idPrefix + ":" + part++, sb.toString(), in);
                sb = new StringBuilder(header).append(" (tiếp)\n");
                in = new ArrayList<>();
            }
            sb.append(line);
            in.add(t);
        }
        if (!in.isEmpty()) {
            emitOverview(out, idPrefix + ":" + part, sb.toString(), in);
        }
    }

    private void emitOverview(List<Document> out, String id, String text, List<Tour> tours) {
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put(META_TYPE, TYPE_OVERVIEW);
        meta.put(META_TITLE, id);
        meta.put(META_TOUR_IDS, String.join(",", tours.stream().map(t -> String.valueOf(t.getId())).toList()));
        out.add(Document.builder().id(docId(id)).text(text.strip()).metadata(meta).build());
    }

    private static String tourLine(Tour t, boolean withRoute) {
        StringBuilder sb = new StringBuilder();
        sb.append("- ").append(t.getName()).append(" (/tours/").append(t.getId()).append("), ")
                .append(nz(t.getDuration())).append(", ").append(nz(t.getTransport()))
                .append(", khởi hành từ ").append(nz(t.getDepartureLocation()))
                .append(", giá người lớn khoảng ").append(vnd(t.effectiveAdultPrice().longValue()));
        if (withRoute) {
            String route = routeOf(t.getItinerary());
            if (!route.isEmpty()) {
                sb.append(". Hành trình: ").append(route);
            }
        }
        return sb.append('\n').toString();
    }

    /** Tóm tắt hành trình từ tiêu đề các ngày ("Ngày 1: Hà Nội - Singapore" -> "Hà Nội - Singapore → ..."). */
    static String routeOf(String itinerary) {
        if (itinerary == null || itinerary.isBlank()) {
            return "";
        }
        List<String> titles = new ArrayList<>();
        for (String line : itinerary.replace("\r", "").split("\n")) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("^Ngày\\s*\\d+\\s*:\\s*(.+)$").matcher(line.strip());
            if (m.matches()) {
                String title = m.group(1).strip();
                // Bỏ tiêu đề "rác" do nguồn dữ liệu (đó là câu mô tả buổi sáng/trưa, không phải tên chặng); rút gọn tiêu đề dài
                if (title.matches("(?i)^(sáng|trưa|chiều|tối)\\s*:.*")) {
                    continue;
                }
                titles.add(title.length() > 70 ? title.substring(0, 70).strip() + "…" : title);
            }
        }
        String joined = String.join(" → ", titles);
        return joined.length() > 320 ? joined.substring(0, 320).strip() + "…" : joined;
    }

    private static String slug(String s) {
        String n = java.text.Normalizer.normalize(s.replace('đ', 'd').replace('Đ', 'D'), java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return n.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
    }

    private void addSplit(List<Document> out, String idPrefix, String text, Map<String, Object> meta) {
        if (text == null || text.isBlank() || text.endsWith(":\n")) {
            return;
        }
        List<Document> parts = splitter.apply(List.of(Document.builder().text(text).metadata(meta).build()));
        for (int i = 0; i < parts.size(); i++) {
            out.add(parts.get(i).mutate().id(docId(idPrefix + ":" + i)).build());
        }
    }

    /**
     * Cột id của bảng vector_store có kiểu UUID, nên mỗi đoạn được đặt id UUID cố định suy ra từ khóa dễ đọc
     * (ví dụ "tour:5:head"): cùng một đoạn luôn ra cùng một id.
     */
    static String docId(String key) {
        return UUID.nameUUIDFromBytes(key.getBytes(StandardCharsets.UTF_8)).toString();
    }

    private static String headline(Tour t) {
        StringBuilder sb = new StringBuilder();
        sb.append(t.getName()).append(" (mã ").append(t.getTourCode()).append("). ");
        sb.append(t.getRegion() == TourRegion.INTERNATIONAL ? "Tour nước ngoài" : "Tour trong nước");
        sb.append(", danh mục ").append(t.getCategory().getName()).append(". ");
        sb.append("Điểm đến: ").append(nz(t.getDestination())).append(". ");
        sb.append("Khởi hành từ: ").append(nz(t.getDepartureLocation())).append(". ");
        sb.append("Thời lượng: ").append(nz(t.getDuration())).append(". ");
        sb.append("Phương tiện: ").append(nz(t.getTransport())).append(". ");
        if (t.getDepartureDate() != null) {
            sb.append("Khởi hành dự kiến: ").append(t.getDepartureDate().format(DATE)).append(". ");
        }
        sb.append("Giá người lớn: ").append(vnd(t.effectiveAdultPrice().longValue()));
        if (t.hasPromo()) {
            sb.append(" (đang khuyến mãi, giá gốc ").append(vnd(t.getAdultPrice().longValue())).append(")");
        }
        sb.append(". Giá trẻ em: ").append(vnd(TourMapper.effectiveChildPrice(t).longValue())).append(". ");
        if (t.getShortDescription() != null) {
            sb.append("Mô tả: ").append(t.getShortDescription());
        }
        sb.append(" Xem chi tiết tại /tours/").append(t.getId());
        return sb.toString();
    }

    /** Giữ các mục "bao gồm", "hủy", "phụ thu"; bỏ "giấy tờ mang theo" và các mục dài khác. */
    static String usefulNotes(String notes) {
        if (notes == null || notes.isBlank()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (String block : notes.replace("\r", "").split("\n\\s*\n")) {
            String first = block.lines().findFirst().orElse("").toLowerCase();
            if (first.contains("bao gồm") || first.contains("hủy") || first.contains("phụ thu")) {
                sb.append(block.strip()).append("\n\n");
            }
        }
        return sb.toString().strip();
    }

    // ------------------------------------------------------------------ Dựng tài liệu từ file tri thức

    List<Document> knowledgeDocuments() {
        List<Document> out = new ArrayList<>();
        Map<String, String> files = new LinkedHashMap<>();
        try {
            PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            for (String pattern : List.of("classpath*:ai/knowledge/*.md", "classpath*:ai/knowledge/*.txt")) {
                for (Resource r : resolver.getResources(pattern)) {
                    if (r.getFilename() != null) {
                        files.put(r.getFilename(), new String(r.getInputStream().readAllBytes(), StandardCharsets.UTF_8));
                    }
                }
            }
        } catch (IOException e) {
            log.warn("Không đọc được tài liệu trong classpath: {}", e.getMessage());
        }
        // Thư mục ngoài (ghi đè file cùng tên trong classpath): thêm/sửa tài liệu mà không cần build lại
        String dir = props.ai() == null ? null : props.ai().knowledgeDir();
        if (dir != null && !dir.isBlank() && Files.isDirectory(Path.of(dir))) {
            try (Stream<Path> list = Files.list(Path.of(dir))) {
                for (Path p : list.filter(x -> x.toString().endsWith(".md") || x.toString().endsWith(".txt")).toList()) {
                    files.put(p.getFileName().toString(), Files.readString(p, StandardCharsets.UTF_8));
                }
            } catch (IOException e) {
                log.warn("Không đọc được thư mục tài liệu {}: {}", dir, e.getMessage());
            }
        }
        files.forEach((name, text) -> out.addAll(documentsOf(name, text)));
        return out;
    }

    /** Cắt một file markdown theo tiêu đề (#, ##) rồi cắt tiếp theo độ dài; mỗi đoạn kèm tên tài liệu + mục. */
    List<Document> documentsOf(String filename, String text) {
        String title = filename;
        List<String[]> sections = new ArrayList<>(); // {heading, body}
        String heading = "";
        StringBuilder body = new StringBuilder();
        for (String line : text.replace("\r", "").split("\n")) {
            if (line.startsWith("# ") && title.equals(filename)) {
                title = line.substring(2).strip();
                continue;
            }
            if (line.startsWith("## ") || line.startsWith("# ")) {
                if (body.toString().isBlank() && sections.isEmpty() && heading.isEmpty()) {
                    // chưa có nội dung trước tiêu đề đầu tiên
                } else {
                    sections.add(new String[]{heading, body.toString()});
                }
                heading = line.replaceFirst("^#+\\s*", "").strip();
                body = new StringBuilder();
                continue;
            }
            body.append(line).append('\n');
        }
        sections.add(new String[]{heading, body.toString()});

        List<Document> out = new ArrayList<>();
        for (int i = 0; i < sections.size(); i++) {
            String h = sections.get(i)[0];
            String b = sections.get(i)[1].strip();
            if (b.isBlank()) {
                continue;
            }
            Map<String, Object> meta = new LinkedHashMap<>();
            meta.put(META_TYPE, TYPE_DOC);
            meta.put(META_TITLE, title);
            String label = "[Tài liệu: " + title + (h.isEmpty() ? "" : " > " + h) + "] ";
            addSplit(out, "kb:" + filename + ":" + i, label + b, meta);
        }
        return out;
    }

    // ------------------------------------------------------------------ Tiện ích

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    static String vnd(long n) {
        return String.format("%,d", n).replace(',', '.') + " đ";
    }
}
