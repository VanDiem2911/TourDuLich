#!/usr/bin/env python3
"""
Lấy dữ liệu tour mẫu từ fiditour.com (WordPress REST API công khai, robots.txt cho phép) và sinh file
database/seed_fiditour.sql theo đúng cấu trúc bảng tours của project.

Chỉ dùng thư viện chuẩn của Python 3.  Chạy:
    python tools/scrape_fiditour.py                  # sinh database/seed_fiditour.sql
    python tools/scrape_fiditour.py --intl-limit 30

Nguồn đã chia sẵn:  category 19 = "Du Lịch Trong Nước",  category 20 = "Du Lịch Nước Ngoài".
Ghi chú: dữ liệu chỉ phục vụ demo/học tập. Nội dung và ảnh thuộc bản quyền Fiditour. Script gọi chậm
(1 request/giây), có User-Agent rõ ràng. Các cột nguồn không có (ngày khởi hành, số chỗ, giá trẻ em)
được sinh giả lập và ghi rõ trong file SQL.
"""
import argparse
import html
import json
import re
import sys
import time
import urllib.request
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path

API = "https://fiditour.com/wp-json/wp/v2/posts"
UA = "TourDuLich-student-project/1.0 (educational)"
CAT_DOMESTIC, CAT_INTL = 19, 20
ROOT = Path(__file__).resolve().parent.parent
STATS = Counter()

BLOCK = {"p", "div", "br", "li", "ul", "ol", "tr", "td", "th", "h1", "h2", "h3", "h4", "h5", "h6", "table", "section"}


class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts, self.skip = [], 0

    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style"):
            self.skip += 1
        if tag in BLOCK:
            self.parts.append("\n")

    def handle_endtag(self, tag):
        if tag in ("script", "style"):
            self.skip = max(0, self.skip - 1)
        if tag in BLOCK:
            self.parts.append("\n")

    def handle_data(self, data):
        if not self.skip:
            self.parts.append(data)


def to_lines(content_html):
    p = TextExtractor()
    p.feed(content_html)
    text = "".join(p.parts).replace("\xa0", " ")
    lines = [re.sub(r"[ \t]+", " ", l).strip() for l in text.split("\n")]
    return [l for l in lines if l]


def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r), r.headers


def list_posts(cat):
    posts, page = [], 1
    while True:
        url = f"{API}?categories={cat}&per_page=50&page={page}&_embed=wp:featuredmedia"
        try:
            data, headers = fetch_json(url)
        except Exception as ex:
            print(f"  dừng ở trang {page}: {ex}", file=sys.stderr)
            break
        posts.extend(data)
        if page >= int(headers.get("X-WP-TotalPages", 1)):
            break
        page += 1
        time.sleep(1)
    return posts


def clean_title(raw):
    t = html.unescape(raw)
    t = re.sub(r"[“”\"]", "", t)
    t = re.sub(r"\s+", " ", t).strip()
    t = re.sub(r"\s*[–—]\s*", " - ", t)
    return t.strip(" -")


STALE_RE = re.compile(r"tết\s*2026|hoa anh đào|ất tỵ|xuân ất|tết nguyên đán", re.I)
LEAD_NOISE = re.compile(r"^(chương trình tour|tour du lịch|hành trình khám phá|tham quan|tour)\s*:?\s*", re.I)
LEAD_DEPART = re.compile(r"^(hà nội\s*/\s*sài gòn|hà nội|hn|tp\.?\s*hcm|tphcm|hcm|sài gòn|nội bài)\s*-\s*", re.I)
LEAD_YEAR = re.compile(r"^20\d\d\s*[:\-]?\s*")


def normalize_departure(raw):
    """Về một trong: Hà Nội / TP.HCM / Đà Nẵng / 'Hà Nội / TP.HCM'. Giá trị lạ ("Thứ 5"...) -> TP.HCM."""
    low = (raw or "").lower()
    hn = "hà nội" in low or "nội bài" in low
    hcm = any(k in low for k in ("hcm", "hồ chí minh", "sài gòn"))
    if hn and hcm:
        return "Hà Nội / TP.HCM"
    if hn:
        return "Hà Nội"
    if "đà nẵng" in low:
        return "Đà Nẵng"
    return "TP.HCM"


def display_title(title, duration, intl):
    """Chuẩn hóa tên tour: bỏ ngoặc/nhiễu, bỏ điểm khởi hành ở đầu, đổi chữ IN HOA sang Title Case, thêm thời lượng."""
    t = re.sub(r"\([^)]*\)", " ", title)
    t = re.sub(r"\d+\s*N\s*\d+\s*Đ", " ", t, flags=re.I)
    t = re.sub(r"\s+", " ", t).strip(" -:")
    for _ in range(2):
        t = LEAD_NOISE.sub("", t)
        t = LEAD_YEAR.sub("", t)
    if intl:
        t = LEAD_DEPART.sub("", t)
    else:
        t = re.sub(r"^nội bài\s*-\s*", "", t, flags=re.I)
    letters = [c for c in t if c.isalpha()]
    if letters and sum(c.isupper() for c in letters) / len(letters) > 0.4:
        t = t.title()
    for bad, good in (("Tp.Hcm", "TP.HCM"), ("Kdl", "KDL"), ("Hn", "HN"), ("Hcm", "HCM"), ("Pattalya", "Pattaya"),
                      ("Ch Séc", "CH Séc")):
        t = t.replace(bad, good)
    t = re.sub(r"\s*:\s*", ": ", t)
    t = re.sub(r"\s*-\s*", " - ", t).strip(" -:")
    return f"{t} {duration}".strip()


def cap_itinerary(itin, limit=19500):
    """Giữ lịch trình dưới giới hạn 20000 ký tự của form admin, cắt ở ranh giới giữa hai ngày."""
    if len(itin) <= limit:
        return itin
    cut = itin[:limit].rsplit("\n\n", 1)[0]
    return cut


def parse_duration(title, lines):
    m = re.search(r"(\d+)\s*N\s*(\d+)\s*Đ", title, re.I)
    if m:
        return f"{m.group(1)}N{m.group(2)}Đ"
    for i, l in enumerate(lines):
        if l.upper() == "THỜI GIAN" and i + 1 < len(lines):
            m = re.search(r"(\d+)\s*NGÀY\s*(\d+)\s*ĐÊM", lines[i + 1].upper())
            if m:
                return f"{m.group(1)}N{m.group(2)}Đ"
    return None


def parse_price(lines):
    text = "\n".join(lines)
    m = re.search(r"giá\s*từ:?\s*([0-9][0-9.,]{4,})", text, re.I)
    if m:
        return int(re.sub(r"\D", "", m.group(1)))
    # Dự phòng: số tiền nhỏ nhất (>= 500.000) trong khối "GIÁ TOUR"
    start = next((i for i, l in enumerate(lines) if l.upper().startswith("GIÁ TOUR")), None)
    if start is not None:
        nums = []
        for l in lines[start:start + 40]:
            if l.upper().startswith("LỊCH TRÌNH"):
                break
            for n in re.findall(r"(\d{1,3}(?:[.,]\d{3})+)\s*(?:VND|VNĐ|đ)", l, re.I):
                v = int(re.sub(r"\D", "", n))
                if v >= 500000:
                    nums.append(v)
        if nums:
            return min(nums)
    return None


def parse_departure(lines):
    for i, l in enumerate(lines):
        if l.upper().startswith("KHỞI HÀNH") and i + 1 < len(lines):
            tail = l.split(":", 1)[1].strip() if ":" in l else ""
            val = tail or lines[i + 1]
            val = val.title().replace("Hồ Chí Minh", "TP.HCM").replace("Tp.Hcm", "TP.HCM")
            return val[:150]
    return None


DAY_RE = re.compile(r"^NGÀY\s*(\d+)\s*[:.\-–]?\s*(.*)$", re.I)
STOP_RE = re.compile(r"^(GIÁ (TOUR )?BAO GỒM|GIÁ KHÔNG BAO GỒM|LƯU Ý|ĐIỀU KIỆN|THÔNG TIN|CHÍNH SÁCH|QUY ĐỊNH|"
                     r"BAO GỒM|KHÔNG BAO GỒM|GHI CHÚ|HỦY TOUR)", re.I)


# Phần sau lịch trình (giá bao gồm, không bao gồm, quy định hủy...) KHÔNG thuộc lịch trình: tách thành `notes`
NOTES_START_RE = re.compile(r"^(GIÁ )?(TOUR )?(KHÔNG )?BAO GỒM\s*$|^GIÁ TOUR (KHÔNG )?BAO GỒM", re.I)
NOTES_END_RE = re.compile(r"^(CÓ THỂ BẠN QUAN TÂM|BÀI VIẾT LIÊN QUAN|TOUR LIÊN QUAN|TOUR KHÁC)", re.I)
NOTE_FRAGMENT_RE = re.compile(r"\s*GIÁ TOUR( KHÔNG)?( BAO)?( GỒM)?\s*$")


def is_heading(l):
    letters = [c for c in l if c.isalpha()]
    return bool(letters) and l == l.upper() and len(l) <= 60 and not re.match(r"^[\d\-–+•(]", l)


def note_heading(l):
    low = l.lower()
    if "không bao gồm" in low:
        return "Giá tour không bao gồm"
    if "bao gồm" in low:
        return "Giá tour bao gồm"
    return l.capitalize()


def parse_notes(lines):
    start0 = next((i for i, l in enumerate(lines) if l.upper().startswith("LỊCH TRÌNH")), 0)
    start = next((i for i in range(start0, len(lines)) if NOTES_START_RE.match(lines[i])), None)
    if start is None:
        return ""
    blocks, cur = [], None
    for l in lines[start:]:
        if NOTES_END_RE.match(l):
            break
        l = NOTE_FRAGMENT_RE.sub("", l).strip()
        if not l:
            continue
        if is_heading(l):
            cur = {"title": note_heading(l), "body": []}
            blocks.append(cur)
        elif cur is not None:
            # Nguồn hay viết liền "1. A …. 2. B": tách mỗi mục đánh số ("2. Vé…") xuống dòng riêng.
            # Điều kiện "số + dấu chấm + chữ cái" nên không cắt nhầm số tiền như 160.000.
            if re.match(r"^\d{1,2}\.", l):
                l = re.sub(r"\s+(?=\d{1,2}\.\s*[A-Za-zÀ-ỹĐđ])", "\n", l)
            cur["body"].extend(l.split("\n"))
    out, size = [], 0
    for b in blocks:
        if not b["body"]:
            continue
        text = b["title"] + "\n" + "\n".join(b["body"])
        if size + len(text) > 15000:
            break
        out.append(text)
        size += len(text) + 2
    return "\n\n".join(out)


def clean_day_title(t):
    # Một số bài bị cách rời từng chữ ("P h ú Q u ố c"): ranh giới từ đã mất ở nguồn nên bỏ tiêu đề đó
    toks = t.split(" ")
    if len(toks) >= 6 and sum(1 for k in toks if len(k) <= 1) / len(toks) > 0.6:
        return ""
    t = re.sub(r"\s*\((?:bao gồm|gồm|ăn)[^)]*\)\s*$", "", t, flags=re.I)
    return t.strip(" :-–")


def parse_itinerary(lines, max_days=None):
    """
    Tách lịch trình theo ngày. Một số bài không có dòng "LỊCH TRÌNH" và có thêm bảng tóm tắt ("Ngày 1 … Ngày 5" của
    lịch bay) hoặc lặp tiêu đề ngày, nên: mỗi số ngày chỉ giữ MỘT mục có nội dung dài nhất, bỏ các ngày vượt quá
    max_days (số ngày của tour, ví dụ 5 với "5N4Đ"), rồi sắp theo số ngày.
    """
    start = next((i for i, l in enumerate(lines) if l.upper().startswith("LỊCH TRÌNH")), -1)
    days, cur, want_title = [], None, False
    for l in lines[start + 1:]:
        m = DAY_RE.match(l)
        if m:
            if cur:
                days.append(cur)
            cur = {"num": int(m.group(1)), "title": clean_day_title(m.group(2)), "body": []}
            want_title = not m.group(2).strip()
            continue
        if cur is None:
            continue
        # Dừng ở mục "giá bao gồm"; các tiêu đề khác (LƯU Ý, QUY ĐỊNH...) chỉ tính khi viết HOA toàn bộ, vì câu mô tả
        # trong ngày cũng có thể bắt đầu bằng "Bao gồm…", "Lưu ý…".
        if NOTES_START_RE.match(l) or (STOP_RE.match(l) and l == l.upper() and (days or cur["body"])):
            break
        if want_title:
            cur["title"] = clean_day_title(l)
            want_title = False
            continue
        cur["body"].append(l)
    if cur:
        days.append(cur)

    def weight(d):
        return len("\n".join(d["body"])) + len(d["title"])

    best = {}
    for d in days:
        if d["num"] not in best or weight(d) > weight(best[d["num"]]):
            best[d["num"]] = d
    days = [best[n] for n in sorted(best)]
    if max_days:
        within = [d for d in days if 1 <= d["num"] <= max_days]
        days = within or days
    if days:
        # Chú thích ảnh còn sót cuối ngày cuối ("Chợ Đà Lạt", "Chùa Linh Ứng"): dòng ngắn không có dấu câu kết thúc
        body = days[-1]["body"]
        while body and len(body[-1]) <= 30 and not re.search(r"[.!?…:)]$", body[-1]):
            body.pop()
    out = []
    for d in days:
        n = d["num"]
        body = "\n".join(d["body"]).strip()
        title = d["title"] or f"Hành trình ngày {n}"
        out.append(f"Ngày {n}: {title}" + (f"\n{body}" if body else ""))
    return "\n\n".join(out)


def guess_transport(lines, intl, itin=""):
    """Tour nước ngoài: máy bay. Tour trong nước: chỉ nhìn vào LỊCH TRÌNH (không nhìn mục "giá chưa gồm vé máy bay")."""
    if intl:
        return "Máy bay"
    text = (itin or " ".join(lines)).lower()
    if "sân bay" in text or "chuyến bay" in text or "máy bay" in text:
        return "Máy bay"
    if "du thuyền" in text:
        return "Xe du lịch + Du thuyền"
    if "tàu cao tốc" in text or "cano" in text:
        return "Xe du lịch + Tàu cao tốc"
    return "Xe du lịch"


def short_desc(itin, title):
    first = itin.split("\n\n")[0].split("\n")[1:] if itin else []
    s = " ".join(first).strip()
    s = re.sub(r"^(Sáng|Trưa|Chiều|Tối)\s*:\s*", "", s)
    if len(s) < 40:
        return title
    return (s[:240].rsplit(" ", 1)[0] + "…") if len(s) > 240 else s


def categorize_domestic(title):
    t = title.lower()
    if any(k in t for k in ("phú quốc", "quy nhơn", "phan thiết", "mũi né", "nha trang", "côn đảo", "cát bà")):
        return "Nghỉ dưỡng biển đảo"
    if any(k in t for k in ("hà giang", "fansipan", "sapa", "sa pa", "mộc châu", "sơn la", "điện biên", "cao bằng")):
        return "Khám phá & Trekking"
    if any(k in t for k in ("huế", "la vang", "phong nha")):
        return "Văn hóa - Lịch sử"
    return "Tour trong nước"


# (từ khóa trong tiêu đề, tên điểm đến hiển thị)
COUNTRIES = [
    ("nhật bản", "Nhật Bản"), ("osaka", "Nhật Bản"), ("tokyo", "Nhật Bản"), ("kyoto", "Nhật Bản"),
    ("hokkaido", "Nhật Bản"), ("hàn quốc", "Hàn Quốc"), ("seoul", "Hàn Quốc"), ("busan", "Hàn Quốc"),
    ("jeju", "Hàn Quốc"), ("thái lan", "Thái Lan"), ("bangkok", "Thái Lan"), ("pattaya", "Thái Lan"),
    ("phuket", "Thái Lan"), ("trung quốc", "Trung Quốc"), ("bắc kinh", "Trung Quốc"), ("thượng hải", "Trung Quốc"),
    ("trương gia giới", "Trung Quốc"), ("côn minh", "Trung Quốc"), ("singapore", "Singapore"),
    ("malaysia", "Malaysia"), ("indonesia", "Indonesia"), ("bali", "Indonesia"), ("đài loan", "Đài Loan"),
    ("đài bắc", "Đài Loan"), ("dubai", "Dubai"), ("abu dhabi", "Dubai"), ("lào", "Lào"),
    ("campuchia", "Campuchia"), ("hồng kông", "Hồng Kông"), ("hongkong", "Hồng Kông"), ("maldives", "Maldives"),
    ("thổ nhĩ kỳ", "Thổ Nhĩ Kỳ"), ("ai cập", "Ai Cập"), ("ấn độ", "Ấn Độ"), ("nepal", "Nepal"),
    ("châu âu", "Châu Âu"), ("pháp", "Châu Âu"), ("thụy sĩ", "Châu Âu"), ("ý ", "Châu Âu"), ("đức", "Châu Âu"),
    ("hà lan", "Châu Âu"), ("tây ban nha", "Châu Âu"), ("úc", "Úc"), ("mỹ", "Mỹ"), ("canada", "Canada"),
    ("new zealand", "New Zealand"), ("nga", "Nga"),
    ("trùng khánh", "Trung Quốc"), ("thành đô", "Trung Quốc"), ("thẩm quyến", "Trung Quốc"),
    ("khai phong", "Trung Quốc"), ("cáp nhĩ tân", "Trung Quốc"), ("quảng châu", "Trung Quốc"),
    ("hoa kỳ", "Hoa Kỳ"), ("sydney", "Úc"), ("melbourne", "Úc"), ("istanbul", "Thổ Nhĩ Kỳ"),
]


# Điểm đến trong nước: lấy địa danh xuất hiện SỚM NHẤT trong tên tour (khớp tên điểm đến ở seed.sql)
DOMESTIC_PLACES = [
    ("đà lạt", "Đà Lạt"), ("phú quốc", "Phú Quốc"), ("quy nhơn", "Quy Nhơn"), ("mũi né", "Mũi Né"),
    ("phan thiết", "Mũi Né"), ("nha trang", "Nha Trang"), ("đà nẵng", "Đà Nẵng"), ("bà nà", "Đà Nẵng"),
    ("hội an", "Đà Nẵng"), ("huế", "Huế"), ("la vang", "Huế"), ("phong nha", "Quảng Bình"),
    ("hà giang", "Hà Giang"), ("sapa", "Sa Pa"), ("sa pa", "Sa Pa"), ("sơn la", "Sơn La"),
    ("điện biên", "Sơn La"), ("mộc châu", "Mộc Châu"), ("tràng an", "Ninh Bình"), ("ninh bình", "Ninh Bình"),
    ("hạ long", "Hạ Long"), ("cát bà", "Cát Bà"), ("côn đảo", "Côn Đảo"), ("tiền giang", "Tiền Giang"),
    ("cần thơ", "Cần Thơ"), ("châu đốc", "Châu Đốc"), ("cà mau", "Cà Mau")
]


def destination_of(title, intl):
    low = title.lower() + " "
    if not intl:
        hits = [(low.find(k), v) for k, v in DOMESTIC_PLACES if k in low]
        if hits:
            return min(hits)[1]
    if intl:
        if "địa trung hải" in low:
            return "Địa Trung Hải"
        for key, val in COUNTRIES:
            if re.search(r"(?<!\w)" + re.escape(key.strip()) + r"(?!\w)", low):
                return val
    t = re.sub(r"\(?\s*\d+\s*N\s*\d+\s*Đ\s*\)?", "", title).strip(" -")
    parts = [p.strip() for p in t.split(" - ") if p.strip()]
    skip = ("tour", "du xuân", "nội bài", "hà nội", "tp.hcm", "hcm", "hn", "xứ sở")
    for p in parts:
        if not p.lower().startswith(skip) and len(p) <= 40:
            return p.title()
    return (parts[0] if parts else title)[:40].title()


IMG_TAG_RE = re.compile(r"<img\b[^>]*>", re.I)
IMG_URL_RE = re.compile(r"""(?:data-src|src)=["'](https://fiditour\.com/wp-content/uploads/[^"']+\.(?:jpe?g|png|webp))["']""", re.I)
SIZE_SUFFIX_RE = re.compile(r"-\d{2,4}x\d{2,4}(?=\.\w+$)")
COMMON_IMAGES = set()  # ảnh xuất hiện ở nhiều bài (banner/logo dùng chung) -> không đưa vào thư viện của tour


def post_images(post):
    """Ảnh trong nội dung bài, bỏ hậu tố kích thước (-1024x759) để lấy bản gốc, giữ thứ tự và không trùng."""
    seen, out = set(), []
    for tag in IMG_TAG_RE.findall(post["content"]["rendered"]):
        m = IMG_URL_RE.search(tag)
        if not m:
            continue
        url = SIZE_SUFFIX_RE.sub("", m.group(1))
        if url not in seen and url.isascii():  # bỏ URL có ký tự lạ (tên file tiếng Trung...) vì dễ lỗi khi hotlink
            seen.add(url)
            out.append(url)
    return out


def build_tour(post, intl):
    title = clean_title(post["title"]["rendered"])
    if STALE_RE.search(title):
        STATS["chiến dịch theo mùa đã qua"] += 1
        return None
    lines = to_lines(post["content"]["rendered"])
    price = parse_price(lines)
    duration = parse_duration(title, lines)
    itin = parse_itinerary(lines, int(duration.split("N")[0]) if duration else None)
    if not (price and itin and duration):
        STATS[f"thiếu {'giá ' if not price else ''}{'lịch trình ' if not itin else ''}{'thời lượng' if not duration else ''}".strip()] += 1
        return None
    media = (post.get("_embedded", {}).get("wp:featuredmedia") or [{}])[0]
    image = media.get("source_url")
    if not image:
        STATS["thiếu ảnh"] += 1
        return None
    itin = cap_itinerary(itin)
    notes = parse_notes(lines)
    cover = SIZE_SUFFIX_RE.sub("", image)
    gallery = [u for u in post_images(post) if u not in COMMON_IMAGES and u != cover][:6]
    shown = display_title(title, duration, intl)
    return {
        "title": shown[:255],
        "dest": destination_of(title, intl)[:150],
        "dep": normalize_departure(parse_departure(lines)),
        "duration": duration,
        "price": price,
        "transport": guess_transport(lines, intl, itin),
        "image": image[:500],
        "itin": itin,
        "notes": notes,
        "gallery": "\n".join(gallery),
        "desc": short_desc(itin, shown)[:500],
        "category": "Tour quốc tế" if intl else categorize_domestic(title),
        "region": "INTERNATIONAL" if intl else "DOMESTIC",
        "source": post.get("link", ""),
        "pid": post["id"],
        "intl": intl,
    }


def sql(s):
    if s is None:
        return "NULL"
    return "'" + s.replace("\\", "\\\\").replace("'", "''") + "'"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--intl-limit", type=int, default=30, help="số tour nước ngoài tối đa (nguồn có ~170)")
    ap.add_argument("--per-country", type=int, default=4, help="tối đa số tour cho mỗi điểm đến nước ngoài")
    ap.add_argument("--out", default=str(ROOT / "database" / "seed_fiditour.sql"))
    a = ap.parse_args()

    dom, intl_all, seen = [], [], set()
    for cat, intl in ((CAT_DOMESTIC, False), (CAT_INTL, True)):
        print(f"Đang lấy category {cat} ({'nước ngoài' if intl else 'trong nước'})…")
        posts = list_posts(cat)
        print(f"  {len(posts)} bài")
        freq = Counter(u for p in posts for u in set(post_images(p)))
        COMMON_IMAGES.update(u for u, n in freq.items() if n >= 3)
        for p in posts:
            t = build_tour(p, intl)
            if not t:
                continue
            key = re.sub(r"\W+", "", t["title"].lower())
            if key in seen:
                STATS["trùng tên"] += 1
                continue
            seen.add(key)
            (intl_all if intl else dom).append(t)
    print("Lý do bị loại:", dict(STATS))

    # Tour nước ngoài: giữ đa dạng điểm đến (tối đa N tour mỗi nước)
    per, chosen = Counter(), []
    for t in intl_all:
        if per[t["dest"]] >= a.per_country:
            continue
        per[t["dest"]] += 1
        chosen.append(t)
    chosen = chosen[: a.intl_limit]
    final = dom + chosen
    print(f"Hợp lệ: {len(dom)} trong nước, {len(intl_all)} nước ngoài -> chọn {len(dom)} + {len(chosen)}")
    print("Điểm đến nước ngoài:", dict(Counter(t["dest"] for t in chosen)))

    out = [
        "-- =====================================================================",
        "-- Tour mẫu lấy từ fiditour.com bằng tools/scrape_fiditour.py (chỉ phục vụ demo/học tập).",
        "-- Nội dung và ảnh thuộc bản quyền Fiditour; image_url trỏ trực tiếp về nguồn.",
        "-- Cột nguồn không có (ngày khởi hành, số chỗ, giá trẻ em) được sinh giả lập:",
        "--   departure_date = CURDATE() + n ngày, child_price ~ 75% giá người lớn, total_seats 20-40.",
        "-- Mã tour dạng FDT-<id bài viết>. INSERT ... ON DUPLICATE KEY UPDATE chỉ cập nhật phần nội dung",
        "-- (tên, giá, ảnh, lịch trình, ghi chú...), giữ nguyên ngày khởi hành, số chỗ và trạng thái -> chạy lại an toàn.",
        "-- =====================================================================",
        "USE tourdulich;",
        "",
    ]
    for n, t in enumerate(final):
        code = f"FDT-{t['pid']}"
        seats = 20 + (t["pid"] % 5) * 5
        avail = max(3, seats - (t["pid"] % 9))
        child = int(round(t["price"] * 0.75 / 1000.0) * 1000)
        day = 10 + (n * 3) % 70
        out.append(
            "INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, "
            "transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, "
            "short_description, itinerary, notes, gallery_urls, status, region)\nVALUES (\n"
            f"    (SELECT id FROM categories WHERE name = {sql(t['category'])} LIMIT 1), {sql(code)}, {sql(t['title'])},\n"
            f"    {sql(t['dep'])}, {sql(t['dest'])}, {sql(t['duration'])}, {sql(t['transport'])},\n"
            f"    DATE_ADD(CURDATE(), INTERVAL {day} DAY) + INTERVAL 7 HOUR,\n"
            f"    {t['price']}, {child}, {seats}, {avail}, {sql(t['image'])},\n"
            f"    {sql(t['desc'])},\n    {sql(t['itin'])},\n    {sql(t['notes'] or None)},\n    {sql(t['gallery'] or None)},\n"
            f"    'ACTIVE', {sql(t['region'])})\n"
            "ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), "
            "destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), "
            "adult_price = VALUES(adult_price), image_url = VALUES(image_url), "
            "short_description = VALUES(short_description), itinerary = VALUES(itinerary), "
            "notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);"
        )
        out.append(f"-- nguồn: {t['source']}\n")
    Path(a.out).write_text("\n".join(out), encoding="utf-8")
    print("Đã ghi", a.out)


if __name__ == "__main__":
    main()
