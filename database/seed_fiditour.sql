-- =====================================================================
-- Tour mẫu lấy từ fiditour.com bằng tools/scrape_fiditour.py (chỉ phục vụ demo/học tập).
-- Nội dung và ảnh thuộc bản quyền Fiditour; image_url trỏ trực tiếp về nguồn.
-- Cột nguồn không có (ngày khởi hành, số chỗ, giá trẻ em) được sinh giả lập:
--   departure_date = CURDATE() + n ngày, child_price ~ 75% giá người lớn, total_seats 20-40.
-- Mã tour dạng FDT-<id bài viết>. INSERT ... ON DUPLICATE KEY UPDATE chỉ cập nhật phần nội dung
-- (tên, giá, ảnh, lịch trình, ghi chú...), giữ nguyên ngày khởi hành, số chỗ và trạng thái -> chạy lại an toàn.
-- =====================================================================
USE tourdulich;

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-10421', 'Đà Nẵng - Bà Nà - Hội An 4N3Đ',
    'TP.HCM', 'Đà Nẵng', '4N3Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 10 DAY) + INTERVAL 7 HOUR,
    7990000, 5992000, 25, 17, 'https://fiditour.com/wp-content/uploads/2024/06/4.png',
    '04:30 Nhân Viên Công ty sẽ đón quý khách tai sân bay Tân Sơn Nhất, làm thủ tục khởi hành đi Huế trên chuyến bay VJ bay lúc 06h30 08h00: Đoàn khởi hành đi Phong Nha – Kẻ Bàng _ Di Sản Thiên Nhiên Thế Giới. Trên đường đi, đoàn viếng thăm…',
    'Ngày 1: TPHCM – THÁNH ĐỊA LA VANG – CẦU HIỀN LƯƠNG – ĐỘNG PHONG NHA (Trưa, Tối)
Sáng: 04:30 Nhân Viên Công ty sẽ đón quý khách tai sân bay Tân Sơn Nhất, làm thủ tục khởi hành đi Huế trên chuyến bay VJ bay lúc 06h30
08h00: Đoàn khởi hành đi Phong Nha – Kẻ Bàng _ Di Sản Thiên Nhiên Thế Giới. Trên đường đi, đoàn viếng thăm Thánh Địa La Vang là một trong những địa điểm hành hương quan trọng không chỉ riêng đồng bào Công giáo, mà còn của cả người không Công giáo và khách du lịch quốc tế. Tiếp đến đoàn dừng chân ngắm nhìn Vĩ tuyến 17 – Cầu Hiền Lương – Sông Bến Hải.
Trưa: Dùng cơm trưa tại nhà hàng ở Phong Nha, nghỉ ngơi tại nhà hàng.
Sau bữa trưa, đoàn ngồi thuyền ngược dòng sông Son, chinh phục Động Phong Nha kỳ vĩ, một thắng cảnh thiên nhiên mà tạo hoá đã ban tặng cho người dân Quảng Bình. Nơi đây, sự giao hoà của rừng nguyên sinh và sông Son, cùng với động khô và động nước tạo nên một bức tranh thuỷ mặc làm say lòng người. Đây là một trong những vùng đá vôi nhiệt đới cổ đại nhất, rộng lớn nhất thế giới với diện tích trên 200.000 ha. Có hệ thống hơn 300 hang động lớn nhỏ, tiềm ẩn nhiều điều kỳ lạ và hấp dẫn. Hang Bi Ký, Cô Tiên và Cung Đình dưới sâu lòng núi, nơi có con sông ngầm từ đất nước bạn Lào chảy sang.
15h00 : Đoàn khởi hành về lại Cố Đô Huế theo đường Trường Sơn – Hồ Chí Minh Huyền Thoại.
Tối: Đoàn dùng cơm tối tại nhà hàng Đông Hà, Quảng Trị.
Đến Huế, Sau đó đoàn khởi hành về khách sạn 3 * nhận phòng nghỉ ngơi, tự do thưởng thức đặc sản và tham quan thành phố Huế về đêm.
Phong Nha - Kẻ Bàng

Ngày 2: HUẾ – CHÙA THIÊN MỤ – LĂNG MINH MẠNG – ĐÀ NẴNG – HỘI AN (Sáng, Trưa)
Sáng: Dùng điểm tâm buffet tại khách sạn. Đoàn làm thủ tục trả phòng. Quý khách Tham quan chợ Đông Ba – Khu chợ truyền thống có bề dày lịch sử và văn hóa cao, đã đi qua hơn 100 năm với biết bao thăng trầm cùng Huế, tham quan và mua sắm quà cho người thân.
08:00 Đoàn đi tham quan Chùa Thiên Mụ, một ngôi chùa cổ nằm trên đồi Hà Khê, tả ngạn sông Hương. Chùa Thiên Mụ _ là một trong những thắng cảnh đẹp được nhắc đến nhiều nhất tại Huế. Không chỉ đi vào những bài thơ lãng mạn của xứ Huế mà còn trong cả câu ca, Thiên Mụ cũng được coi là một ngôi chùa linh thiêng và những cảnh không thể bỏ qua của bất cứ du khách nào khi đặt chân đến thủ đô cổ xưa này.
09h00: Đoàn ghé tham quan Lăng Minh Mạng Huế với kiến trúc truyền thống cổ xưa, mang đậm bản sắc Nho Giáo. Đây là điểm đến hấp dẫn mà du khách không nên bỏ lỡ trong hành trình về thăm cố đô để chiêm ngưỡng nghệ thuật kiến trúc lăng tẩm và hiểu hơn về các giai đoạn lịch sử quan trọng của đất nước.
11h00: Quý khách dùng cơm trưa tại nhà hàng. Sau đó Quý khách khởi hành về Đà nẵng
13h30: Đến với biển Lăng Cô, quý khách ngắm cảnh biển nổi tiếng của xứ Huế
14h00: Check in 1 địa điểm mà giới săn ảnh rất mê mẩn: Đầm Lập An, đầm được dải núi Bạch Mã hùng vĩ bao quanh, phía trước là vịnh Lăng Cô dịu êm với màu nước xanh ngọc bích. Mặt nước trong xanh như một tấm gương in sắc trời, màng sương mỏng luôn bao phủ,.. Người ta thường ví von đến Lập An tựa như đến một cõi mơ …..Tất cả đều ấy tạo cho du khách những xúc cảm khó tả,, đến 1 lần rồi nhớ mãi….
Ngoài ra, quý khách còn tận mắt nhìn cách dân địa phương nuôi Hàu, bắt hàu. Một khung cảnh thường nhật của người dân, nhưng lại là sự tò mò, hiếu kì của du khách.
15h00: Đến Đà Nẵng, Về khách sạn nhận phòng nghỉ ngơi
16h30: Quý khách bắt đầu khởi hành tham quan phố cổ Hội An, đây là phố đèn lồng đẹp nhất vào ban đêm mang phong cách đậm chất phố người Hoa. Trong tour quý khách sẽ có dịp tham quan chùa Cầu Nhật Bản, xây dựng vào đầu thế kỷ 17, một biểu tượng độc đáo và rất thân thương của người Hội An.
17h00: Đoàn tự túc dùng bữa tối và thưởng các đặc sản tại Hội An. Sau đó, quý khách sẽ tham quan: Thưởng thức bài chòi bên dòng sông Hoài thơ mộng, tự do mua sắm đặc sản Phố Hội tại chợ đêm Hội An với vô số gian hàng được trưng bày bắt mắt… Hoặc quý khách có thể tham quan và chụp ảnh tại chùa Cầu (chi phí vé tự túc). Nghỉ đêm tại Đà nẵng
Chùa Thiên Mụ

Ngày 3: KHÁM PHÁ ĐÀ NẴNG – BÀ NÀ HILL – HỘI AN
Sáng: Dùng điểm tâm Buffet tại khách sạn.
08h00: Quý khách đến trạm đón tiếp tại Bà Nà Hills, bắt đầu hành trình lên núi bằng hệ thống cáp treo đạt 4 kỉ lục của Thế Giới. (Gía vé tự túc).
Cầu Vàng – Toạ lạc ở độ cao 1414m so với mực nước biển. Đây là điểm tham quan thu hút nhiều du khách check-in
Tàu hỏa leo núi – Chuyến tàu hỏa leo núi đầu tiên và duy nhất tại Việt Nam được cung cấp bởi hãng Garaventa (Thụy Sỹ) đưa bạn đến vườn hoa D’Amour, hầm rượu cổ Debay và chùa Linh Ứng – những điểm đến không thể bỏ lỡ trong hành trình khám phá Bà Nà.
Hầm rượu cổ Debay, tại đây có thể thưởng thức 1 ly rượu vang Pháp trong không khi se lạnh của Bà Nà.
Khu vườn hoa Le Jardin D’amour (vườn suối mơ, vườn địa đàng, vườn bí ẩn, vườn uyên ương, vườn suy tưởng, …) với ngàn hoa đua sắc.
Chùa Linh Ứng – 1 trong 3 ngôi chùa linh thiêng của Đà Nẵng với bức tượng Đức Bổn Sư uy nghi, cao 27m màu trắng. Sau chùa là Vườn Lộc Uyển, Quan Âm Các…
Tiếp tục về lại ga Debay để lên cáp treo thứ 2.
Đến nơi, quý khách thưởng ngoạn khung cảnh làng Pháp, Quảng Trường Du Dôme…với kiến trúc theo phong cách Pháp đầy cổ kính.
Trưa: Du khách ăn trưa Buffet tại nhà hàng trên Bà Nà. (Nếu quý khách lựa chọn combo bao gồm ăn buffet).
Sau bữa trưa quý khách tham quan, vui chơi tại Thiên đường giải trí Fantasy Park (khu vui chơi trong nhà lớn nhất Việt Nam). Tham gia FREE 105 trò chơi cảm giác mạnh, phim 3D, 4D, 5D, tháp rơi tự do, công viên Khủng Long, đường đua rực lửa, xe trượt ống, …
Bảo tàng tượng sáp (chi phí tự túc), là nơi trưng bày bản sao của các chính trị gia, người nổi tiếng từ khắp các nước trên thế giới. Tại đây, quý khách có thể chụp hình với các diễn viên, ngôi sao bóng đá nổi tiếng như Mr Bean, David Backham, Lionel Messi……
Viếng Tháp Linh Phong Tự – với độ cao 9 tầng, mỗi tầng đều có 4 chiếc chuông đồng được treo ở bốn góc biểu trưng cho âm vang linh thiêng của một công trình kiến trúc tâm linh
Tham quan Lầu Chuông, Trú Vũ Trà Quán, Nhà Bia, Miếu Bà, … cùng cầu nguyện may mắn, phúc lộc, an yên, …
Chiều: Đoàn tập trung chuẩn bị rời Bà Nà, ngồi tuyến cáp treo xuống Ga Tóc Tiên, quý khách có thể ngắm thác Tóc Tiên mềm mại, những tán cây rừng, … xuống đến chân núi, tạm biệt Bà Nà
18h30: Xe và HDV đưa Quý khách dùng đặc sản Đà Nẵng, với món bánh tráng thịt heo nổi tiếng.
Tự do thưởng thức đặc sản Đà Nẵng như hải sản, bánh tráng cuốn thịt heo, mỳ quảng, … hoặc dạo chơi tại tuyến phố ẩm thực đêm đường Phạm Hồng Thái, …
Tối: Quý khách tự do dạo chơi, thăm quan Cầu Tình yêu, Cá chép hóa rồng, dạo bộ đường Bạch Đằng. Ngắm và thưởng thức cầu Rồng phun nước và phun lửa lúc 21h (thứ 7/CN hàng tuần)
Cầu Vàng

Ngày 4: ĐÀ NẴNG – BÁN ĐẢO SƠN TRÀ – CHÙA LINH ỨNG – HCM
Sáng: Quý khách dùng bữa sáng tại khách sạn. Quý khách tự do tắm biển Mỹ Khê.
Quý khách tại khách sạn khởi hành đi tham quan Bán Đảo Sơn Trà (Monkey Mountain) quay một vòng quanh Bán Đảo để thưởng ngoạn toàn cảnh phố biển Đà Nẵng trên cao. Xe đưa quý khách dọc theo triền núi Đông Nam để chiêm ngưỡng vẻ đẹp tuyệt mỹ của biển Đà Nẵng, Tại đây, du khách có thể khám phá những điểm đến tuyệt đẹp như Chùa Linh Ưng, đỉnh Bàn Cờ, Bãi Obama ….
Tại đây, quý khách tham quan Làng đá Mỹ nghệ Non Nước, một trong bốn ngôi làng cổ tại Quảng Nam – Đà Nẵng xưa kia tập trung vào nghề đúc, đẽo và tạc đá. Tiếp tục chương trình, quý khách sẽ thượng sơn tham quan ngọn Thủy Sơn, ngọn núi lớn nhất và đẹp nhất Ngũ Hành Sơn.
Trưa: Sau đó làm thủ tục trả phòng khách sạn. Đoàn dùng bữa trưa tại nhà hàng.
Qúy khách thăm quan và mua sắm tại Siêu thị Đặc sản miền trung/ Chợ hàn.
Sau đó xe và HDV tiễn đoàn ra sân bay Đà Nẵng, làm thủ tục lên máy bay. Chào tạm biệt và hẹn gặp lại.
Một số thứ tự, chi tiết trong chương trình; giờ bay; có thể thay đổi để phù hợp với tình hình thực tế của chuyến đi (thời tiết…).',
    'Giá tour bao gồm
Vận chuyển
Xe đời mới máy lạnh 16-30 Chỗ, đón khách theo chương trình.
Vé máy bay khứ hồi SGN-HUI – DAD-SGN bao gồm 7kg hành lý xách tay + 20 Kg ký gửi.
Lưu trú
Khách sạn 3 sao tại Huế (1 đêm): 2-3 khách/phòng
Khách sạn 4 sao tại Đà Nẵng (2 đêm): 2-3 khách/phòng
Phụ thu phòng đơn: 1.500.000 đ/khách
Ăn uống
Điểm tâm: 03 buổi tại khách sạn
Ăn chính: 04 buổi – 130.000đ/suất
01 buổi – 150.000đ/suất
Vé tham quan
Điểm tham quan trong chương trình.
Bảo hiểm
50.000.000 đ/Người/trường hợp
Hướng dẫn viên
1 HDV nhiệt tình, vui vẻ
Nước suối, khăn lạnh
Nước suối: 1 chai 500ml/ngày/khách
Khăn lạnh: 1 cái/ngày/khách

Giá tour không bao gồm
Chi phí cá nhân
Giặt ủi, điện thoại, ăn uống ngoài chương trình
Điểm tham quan
Vé cáp treo Bà Nà, Fantasy park (Từ tháng 1 đến tháng 3 giá 1.250.000đ/ khách đặt vào thời điểm book vé tour). Từ tháng 4 sẽ cập nhật lại giá khi có thông báo mới của Bà Nà.
Thuế VAT
Khách nào có nhu cầu xuất hóa đơn thì đóng thêm 08% giá tour

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá tour trẻ em
Trẻ em dưới 4 tuổi không tính giá tour; cha mẹ tự túc các chi phí (nếu có).
Trẻ em từ 5 – 7 tuổi tính 50% giá tour, Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ em từ 8-10 tuổi tính 70% giá tour. Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ từ 11 tuổi bằng giá người lớn. Ngủ giường riêng

Lưu ý:
Chương trình phụ thuộc vào thời tiết. Trường hợp không di chuyển Cano ra đảo,
chương trình sẽ khởi hành bằng đường bộ và không lặn ngắm san hô.
Thứ tự các điểm tham quan trong chương trình có thể thay đổi cho phù hợp với thời
gian hành trình. Tuy nhiên công ty vẫn đảm bảo các chương trình tuyến điểm cho quý
khách.
Giá tour không áp dụng các ngày lễ, tết
Giá tạm tính có thể thay đổi khi chi phí đầu vào như xăng dầu, giá vé tham quan, thực
phẩm,… thay đổi và sẽ được báo trước với đối tác, chậm nhất khi liên hệ.
Tùy thuộc vào đường bay và giờ bay của khách cty sẽ thiết kế chương trình tour sao
cho hợp lý và tối ưu nhất
Chương trình đón tiễn tại sân bay hoặc nhà ga Quy Nhơn buổi sáng từ 8h00 – 10h00,
tiễn các chuyến bay buổi chiều từ 15h00 – 17h00 ( phụ thu thêm chi phí tùy theo nhóm
khách)',
    'https://fiditour.com/wp-content/uploads/2024/06/7-cai-nhat-cua-phong-nha-ke-bang-1639936654793597781412.jpg
https://fiditour.com/wp-content/uploads/2024/06/a07a8cf87821b17fe830-1.jpg
https://fiditour.com/wp-content/uploads/2024/06/cau-vang-da-nang-13.webp
https://fiditour.com/wp-content/uploads/2024/06/unnamed.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/da-nang-ba-na-hoi-an/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Nghỉ dưỡng biển đảo' LIMIT 1), 'FDT-10414', 'Phan Thiết - Mũi Né 2N1Đ',
    'TP.HCM', 'Mũi Né', '2N1Đ', 'Xe du lịch',
    DATE_ADD(CURDATE(), INTERVAL 13 DAY) + INTERVAL 7 HOUR,
    2150000, 1612000, 40, 39, 'https://fiditour.com/wp-content/uploads/2024/06/1.png',
    'Buổi sáng: 07h00: Xe và hướng dẫn viên đón quý khách tại điểm hẹn, rời TP.HCM theo Cao tốc Dầu Giây – Phan Thiết khởi hành đi Mũi Né. (Tự túc ăn sáng) 10h30: Đến Phan Thiết, xe đưa quý khách đên check-in tại BÃI BIỂN BIKINI BEACH NOVA…',
    'Ngày 1: HỒ CHÍ MINH – PHAN THIẾT – CHECK-IN BIKINI BEACH – LÀNG CHÀI MŨI NÉ
Buổi sáng:
07h00: Xe và hướng dẫn viên đón quý khách tại điểm hẹn, rời TP.HCM theo Cao tốc Dầu Giây – Phan Thiết khởi hành đi Mũi Né. (Tự túc ăn sáng)
10h30: Đến Phan Thiết, xe đưa quý khách đên check-in tại BÃI BIỂN BIKINI BEACH NOVA WORLD PHAN THIẾT, là điểm check-in mới tại Phan Thiết đã đi vào hoạt động và được người dân cũng như du khách đặc biệt yêu thích với góc chụp hình hấp dẫn, các biểu tượng độc đáo như tượng happy boy- girl, cổng cầu vòng, nhà gỗ, khung chụp ảnh, logo Bikini Beach ngay tại bãi biển…
12h00: Quý khách dùng cơm trưa tại nhà hàng.
14h00: Đoàn về resort nhận phòng nghỉ ngơi, tự do tắm biển.
Xe đưa đoàn khởi hành tham quan Bàu Trắng – Được ví như sa mạc Sahara, đồi cát Bàu Trắng là một địa điểm du lịch độc đáo tại Mũi Né – Phan Thiết. Bạn sẽ ngỡ ngàng trước khung cảnh tựa như một bức họa kỳ vĩ. Giữa cái nắng chói chang, đồi cát hiện lên với một vẻ mông lung ảo diệu. Bạn sẽ được dịp chiêm ngưỡng cảnh hồ sen tuyệt đẹp được vây quanh bởi những triền cát bao la. Đứng từ trên đồi nhìn xuống, mặt hồ trong xanh rợp sắc hồng hoa sen trông rất thơ mộng và tràn đầy sức sống.
Bên cạnh đó, bạn có thể chơi trò trượt cát hoặc trải nghiệm đi xe Jeep địa hình để cảm nhận cảm giác thật tuyệt vời khi được lướt băng băng trên những triền cát, chinh phục hết đỉnh đồi này đến đỉnh đồi khác. (Chi phí ván trượt, xe Jeep tự túc)
Buổi tối:
Quý khách tự do thưởng thức các món đặc sản Phan Thiết như Bánh Căn, Bánh xèo, Bánh Canh, Bún Sứa, Bánh tráng mắm ruốc, hải sản,… thay cho bữa cơm tối. (bữa tối tự túc)
Hoặc 16h30: Quý khách đăng kí đi “LÀNG CHÀI MŨI NÉ” tham quan cảnh mua bán, đánh bắt hải sản của người dân, tự túc khám phá hải sản tươi sống tại chỗ tại Làng Chài địa phương.
19h00: Xe đưa quý khách về lại resort nghỉ ngơi. Nghỉ đêm tại Mũi Né. Hoặc quý khách có thể đăng kí tham gia chương trình Fishermen Show.
“CHƯƠNG TRÌNH ĐẶC BIỆT: THAM DỰ FISHERMEN SHOW”
Fishermen Show – Huyền Thoại Làng Chài (chi phí tự túc: 300.000đ – 500.000đ/vé tùy vị trí ghế ngồi) Show vũ kịch đương đại trên sân khấu nhạc nước, ĐẦU TIÊN và DUY NHẤT tại VIỆT NAM.
Thời lượng: 1 tiếng, bao gồm phần giải trí và 6 chương múa của 25 diễn viên trên sân khấu nhạc nước.

Ngày 2: MŨI NÉ – TP. HỒ CHÍ MINH
Buổi sáng:
Quý khách dùng điểm tâm sáng tại nhà hàng. Tự do tắm biển hoặc mua sắm đặc sản tại chợ Phan Thiết.
11h00: Quý khách làm thủ tục trả phòng. Xe đưa quý khách đến nhà hàng dùng bữa trưa.
CÔNG TY tặng mỗi hành khách 1 suất Bánh canh Tôm Hùm đặc sản của Phan Thiết.
14h00: Quý khách trở về HCM, trên đường ghé mua đặc sản của Bình Thuận như: Thanh Long, nước mắm, mực khô…. về làm quà cho người thân.
17h30: Đến Tp. HCM chia tay và hẹn gặp lại quý khách.
Lưu ý: Thứ tự các điểm tham quan trên có thể thay đổi tùy theo hoàn cảnh thực tế và điều kiện thời tiết, nhưng số lượng các điểm tham quan không thay đổi.',
    'Giá tour bao gồm
Xe ghế ngồi 16 chỗ, 29 chỗ đến 45 chỗ tùy số lượng khách.
Mỗi đợt khởi hành tối thiểu 25 khách/đợt (10 – 12 khách xe 16 chỗ, 25 – 28 khách xe 29c, 30 – 33 khách xe 35c, trên 40 khách xe 45c).
Xe đời mới máy lạnh, đón khách theo chương trình. Trường hợp không đủ số lượng khách thì được dời sang lịch khởi hành tiếp theo.
RESORT 3 SAO (Tiêu chuẩn 2-4 khách/phòng)
Phụ thu phòng đơn: 600.000đ/khách/đêm
Điểm tâm: 1 buổi: 1 buổi tại resort.
Ăn chính: 2 buổi
1 buổi trưa Set Menu
1 buổi Bánh canh Tôm Hùm
Vé vào cổng tham quan các điểm trong chương trình.
50.000.000 đ/Người/trường hợp. (Không được hưởng Bảo hiểm du lịch cho các trường hợp hợp sau: trên 80 tuổi, tiền sử các bệnh như: tim mạch, đột quỵ, …)
1 HDV nhiệt tình, vui vẻ phục vụ đoàn suốt tuyến
Nước suối: 1 chai 500ml/ngày/khách
Khăn lạnh: 1 cái/ngày/khách
Nón du lịch: 1 nón/khách

Giá tour không bao gồm
Giặt ủi, điện thoại, ăn uống ngoài chương trình…
Ăn sáng và ăn tối Ngày 1 tại Phan Thiết
Các điểm tham quan ngoài chương trình
Quý khách có nhu cầu xuất hóa hơn VAT vui lòng đóng thêm 10%

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá tour trẻ em
Trẻ em dưới 4 tuổi không tính giá tour; cha mẹ tự túc các chi phí (nếu có).
Trẻ em từ 5 – 7 tuổi tính 50% giá tour, Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ em từ 8-10 tuổi tính 70% giá tour. Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ từ 11 tuổi bằng giá người lớn. Ngủ giường riêng

Lưu ý:
Chương trình phụ thuộc vào thời tiết. Trường hợp không di chuyển Cano ra đảo,
chương trình sẽ khởi hành bằng đường bộ và không lặn ngắm san hô.
Thứ tự các điểm tham quan trong chương trình có thể thay đổi cho phù hợp với thời
gian hành trình. Tuy nhiên công ty vẫn đảm bảo các chương trình tuyến điểm cho quý
khách.
Giá tour không áp dụng các ngày lễ, tết
Giá tạm tính có thể thay đổi khi chi phí đầu vào như xăng dầu, giá vé tham quan, thực
phẩm,… thay đổi và sẽ được báo trước với đối tác, chậm nhất khi liên hệ.
Tùy thuộc vào đường bay và giờ bay của khách cty sẽ thiết kế chương trình tour sao
cho hợp lý và tối ưu nhất
Chương trình đón tiễn tại sân bay hoặc nhà ga Quy Nhơn buổi sáng từ 8h00 – 10h00,
tiễn các chuyến bay buổi chiều từ 15h00 – 17h00 ( phụ thu thêm chi phí tùy theo nhóm
khách)',
    NULL,
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/phan-thiet-mui-ne/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Văn hóa - Lịch sử' LIMIT 1), 'FDT-9108', 'Thánh Địa La Vang - Động Phong Nha - Cố Đô Huế 2N1Đ',
    'TP.HCM', 'Huế', '2N1Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 16 DAY) + INTERVAL 7 HOUR,
    2850000, 2138000, 35, 35, 'https://fiditour.com/wp-content/uploads/2024/01/3.png',
    'Đón quý khách tại Trung tâm Huế từ 6h30 – 07h00. Rời Huế đi Phong Nha – Kẻ Bàng. Viếng thăm Thánh Địa La Vang – Được phong tặng là Tiểu Vương Cung Thánh Đường, là nơi lưu dấu những vết tích của lịch sử và là trung tâm hành hương Công Giáo…',
    'Ngày 1: Thánh Địa La Vang – Động Phong Nha
Sáng: Đón quý khách tại Trung tâm Huế từ 6h30 – 07h00.
Rời Huế đi Phong Nha – Kẻ Bàng. Viếng thăm Thánh Địa La Vang – Được phong tặng là Tiểu Vương Cung Thánh Đường, là nơi lưu dấu những vết tích của lịch sử và là trung tâm hành hương Công Giáo lớn nhất cả nước.
Trên hành trình quý khách được ngang qua Vĩ tuyến 17, Sông Bến Hải – Cầu Hiền Lương huyền thoại – là biểu tượng cho khát vọng thống nhất non sông không thể nguôi trong suốt 20 năm trường.
Và ngang qua vùng Lệ Thủy, nơi có Cánh đồng điện gió Quảng Bình là dự án điện gió trên bờ có quy mô lớn nhất Việt Nam tính đến thời điểm hiện nay.
Trưa: Ăn trưa nhà hàng tại Phong Nha.
Chiều: Ngồi thuyền ngược sông Son chinh phục Động Phong Nha: Cô Tiên & Cung Đình dưới sâu lòng núi nơi có con sông ngầm từ Lào chảy sang, chiêm ngưỡng các khối thạch nhũ tuyệt đẹp được kiến tạo bởi thiên nhiên qua hàng ngàn thiên niên kỷ.
Khởi hành về Huế theo đường Trường Sơn – Hồ Chí Minh.
Tối: Ăn tối nhà hàng, tự do khám phá Cố Đô về đêm với cầu Tràng Tiền rực rỡ soi mình xuống dòng sông Hương thơ mộng, dạo chơi chợ đêm tìm hiểu nét sinh hoạt của đất kinh thành.
Phong Nha - Kẻ Bàng

Ngày 2: Đại Nội – Làng Hương Thủy Xuân – Tiễn khách ( Ăn sáng , trưa )
Sáng: Dùng điểm tâm sáng tại khách sạn. Trả phòng.
Khởi hành tham quan Đại Nội – Hoàng cung triều
Nguyễn, nơi hội tụ các nét đẹp kiến trúc đỉnh cao của thời đại phong kiến nhà Nguyễn, được xây dựng cách đây hàng trăm năm với diện tích vô cùng đồ sộ, có hơn 100 công trình kiến trúc lộng lẫy như: Ngọ Môn, Cung Diên Thọ, Tử Cấm Thành, Điện Thái Hòa được bố trí
hài hòa, hợp lý.
Quý khách tiếp tục tham quan Làng Hương Thủy Xuân – Làng nghề làm hương truyền thống hơn 700 năm của xứ Huế. Quý khách có thể tìm hiểu về quy trình làm hương, trải nghiệm các công đoạn cũng như check-in cùng không gian đa sắc màu tuyệt đẹp.
Trưa: Ăn trưa nhà hàng tại Huế.
Chiều: Tiễn quý khách ra sân bay Huế (các chuyến sau 14h00). Và sân bay Đà Nẵng (các chuyến sau 17h00).
Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách!',
    'Giá tour bao gồm
o Vận chuyển: 01 xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình
o Lưu trú: Tiêu chuẩn 3 sao. 2 khách người lớn/phòng. Nếu lẻ nam hoặc lẻ nữ sẽ ngủ ghép phòng 3 khách.
• Khách sạn 4* Huế: Parkview, Mondial, …
o Hướng dẫn viên: Tiếng Việt phục vụ suốt tuyến, vui vẻ, nhiệt tình.
o Các bữa ăn theo chương trình:
• 02 bữa ăn sáng Buffet
• Bữa chính: 130.000vnđ/suất.
o Vé các điểm tham quan.
o Vé nghe Ca Huế trên sông Hương.
o Thuyền tham quan Động Phong Nha
o Phục vụ 02 chai nước suối Dasani 500ml/khách /ngày.
o Bảo hiểm du lịch: 30.000.000 VNĐ/vụ

Giá tour không bao gồm
✓ Vé máy bay khứ hồi, tàu, xe.
✓ Chi phí cá nhân, uống tự gọi trong các bữa ăn,.. và tham quan vận chuyển ngoài chương trình.
✓ Combo Vé cáp treo Bà Nà & Ăn Buffet tại Bà Nà (tùy thuộc theo giá công bố của tập đoàn Sun Group.)
✓ Vé du thuyền Sông Hàn.
✓ Tip cho Hướng dẫn viên và tài xế

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport)
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá vé tour trẻ em:
Trẻ em dưới 5 tuổi: miễn phí, cha mẹ tự lo các chi phí phát sinh (nếu có).
Trẻ em từ 5 – dưới 10 tuổi: 50% giá tour, ngủ chung với cha mẹ.
Trẻ em từ 10 tuổi trở lên: bằng vé nguời lớn.
02 người lớn được kèm 01 trẻ em dưới 05 tuổi. Từ trẻ thứ 02 trở lên, quý khách vui lòng trả 50% giá vé người lớn.
Tiêu chuẩn 50% vé: được 1 suất ăn + 1 ghế ngồi trên xe và ngủ chung giường với bố mẹ.
GIÁ VÉ MÁY BAY TRẺ EM: Theo qui định riêng của từng hãng hàng không
Trẻ em dưới 2 tuổi: 10% giá vé máy bay.
Trẻ em từ 2 – dưới 12 tuổi: 90% giá vé máy bay (Vietnam Airlines); 100% giá vé máy bay (Vietjet Air).
Trẻ em từ 12 tuổi trở lên: 100% giá vé máy bay',
    'https://fiditour.com/wp-content/uploads/2024/06/7-cai-nhat-cua-phong-nha-ke-bang-1639936654793597781412-1.jpg
https://fiditour.com/wp-content/uploads/2024/01/352521770_6922050131.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/da-nang-hoi-an-ba-na-hue-dong-phong-nha-4n3d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Văn hóa - Lịch sử' LIMIT 1), 'FDT-9096', 'Bà Nà Núi Chúa - Cố Đô Huế - Thánh Địa La Vang - Động Phong Nha 3N2Đ',
    'TP.HCM', 'Đà Nẵng', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 19 DAY) + INTERVAL 7 HOUR,
    3300000, 2475000, 25, 19, 'https://fiditour.com/wp-content/uploads/2024/01/1.png',
    'Thứ Sáu – Thứ Hai Sáng: Đón khách tại sân bay Đà Nẵng từ 06h30 – 07h15. Khởi hành đi Bà Nà – Núi Chúa (Tự túc chi phí Option Bà Nà theo giá của Sun Group), nơi có những khoảnh khoắc giao mùa bất ngờ Xuân – Hạ – Thu – Đông trong một ngày.…',
    'Ngày 1: ĐÓN KHÁCH – BÀ NÀ NÚI CHÚA – CỐ ĐÔ HUẾ
Thứ Sáu – Thứ Hai
Sáng: Đón khách tại sân bay Đà Nẵng từ 06h30 – 07h15. Khởi hành đi Bà Nà – Núi Chúa (Tự túc chi phí Option Bà Nà theo giá của Sun Group), nơi có những khoảnh khoắc giao mùa bất ngờ Xuân – Hạ – Thu – Đông trong một ngày. Qúy khách sẽ tận hưởng cảm giác bồng bền khi ngồi trên Cabin lơ lững giữa chừng mây. Viếng chùa Linh Ứng với tượng Phật Thích Ca cao 27m, viếng đền thờ Bà Chúa Mẫu Thượng Ngàn. Tham quan Cầu vàng – Cây cầu độc đáo nằm trong vườn Thiên Thai ở Bà Nà Hill – được xây dựng trên độ cao 1.400m so với mặt nước biển, cây cầu gồm 8 nhịp và có độ dài là 150m. Cây cầu được nâng đỡ bởi đôi bàn tay khổng lồ. Người đi như lạc giữa tiên cảnh nơi có mây, trời bao la.
Tham gia vui chơi tại công viên Fantasy Park: với các trò chơi phiêu lưu mới lạ như: Vòng Quay Tình Yêu, Phi Công Skiver, Đường Đua Lửa, Ngôi Nhà Ma và Khu trưng bày hơn 40 tượng sáp những nhân vật nổi tiếng trên thế giới…
Trưa: Ăn trưa Option Buffet tại Bà Nà (Nếu quý khách không đăng ký đi hoặc không ăn buffet Bà Nà thì tự túc chi phí ăn trưa và nhập đoàn)
Chiều: Khởi hành đi Cố Đô Huế – Di sản văn hoá Thế Giới, xuyên hầm đường bộ đèo Hải Vân, dừng chân tại làng chài Lăng Cô chụp hình lưu niệm. Nhận phòng khách sạn 4* nghỉ ngơi.
Đến thành phố Huế, quý khách dừng chân viếng Chùa Thiên Mụ cổ kính, là nơi lưu giữ nhiều cổ vật quý có giá trị về mặt lịch sử và nghệ thuật.
Tối: Ăn tối nhà hàng với đặc sản xứ Huế (Bánh bèo, lọc, nậm, khoái,…). Quý khách xuống thuyền Rồng để thưởng thức Ca Huế trên sông Hương – nét văn hóa độc đáo của xứ Huế, ngắm nhìn cầu Tràng Tiền bắc ngang qua dòng sông Hương, là biểu tượng đặc trưng của xứ Huế, cũng là chứng tích lịch sử chứng kiến biết bao thăng trầm lịch sử của đất nước.
Bà Nà Núi Chúa

Ngày 2: THÁNH ĐỊA LA VANG – ĐỘNG PHONG NHA
Thứ Bảy – Thứ Ba
Sáng: Điểm tâm sớm. Rời Huế đi Phong Nha – Kẻ Bàng. Viếng thăm Thánh Địa La Vang – Được phong tặng là Tiểu Vương Cung Thánh Đường, là nơi lưu dấu những vết tích của lịch sử và là trung tâm hành hương Công Giáo lớn nhất cả nước.
Trên hành trình quý khách được ngang qua Vĩ tuyến 17, Sông Bến Hải – Cầu Hiền Lương huyền thoại – là biểu tượng cho khát vọng thống nhất non sông không thể nguôi trong suốt 20 năm trường. Và ngang qua vùng Lệ Thủy, nơi có Cánh đồng điện gió Quảng Bình là dự án điện gió trên bờ có quy mô lớn nhất Việt Nam tính đến thời điểm hiện nay.
Trưa: Ăn trưa nhà hàng tại Phong Nha.
Chiều: Ngồi thuyền ngược sông Son chinh phục Động Phong Nha: Cô Tiên & Cung Đình dưới sâu lòng núi nơi có con sông ngầm từ Lào chảy sang, chiêm ngưỡng các khối thạch nhũ tuyệt đẹp được kiến tạo bởi thiên nhiên qua hàng ngàn thiên niên kỷ. Khởi hành về Huế theo đường Trường Sơn – Hồ Chí Minh.
Tối: Ăn tối nhà hàng, tự do khám phá Cố Đô về đêm với cầu Tràng Tiền rực rỡ soi mình xuống dòng sông Hương thơ mộng, dạo chơi chợ đêm tìm hiểu nét sinh hoạt của đất kinh thành.
Phong Nha - Kẻ Bàng

Ngày 3: ĐẠI NỘI – LÀNG HƯƠNG THỦY XUÂN – TIỄN KHÁCH
Chủ Nhật – Thứ Tư
Sáng: Điểm tâm. Trả phòng. Khởi hành tham quan Đại Nội – Hoàng cung triều Nguyễn, nơi hội tụ các nét đẹp kiến trúc đỉnh cao của thời đại phong kiến nhà Nguyễn, được xây dựng cách đây hàng trăm năm với diện tích vô cùng đồ sộ, có hơn 100 công trình kiến trúc lộng lẫy như: Ngọ Môn, Cung Diên Thọ, Tử Cấm Thành, Điện Thái Hòa được bố trí hài hòa, hợp lý.
Quý khách tiếp tục tham quan Làng Hương Thủy Xuân – Làng nghề làm hương truyền thống hơn 700 năm của xứ Huế. Quý khách có thể tìm hiểu về quy trình làm hương, trải nghiệm các công đoạn cũng như check-in cùng không gian đa sắc màu tuyệt đẹp.
Trưa: Ăn trưa nhà hàng tại Huế.
Chiều: Tiễn quý khách ra sân bay Huế (các chuyến sau 14h00). Và sân bay Đà Nẵng (các chuyến sau 17h00). Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách!
Làng Hương Thuỷ Xuân
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Xe vận chuyển tốt đời mới phục vụ theo chương trình.
Ngủ 2-3 khách/phòng khách sạn tiện nghi 4 sao Huế.
Khách sạn 4* Huế: Parkview, Mondial, …
Ăn các bữa theo tour: 02 bữa sáng buffet + 04 bữa chính tiêu chuẩn 130.000 VNĐ/suất.
Vé các điểm tham quan.
Vé nghe Ca Huế trên sông Hương.
Thuyền tham quan Động Phong Nha
Hướng dẫn viên tiếng Việt phục vụ tận tình.
Phục vụ 02 chai nước suối Dasani 500ml/khách /ngày.
Bảo hiểm du lịch: 30.000.000 VNĐ/vụ

Giá tour không bao gồm
Vé máy bay khứ hồi, tàu, xe.
Chi phí cá nhân, uống tự gọi trong các bữa ăn,.. và tham quan vận chuyển ngoài chương trình.
Combo Vé cáp treo Bà Nà & Ăn Buffet tại Bà Nà (tùy thuộc theo giá công bố của tập đoàn Sun Group.)
Tip cho Hướng dẫn viên và tài xế.

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport)
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá vé tour trẻ em:
Trẻ em dưới 5 tuổi: miễn phí, cha mẹ tự lo các chi phí phát sinh (nếu có).
Trẻ em từ 5 – dưới 10 tuổi: 50% giá tour, ngủ chung với cha mẹ.
Trẻ em từ 10 tuổi trở lên: bằng vé nguời lớn.
02 người lớn được kèm 01 trẻ em dưới 05 tuổi. Từ trẻ thứ 02 trở lên, quý khách vui lòng trả 50% giá vé người lớn.
Tiêu chuẩn 50% vé: được 1 suất ăn + 1 ghế ngồi trên xe và ngủ chung giường với bố mẹ.
GIÁ VÉ MÁY BAY TRẺ EM: Theo qui định riêng của từng hãng hàng không
Trẻ em dưới 2 tuổi: 10% giá vé máy bay.
Trẻ em từ 2 – dưới 12 tuổi: 90% giá vé máy bay (Vietnam Airlines); 100% giá vé máy bay (Vietjet Air).
Trẻ em từ 12 tuổi trở lên: 100% giá vé máy bay',
    'https://fiditour.com/wp-content/uploads/2024/01/le-hoi-carnival-ba-na-hill-da-nang-3.jpg
https://fiditour.com/wp-content/uploads/2024/06/7-cai-nhat-cua-phong-nha-ke-bang-1639936654793597781412-1.jpg
https://fiditour.com/wp-content/uploads/2024/01/lang-huong-thuy-xuan-7-1410.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ba-na-nui-chua-co-do-hue-dong-phong-nha-3n2d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Khám phá & Trekking' LIMIT 1), 'FDT-9034', 'Hà Giang - Đồng Văn - Mã Pì Lèng Cao Bằng - Mèo Vạc Thác Bản Giốc - Lạng Sơn 5N4Đ',
    'TP.HCM', 'Hà Giang', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 22 DAY) + INTERVAL 7 HOUR,
    10990000, 8242000, 40, 33, 'https://fiditour.com/wp-content/uploads/2022/12/14.png',
    'Buổi sáng: Nhân viên Công ty du lịch sẽ làm thủ tục chuyến bay Sài Gòn – Hà Nội, quý khách hạ cánh xuống sân bay Nội Bài, HDV đón tại sân bay Nội Bài khởi hành đi Hà Giang. Đến thành phố Tuyên Quang quý khách dùng cơm trưa, sau đó tham…',
    'Ngày 1: SÀI GÒN ✈ HÀ NỘI  HÀ GIANG
Buổi sáng: Nhân viên Công ty du lịch sẽ làm thủ tục chuyến bay Sài Gòn – Hà Nội, quý khách hạ cánh xuống sân bay Nội Bài, HDV đón tại sân bay Nội Bài khởi hành đi Hà Giang. Đến thành phố Tuyên Quang quý khách dùng cơm trưa, sau đó tham quan chụp ảnh di tích thành cổ nhà Mạc.
Đoàn tiếp tục di chuyển đi Hà Giang – vùng đất có chè san tuyết, rượu mật ong và thắng cố, xứ sở của đào phai, hoa lê, truyền thống và náo nhiệt trong buổi chợ phiên. Đến Hà Giang quý khách ghé tham quan chụp ảnh km số 0.
Xe đưa quý khách dùng bữa tối sau đó về khách sạn làm thủ tục nhận phòng nghỉ ngơi.
Quý Khách tự do nghỉ ngơi hoặc dạo phố thưởng thức cà phê Núi Cấm “điểm cao nhất Hà Giang”.

Ngày 2: HÀ GIANG  QUẢN BẠ  YÊN NINH  ĐỒNG VĂN
Buổi Sáng, Quý khách làm thủ tục trả phòng, ăn sáng. Đoàn khởi hành theo quốc lộ 4C đi Quản Bạ. Trên đường, Quý Khách dừng chân ngắm cảnh và chụp ảnh tại dốc Bắc Sum.
Tiếp tục khởi hành qua Cổng trời, Núi Đôi là du khách đã lên đến Cổng trời Quản Bạ – nơi tiếp giáp giữa trời và đất. Đoàn thỏa sức chiêm ngưỡng phong cảnh thơ mộng vùng đồi núi thị trấn Tam Sơn từ trên cao.
Sau đó khởi hành đi Yên Minh. Dùng cơm trưa tại thị trấn Yên Minh.
Buổi Chiều: Sau khi ngắm cảnh dốc Thẩm Mã , dốc Chín Khoanh, đoàn đến Sủng Là thăm nhà cổ H’mông với tường trình bằng đất – nơi đã được sử dụng làm bối cảnh để quay bộ phim nhựa “Chuyện của Pao” năm 2006 của đạo diễn Ngô Quang Hải được chuyển thể từ truyện ngắn “Tiếng đàn môi sau bờ rào đá”
Xe đưa Quý Khách đến khu di tích Dinh Vua Mèo – Vương Chính Đức nằm trong một thung lũng của xã Sà Phìn, đây là dòng họ giàu có và uy quyền nhất trong lịch sử dân tộc H’mông ở huyện Đồng Văn đầu thế kỷ 20, là di tích lịch sử văn hóa đã được Nhà nước công nhận.
Đoàn khởi hành đi thăm cột cờ Lũng Cú, điểm cực bắc và là nóc nhà của Việt Nam –“Nơi mà cúi mặt sát đất, ngẩng mặt đụng trời“. Đoàn về đến Đồng Văn ăn tối, nhận phòng nghỉ ngơi.
Buổi tối, Quý Khách tự do dạo phố, khám phá hoặc thưởng thức đặc sản phố cổ Đồng Văn về đêm. Nghỉ đêm tại Đồng Văn.

Ngày 3: ĐỒNG VĂN  MÃ PÌ LÈNG  HẺM TU SẢN  CAO BẰNG
Buổi sáng : Quý khách ăn sáng tại khách sạn trả phòng, Đoàn khởi hành đi Mèo Vạc.
Qúy khách dừng chân ngắm cảnh đèo Mã Phì Lèng, một trong “Tứ Đại Đèo” nổi tiếng nước ta, là đoạn đẹp nhất trên con đường mang tên “Đường Hạnh phúc”. Chụp hình với vẻ đẹp hùng vĩ của hẻm vực Mã Pì Lèng sâu 800m – nơi địa hình bị chia cắt sâu nhất của Việt Nam. Quý khách đi xe ôm xuống bến thuyền quý khách lên thuyền ngắm cảnh sông Nho Quế và hẻm vực Tu Sản khoảng 1 tiếng. (Phí thuyền và xe tự túc nếu điều kiện thời tiết tốt)
Đến thị trấn Mèo Vạc, đoàn có cơ hội tham quan chợ Mèo Vạc .
Tiếp tục khởi hành đi Cao Bằng, dùng cơm trưa tại tại thị trấn Bảo Lạc. Sau đó tiếp tục qua đèo Mẽ Pia, hay còn gọi là dốc 14 tầng.
Ghé tham quan di tích hang Pắc Bó nơi chủ tịch Hồ Chí Minh từng sinh sống và hoạt động cách mạng những năm đầu khi mới về nước. Đến Cao Bằng, đòan nhận phòng khách sạn.
Buổi tối, đi bộ tham quan phố đêm vào tối thứ 6,7. nghỉ đêm tại Cao Bằng.

Ngày 4: CAO BẰNG  THÁC BẢN GIỐC  LẠNG SƠN
Buổi Sáng, Đoàn trả phòng, khởi hành đi ăn sáng. Sau đó di chuyển đi tham quan thác Bản Giốc, thác có độ cao hơn 50m, chia làm 3 tầng được coi là thác đẹp nhất Việt Nam và là thác lớn nhất Đông Nam Á. Đây là thác nước lớn thứ 4 trong top 10 thác nước trên thế giới.
Tiếp tục hành trình, Quí khách khám phá động Ngườm Ngao hay còn gọi là động hổ, một trong những hang động đẹp nhất không chỉ của Cao Bằng mà của cả miền Bắc.
Sau khi dùng cơm trưa quý khách khởi hành đi Lạng Sơn ( 180km ) theo đường Phục Hòa – Đông khê. Trên đường đi Quí khách dừng chân tham quan cửa khẩu Hữu Nghị Quan nơi bắt đầu con đường thiên ký Bắc Nam (Ải Nam Quan) (Nếu cửa khẩu có mở cửa).
Buổi tối, quý khách tự do đi chợ đêm Kỳ Lừa.

Ngày 5: LẠNG SƠN  ĐỘNG TAM THANH  NỘI BÀI
Buổi sáng, Đoàn dùng bữa sáng tại khách sạn khởi hành tham quan chùa Tam Thanh, động
Tam Thanh nổi tiếng, chiêm ngưỡng Hòn Vọng Phu trên núi Tô Thị nổi tiếng trong văn thơ Việt Nam.
Đoàn tham quan mua sắm tại chợ Đông Kinh, ngôi chợ lớn nhất xứ Lạng.
Đoàn dùng cơm trưa sau đó trả phòng khởi hành trở về sân bay Nội Bài đáp chuyến bay về lại Sài Gòn.
Về đến sân bay Tân Sơn Nhất chia tay đoàn hẹn ngày gặp lại.',
    'Giá tour bao gồm
Vé máy bay và hành lý khứ hồi (10kg xách tay + 23kg kí gửi) SGN/HAN/SGN hãng hàng không Vietnam Airlines
Xe ô tô phục vụ khách du lịch, máy lạnh suốt tuyến, tài xế nhiều năm kinh nghiệm.
Ăn sáng: theo chương trình tour tại khách sạn và nhà hàng.
Ăn Chính: 09 bữa chính, thực đơn phong phú từ 5-6 món/bữa ăn (tùy theo từng chuyến bay công ty du lịch sẽ sắp xếp phù hợp đảm bảo đủ 5 bữa ăn cho quý khách).
Khách sạn 3 sao tiêu chuẩn 2 người/phòng. Trường hợp khách có nhu cầu phòng 3 hoặc 4 sẽ được bố trí theo yêu cầu của khách.
Hà Giang : Hà An/ Cao Nguyên/ Silk River
Đồng Văn : Hoa Cương/ Hoàng Ngọc / Khải Hoàn .
Cao Bằng : Max Boutieque/ Los Angeles / Gia Qúy
Lạng Sơn : Mường Thanh
Quý khách được bao vé tham quan vào cổng Khu Du Lịch các điểm có trong chương trình.
Vui vẻ, nhiệt tình, nhiều kinh nghiệm, nói tiếng việt phục vụ đoàn suốt tuyến.
Nón du lịch, nước suối mỗi ngày.
Quý khách được tham gia bảo hiểm khi đi Du Lịch, mức bồi thường tối đa: 20.000.000 VNĐ/1 trường hợp.

Giá tour không bao gồm
Phụ thu phòng đơn : 1.800.000vnd (cho khách có nhu cầu ngủ riêng 1 người/ phòng) – lễ, tết phụ thu thêm: 400.000vnd
Chi phí điện thoại cá nhân, ăn uống, vé tham quan ngoài chương trình.
Thuế VAT 8% (cho đến khi có thông báo mới)

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CMND/CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình.
Là tour miền núi, thường đi xe nhỏ nên đề nghị Quý khách không mang hành lý cồng kềnh, quá khổ và không mang nhiều hành lý. Nên mang balo thay vì mang những vali cứng.

Giá tour trẻ em
– Tính theo năm sinh, không tính theo ngày tháng sinh.
Trẻ em dưới 06 tuổi miễn phí dịch vụ, hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 1 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.',
    NULL,
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-giang-dong-van-ma-pi-leng-cao-bang-meo-vac-thac-ban-gioc-lang-son-5n4d-2/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Khám phá & Trekking' LIMIT 1), 'FDT-9029', 'Hà Giang - Đồng Văn Thác Bản Giốc - Pác Bó - Hồ Ba Bể 5N4Đ',
    'TP.HCM', 'Hà Giang', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 25 DAY) + INTERVAL 7 HOUR,
    5650000, 4238000, 40, 38, 'https://fiditour.com/wp-content/uploads/2022/12/13-1.png',
    'Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh từ 8h00 – 9h00), khởi hành đi Hà Giang. Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang. Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp…',
    'Ngày 1: (Thứ năm): Đón khách – Tuyên Quang – Hà Giang ( Ăn: Trưa, Chiều)
Sáng: Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh từ 8h00 – 9h00), khởi hành đi Hà Giang. Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang.
Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp hình tại đồi chè Hàm Yên, ngắm dòng sông Lô hùng vĩ.
Đến thành phố Hà Giang, chụp hình kỷ niệm tại Km0 của Hà Giang. Điểm giao nhau của QL2, QL34 và QL4C hay còn gọi là Con đường hạnh phúc.
Tối : Quý khách ăn tối và tự do dạo chơi thăm Hà Giang về đêm.
Đồi chè Hàm Yên

Ngày 2: (Thứ Sáu): Hà Giang – Yên Minh – Đồng Văn – Lũng Cú
Sáng: Quý khách ăn sáng, trả phòng khách sạn, lên xe khởi hành đi Cao nguyên đá Đồng Văn – Khám phá vẻ đẹp hoang sơ, hùng vĩ của núi rừng Đông Bắc, dừng chân tại Cổng Trời Quản Bạ ngắm toàn bộ thị trấnTam Sơn, xã Quản Bạ, dừng chân thăm & chụp hình lưu niệm tại Núi Đôi (núi Cô Tiên) – một thắng cảnh đẹp nổi tiếng của thị trấn và cũng là một minh chứng về lòng chung thủy của nhân gian truyền lại từ đời này qua đời khác.
Tham quan Phố Cáo với những ngôi nhà đặc trưng của người H’mông bởi những hàng rào đá cung quanh nhà.
Thăm bản Sủng Là thăm ngôi nhà Cổ của người H’mông với tường trình bằng đất – nơi đã được sử dụng làm bối cảnh để quay bộ phim nhựa “Chuyện của Pao” năm 2006 của đạo diễn Ngô Quang Hải được chuyển thể từ truyện ngắn “Tiếng đàn môi sau bờ rào đá” của nhà văn Đỗ Bích Thủy đã giành được 4 giải Cánh diều vàng. Quý khách dừng chân nghỉ ngơi và chụp hình hoa tam giác mạch gần dốc chín khoanh.
Chiều: Thăm Cột Cờ Lũng Cũ – nơi địa đầu Tổ quốc, điểm có vĩ độ cao nhất trên bản đồ của Việt Nam.
Dinh Vua Mèo – Vương Chính Đức nằm trong một thung lũng của xã Sà Phìn, đây là dòng họ giàu có và quyền uy nhất Châu Đồng Văn vào đầu thế kỷ 20.
Tối: Quý khách tự do khám phá Đồng Văn về đêm.
Cột cờ Lủng Cú

Ngày 3: ( Thứ 7): Đồng Văn – Mèo Vạc – Cao Bằng – Pắc Pó
Sáng: Quý khách trả phòng khách sạn, chinh phục đèo Mã Pì Lèng trên đường đi Mèo Vạc, cũng là đoạn đẹp nhất trên con đường mang tên “Đường Hạnh phúc”.
Chụp hình với vẻ đẹp hùng vĩ của hẻm vực Mã Pì Lèng sâu 800m – nơi địa hình bị chia cắt sâu nhất của Việt Nam.
Du thuyền trên Sông Nho Quế: Lên thuyền xuôi dòng Nho Quế đến với Hẻm Tu sản, là hẻm vực sâu nhất của Việt Nam nằm trên dòng sông Nho Quế. Dòng Nho Quế chảy vào Việt Nam từ địa phận thôn Xéo Lủng, xã Lũng Cú, huyện Đồng Văn đi qua Hẻm núi Tu Sản chạy men theo chân đèo Mã Pì Lèng ( Chí phí vé tự túc).
Chiều: Quý khách tiếp tục khởi hành đi Cao Bằng. Đến Pác Bó, Quý khách thăm quan Khu di tích lịch sử Pắc Bó. Vào thăm nơi ở và hoạt động của Chủ tịch Hồ Chí Minh trong những năm kháng chiến từ 1941 đến 1945, đoàn chụp hình lưu niệm tại Suối Lê Nin – Núi Các Mác, thăm hang Cốc Bó. Trở về Cao Bằng nhận phòng nghỉ ngơi, Ăn tối tại nhà hàng và thưởng thức các món ăn đặc sản của địa phương.
Tối: Khám phá Cao Bằng về đêm.
Đèo Mã Pí Lèng

Ngày 4: ( Chủ Nhật): Cao Bằng – Thác Bản Giốc – Hồ Ba Bể
Sáng: Quý khách ăn sáng, trả phòng khách sạn, lên xe khởi hành đi tham quan:
Thác Bản Giốc, thác có độ cao 53m, chia làm 3 tầng được coi là thác đẹp nhất Việt Nam và là thác lớn nhất Đông Nam Á. Đây là thác nước lớn thứ 4 trong top10 thác nước trên thế giới nằm trên đường biên giới giữa hai quốc gia.
Thăm quan động Ngườm Ngao (động Hổ), một trong những hang động đẹp nhất không chỉ của Cao Bằng mà của cả miền Bắc.
Chiều: Quý khách khởi hành đi Hồ Ba Bể, ngắm cảnh đẹp yên bình nông thôn miền núi phía Bắc, nhận phòng, ăn tối, nghỉ ngơi.
Tối: Khám phá Ba Bể về đêm.
Thác Bản Giốc

Ngày 5: ( Thứ 2): Ba Bể – Sân bay Nội Bài
Sáng: Quý khách ăn sáng, ra bến xuống thuyền thăm quan hồ Ba Bể:
Ao tiên: Ao Tiên nằm ở góc hồ ba của hồ Ba Bể, là một hồ nước nhỏ nằm lọt giữa một ngọn núi nhô cao trên mặt hồ. Tương truyền là nơi xưa kia các vị thần tiên thường ngồi chơi cờ ở đây.
Đền An Mạ: Đền nằm trên một ngọn núi nhỏ giữa lòng hồ. Tương truyền, trong chiến tranh phong kiến thời Lê – Mạc, các tướng nhà Mạc đã thất trận, chạy đến Động Puông rồi tuẫn tiết tại đó. Cảm kích tinh thần trung liệt, người dân đã dựng đền thờ họ Mạc, song lo bị quan quân nhà Lê phát hiện dẹp bỏ nên đã đổi tên thành Đền An Mạ. Hai từ “An Mạ” theo tiếng dân tộc Tày có nghĩa là “mồ yên mả đẹp”, nơi yên nghỉ của các trung thần họ Mạc.
Đảo Bà Góa – một hòn đảo nhỏ xinh xắn nằm ngay vị trí trung tâm của Hồ, gắn liền với sự tích hình thành của Hồ. Thuyền đi chậm một vòng quanh đảo để Quý khách chụp hình.
Chiều: Xe đưa Quý khách ra sân bay Nội Bài, chia tay đoàn và hẹn ngày gặp lại (Chuyến bay cất cánh sau 18h00).
Hồ Ba Bể
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình…
Thuyền thăm quan Hồ Ba Bể.
Khách sạn tiêu chuẩn: có TV, nóng lạnh, điều hoà, 02 người/phòng (lẻ ngủ phòng 03)
Ăn trong chương trình:
Bữa sáng tại khách sạn, nhà hàng
Bữa chính với các món đặc sản địa phương: 150.000đ/xuất
Vé vào cửa một lượt tham quan các điểm theo chương trình.
Nước và khăn trên xe ôtô: 01 chai nước 500ml + 01 khăn lạnh/người/ngày
Hướng dẫn viên chuyên nghiệp, nhiệt tình, chu đáo
Bảo hiểm du lịch mức: 30.000.000 VND

Giá tour không bao gồm
Chi phí cá nhân như: tiền giặt ủi, điện thoại, đồ uống trong các bữa ăn…
Thuế VAT
TIP cho HDV và tài xế
Gía vé xe + thuyền sông Nho Quế tham khảo: 250.000vnđ/khách

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CMND/CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình.
Là tour miền núi, thường đi xe nhỏ nên đề nghị Quý khách không mang hành lý cồng kềnh, quá khổ và không mang nhiều hành lý. Nên mang balo thay vì mang những vali cứng.

Giá tour trẻ em
– Tính theo năm sinh, không tính theo ngày tháng sinh.
Trẻ em dưới 06 tuổi miễn phí dịch vụ, hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 1 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.',
    'https://fiditour.com/wp-content/uploads/2023/10/thank-you-1.png
https://fiditour.com/wp-content/uploads/2023/02/img_20240729221708.jpg
https://fiditour.com/wp-content/uploads/2023/02/Cot-co-Lung-Cu-nhin-tu-cao.jpg
https://fiditour.com/wp-content/uploads/2023/02/chinh-phuc-deo-ma-pi-leng-tu-dai-dinh-deo-cua-vung-nui-dat-bac-6-1642064878.jpeg
https://fiditour.com/wp-content/uploads/2024/01/thac-ban-gioc-1-1525.jpg
https://fiditour.com/wp-content/uploads/2024/01/du-lich-ho-ba-be-1-0932.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/noi-bai-ha-giang-dong-van-thac-ban-gioc-pac-bo-ho-ba-be-5n4d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Khám phá & Trekking' LIMIT 1), 'FDT-9014', 'Sơn La - Điện Biên - Mộc Châu 4N3Đ',
    'TP.HCM', 'Sơn La', '4N3Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 28 DAY) + INTERVAL 7 HOUR,
    3950000, 2962000, 40, 35, 'https://fiditour.com/wp-content/uploads/2022/12/12-1.png',
    'Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh t 8h00 – 9h00), khởi hành đi Sơn La. Ăn trưa tại Hòa Bình. Chiều: Quý khách tiếp tục khởi hành đi Sơn La, ngắm cảnh đẹp yên bình vùng cao Tây Bắc, nhận phòng khách sạn, ăn tối…',
    'Ngày 1: Đón khách – Hòa Bình – Sơn La
Sáng: Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh t 8h00 – 9h00), khởi hành đi Sơn La.
Ăn trưa tại Hòa Bình.
Chiều: Quý khách tiếp tục khởi hành đi Sơn La, ngắm cảnh đẹp yên bình vùng cao Tây Bắc, nhận phòng khách sạn, ăn tối tại nhà hàng.
Tối: Khám phá Sơn La về đêm.
Sơn La

Ngày 2: Sơn La – Mường Phăng -Điện Biên
Sáng: Quý khách thăm quan Nhà tù Sơn La, Cây đào Tô Hiệu, Bảo tàng Sơn La… khởi hành đi Điện Biên, vượt đèo Pha Đin hùng vỹ, ăn trưa tại Mường Phăng.
Chiều: Quý khách tham quan Mường Phăng – Sở chỉ huy chiến dịch Điện Biên Phủ, hầm Đại Tướng Võ Nguyên Giáp, Lê Trọng Tấn….
Tiếp tục khởi hành về Điện Biên, đi tham quan và Viếng Nghĩa trang Liệt Sỹ, Đồi A1, hầm Đờ Cát, sân bay Mường Thanh, Tượng đài Chiến Thắng….nhận phòng khách sạn, ăn tối, nghỉ ngơi.
Điện Biên Phủ

Ngày 3: Điện Biên – Sơn La – Mộc Châu
Sáng: Quý khách ăn sáng, trả phòng khách sạn, lên xe khởi hành về Mộc Châu, nhận phòng khách sạn, ăn trưa tại nhà hàng.
Chiều: Thăm quan Mộc Châu:
Đồi chè Trái tim, có lẽ đây không chỉ là đồi chè đẹp nhất của Cao nguyên Mộc Châu mà còn là đồi chè đẹp nhất của Việt Nam bởi những luống chè xanh mởn tròn trịa và uốn lượn xa ngút tầm mắt đưa đến một cảm giác lãng mạn và bình yên. Đây cũng chính là vùng nguyên liệu để sản xuất ra thương hiệu nổi tiếng chính là Ô Long trà.
Mộc Châu các mùa hoa trái: Tùy vào từng thời điểm, hướng dẫn viên sẽ đưa Quý khách đi chụp hình với những vườn hoa, vườn quả đặc trưng của Mộc Châu. Chắc chắn Quý khách sẽ ngỡ ngàng và ấn tượng trước những vẻ đẹp đầy sức sống và lôi cuốn ấy.
Tối: Quý khách khám phá Mộc Châu về đêm.
Đồi chè trái tim

Ngày 4: Mộc Châu – Hòa Bình – Nội Bài
Sáng: Quý khách ăn sáng, trả phòng khách sạn.
7h00: Qúy khách lên xe về sân bay Nội Bài, ghé thăm Thủy điện Hòa Bình: Bức thư thế kỷ, tượng đài Bác Hồ…tiếp tục về sân bay, ăn trưa tại nhà hàng.
Chiều: Xe đưa Quý khách ra sân bay Nội Bài, chia tay đoàn và hẹn ngày gặp lại.
(Chuyến bay dự kiến 16h30).
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Vận chuyển: Xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình
o Lưu trú: Khách sạn tiêu chuẩn 3 sao. 2 khách người lớn/phòng. Nếu lẻ nam hoặc lẻ nữ sẽ ngủ ghép phòng 3
khách.
o Hướng dẫn viên: Tiếng Việt phục vụ suốt tuyến, vui vẻ, nhiệt tình.
o Các bữa ăn theo chương trình:
• 01 bữa ăn sáng ăn sáng ngày đi.
• Bữa chính: 150.000vnđ/suất.
o Vé vào cửa một lượt tham quan các điểm theo chương trình.
o Nước và khăn trên xe ôtô: 01 chai nước 500ml + 01 khăn lạnh/người/ngày
o Bảo hiểm du lịch mức: 30.000.000 VND

Giá tour không bao gồm
✓ Chi phí cá nhân như: tiền giặt ủi, điện thoại, đồ uống trong các bữa ăn…
✓ Thuế VAT
✓ TIP cho HDV và tài xế
✓ Chi phí giao lưu với người đồng bao dân tộc Thái tại Bản

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CMND/CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình.
Là tour miền núi, thường đi xe nhỏ nên đề nghị Quý khách không mang hành lý cồng kềnh, quá khổ và không mang nhiều hành lý. Nên mang balo thay vì mang những vali cứng.

Giá tour trẻ em
– Tính theo năm sinh, không tính theo ngày tháng sinh.
Trẻ em dưới 06 tuổi miễn phí dịch vụ, hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 1 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.',
    'https://fiditour.com/wp-content/uploads/2024/01/1712716468-untitled-1.jpg
https://fiditour.com/wp-content/uploads/2024/01/3.jpg
https://fiditour.com/wp-content/uploads/2024/01/vi-vu-check-in-doi-che-trai-tim-moc-chau-day-tho-mong-01-1644765643.jpeg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/noi-bai-son-la-dien-bien-moc-chau-4n3d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-8982', 'Hà Nội - Tràng An - Bái Đính - Hạ Long - KDL Yên Tử 5N4Đ',
    'TP.HCM', 'Ninh Bình', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 31 DAY) + INTERVAL 7 HOUR,
    5100000, 3825000, 30, 30, 'https://fiditour.com/wp-content/uploads/2022/12/9-1.png',
    'Buổi sáng, Nhân viên Công ty du lịch sẽ làm thủ tục chuyến bay Sài Gòn – Nội Bài, đến nơi hướng dẫn viên và xe đón đoàn và đưa Quý khách lên cao tốc đến Hạ Long ra bến tàu, lên du thuyền tham quan Vịnh Hạ Long – Đệ nhất thắng cảnh của Bắc…',
    'Ngày 1: SÀI GÒN ✈ NỘI BÀI – HẠ LONG
Buổi sáng, Nhân viên Công ty du lịch sẽ làm thủ tục chuyến bay Sài Gòn – Nội Bài, đến nơi hướng dẫn viên và xe đón đoàn và đưa Quý khách lên cao tốc đến Hạ Long ra bến tàu, lên du thuyền tham quan Vịnh Hạ Long – Đệ nhất thắng cảnh của Bắc Bộ.
Buổi trưa, Qúy khách ăn trưa trên tàu và tiếp tục tham quan động Thiên Cung, đi qua Hòn Chó Đá, Lư Hương, Gà Chọi, tận hưởng vẻ đẹp Vịnh Hạ Long di sản thiên nhiên thế giới với khí hậu trong lành từ trên du thuyền. Với vẻ đẹp như một bức tranh thủy mặc mà Mẹ thiên nhiên đã ban tặng Vịnh Hạ Long cho con người. Sau đó quý khách lên bờ về khách sạn nhận phòng.
Buổi chiều, Đoàn dùng bữa chiều tại nhà hàng.
Buổi tối, Xe đưa Quý Khách vào khu Sunworld Halong tham quan hoặc sử dụng các dịch vụ tại đây: đi cáp treo Nữ Hoàng ngắm Hạ Long – lên Vòng xoay Mặt Trời cao 215m, vườn Nhật, Công Viên Rồng, Công Viên Nước… (chi phí tự túc).
Quý khách nghỉ đêm tại.
Tự do vui chơi mua sắm tại chợ đêm.
Động Thiên Cung

Ngày 2: HẠ LONG – NINH BÌNH – HÀ NỘI
Buổi sáng, ăn sáng tại khách sạn, trả phòng và khởi hành đi Ninh Bình.
Tham quan chùa Bái Đính, một ngôi chùa với Sơn Thủy hòa hợp, một cảnh non thiên hùng vĩ chính nơi đây Vua Lê Thánh Tông đã đến viếng và ban tặng bốn câu thơ:
Đính Sơn danh tiếng thực cao xa
Che chở kinh thành tự thuở xưa
Nhân kiệt, địa linh nên vượng khí
Núi thiêng cảnh đẹp vững sơn hà.
Quý Khách viếng và chiêm bái ngôi chùa chiếm giữ nhiều kỷ lục nhất Đông Nam Á.
Buổi trưa, Qúy khách ăn trưa và tham quan Khu du lịch sinh thái – danh thắng Tràng An (một quần thể núi non, hang động, sông suối được ví như Hạ Long trên cạn).
Qúy khách khởi hành về Hà Nội, xe đưa quý khách dạo quanh bờ hồ Hoàn Kiếm nghe hướng dẫn viên thuyết minh về lịch sử Hồ, Đoàn ăn chiều nhận phòng nghỉ ngơi.
Buổi tối, Quý khách tự do dạo Chợ đêm Phố cổ vào tối thứ 6, 7, chủ nhật, hoặc những trung tâm thương mại lớn như: Royalcity, Timecity, Vincom, Tràng Tiền Plaza…. nghỉ đêm tại Hà Nội.
Tràng An

Ngày 3: HÀ NỘI – LÀO CAI – SAPA
Buổi sáng, ăn sáng tại khách sạn, trả phòng xe đưa Đoàn đi viếng lăng Bác, vườn cây ao cá, nhà sàn Bác Hồ, chùa Một Cột, Hồ Hoàn Kiếm, Đền Ngọc Sơn, Tháp Rùa.
Buổi chiều, khởi hành đi SaPa theo đường cao tốc Nội Bài – Lào Cai. Trên đường Quý khách chiêm ngưỡng vẽ đẹp hùng vĩ của núi rừng Tây Bắc. Đến thành phố Lào Cai quý khách tiếp tục hành trình 38km sẽ đến với Sapa. Quý khách về khách sạn nhận phòng.
Buổi tối, quý khách tự do đi dạo Sapa về đêm, tự túc khám phá ẩm thực vùng núi Tây Bắc: cơm lam, gà nướng, lẩu cá hồi, sashimi cá hồi tươi,…, tham quan nhà thờ Đá, chợ tình Sapa (nếu đúng vào đêm thứ Bảy)
Nghỉ đêm tại Sapa.
Phong Nha - Kẻ Bàng

Ngày 4: SAPA
Buổi sáng, Quý khách ăn sáng tại khách sạn, đoàn di chuyển xe nhỏ xuống bản Cát Cát, nơi sinh sống của đồng bào H’Mông tìm hiểu nghề dệt nhuộm.
Buổi chiều, Qúy khách lên đỉnh Phanxipăng bằng cáp treo ba dây có độ chênh giữa ga đi và ga đến lớn nhất thế giới: 1.410 mét và cáp treo ba dây dài nhất thế giới: 6.292 mét. Sau đó Quý khách lên đỉnh cao 3143m (Chi phí tự túc vé tham khảo cáp treo 850.000vnđ/vé + Xe lửa leo núi 250.000vnđ/vé)
Lưu ý: Qúy khách vui lòng mang theo áo lạnh, mũ len vì trên đỉnh Phanxipang gió lạnh,
quý khách nào bị huyết áp, tim mạch, bệnh đường hô hấp đươc khuyến cáo không nên đi.
Buổi tối, Quý khách khách dùng bữa với lẩu Cá Tầm, Cá Hồi sau đó đi dạo Sapa về đêm, nghỉ đêm tại Sapa.
Đỉnh núi Fansipan

Ngày 5: SAPA – NỘI BÀI ✈ SÀI GÒN
Buổi sáng, Quý khách tự do dạo phố Sapa buổi sớm ngắm các làng sương phủ giăng đồi núi và đi chợ mua thổ sản của người Dân tộc nơi đây.
Quý khách ăn sáng trả phòng, tạm biệt SaPa.
Xe đưa đoàn trở lại Lào Cai, ghé chợ Cốc Lếu mua sắm hàng Trung Quốc. Tham quan chụp ảnh cửa khẩu Hà khẩu Việt Nam – Trung Quốc.
Sau đó Quý khách khởi hành trên Cao Tốc Lào Cai – Hà Nội trở về sân bay Nội Bài khởi hành về Sài Gòn.
Về đến sân bay Tân Sơn Nhất chia tay đoàn hẹn ngày gặp lai.
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình…
Tàu thăm quan vịnh Hạ Long tuyến Thiên Cung- Đầu Gỗ, thuyền thăm KDL Tràng An
Xe điện khứ hồi lên chùa Bái Đính, Khu DL Yên Tử
Vé vào cửa một lượt tham quan các điểm theo chương trình.
Nước và khăn trên xe ôtô: 01 chai nước 500ml + 01 khăn lạnh/người/ngày
Hướng dẫn viên chuyên nghiệp, nhiệt tình, chu đáo
Ăn trong chương trình:
Bữa sáng tại khách sạn, nhà hàng
Bữa chính với các món đặc sản địa phương: 150.000đ/xuất
Khách sạn 3* trong chương trình: 02 người/phòng (trường hợp lẻ ngủ phòng 3)
Hà Nội: Anise, First Eden, Moonview…
Hạ Long: Seastar, Newyork, Bảo Hân…
Bảo hiểm du lịch mức: 30.000.000 VND

Giá tour không bao gồm
Chi phí cá nhân như: tiền giặt ủi, điện thoại, đồ uống trong các bữa ăn…
Thuế VAT
TIP cho HDV và tài xế
Vé cáp treo KDL Yên Tử khứ hồi : 320.000đ/vé.
HDV tiếng Anh hoặc tiếng Hoa phổ thông: 2.100.000đ/tour

Chính sách giá trẻ em
– Tính theo năm sinh, không tính theo ngày tháng sinh.
Trẻ em dưới 06 tuổi miễn phí dịch vụ ( không quá 10% tổng số người lớn), hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 1 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.

Lưu ý
Tuổi tính theo năm sinh. Ví dụ sinh năm 2016 đến nay 2022 tính 06 tuổi.
Yêu cầu cung cấp chiều cao trẻ em nếu tham gia chương trình công viên, một số điểm thăm quan có đo chiều cao khi vào cổng ( vé phải đặt và thanh toán trước 01 ngày)
Giá vé công viên, điểm đo chiều cao dưới 1m: miễn phí
Từ 1m -1,3m tính 75% giá vé
Từ 1,3m trở lên tính như người lớn
Viếng Lăng Bác đóng cửa sáng thứ 2 & thứ 6 hàng tuần',
    'https://fiditour.com/wp-content/uploads/2024/01/1_dong_thien_cung_co_he_thong_nhu_da_voi_an_tuong_b476719f05.jpg
https://fiditour.com/wp-content/uploads/2024/01/khu-du-lich-trang-an-2.webp
https://fiditour.com/wp-content/uploads/2024/01/ttxvnlangc-1589207452-48.jpg
https://fiditour.com/wp-content/uploads/2024/01/depositphotos172648036xl-1733102057419.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-noi-trang-an-bai-dinh-ha-long-kdl-yen-tu-5n4d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-4751', 'TP.HCM - Tiền Giang - Châu Đốc - Cà Mau 2N1Đ',
    'TP.HCM', 'Tiền Giang', '2N1Đ', 'Xe du lịch',
    DATE_ADD(CURDATE(), INTERVAL 34 DAY) + INTERVAL 7 HOUR,
    800000, 600000, 25, 17, 'https://fiditour.com/wp-content/uploads/2022/12/3-19.png',
    '06h30: Quý khách tập trung tại số 98Q Lê Lai, phường Bến Thành, Quận 1, khởi hành bắt đầu đi chuyến du lịch về Miền Tây. Những tỉnh rất trù phú của Đồng Bằng Sông Cửu Long. Đi theo lộ trình đường cao tốc TP/HCM – Trung Lương. Đến Mỹ Tho,…',
    'Ngày 1: TPHCM – Tiền Giang – Bến Tre – Cần Thơ
Sáng: 06h30: Quý khách tập trung tại số 98Q Lê Lai, phường Bến Thành, Quận 1, khởi hành bắt đầu đi chuyến du lịch về Miền Tây. Những tỉnh rất trù phú của Đồng Bằng Sông Cửu Long. Đi theo lộ trình đường cao tốc TP/HCM – Trung Lương.
Đến Mỹ Tho, Qúy khách dừng chân tại trạm Mekong Restop điểm dừng đầu tiên của Tour Miền Tây, đoàn nghỉ ngơi, chụp hình ăn sáng, sau đó đoàn chụp hình tập thể làm kỷ niệm.
Tiếp theo quý khách đến với ngôi chùa Vĩnh Tràng được xây dựng bởi ông bà Bùi Công Đạt vào thế kỉ XIX.
10h30: Xe và HDV đưa quý khách đến bến tàu du lịch Mỹ Tho tham quan cù lao Thới Sơn:
Tham quan trại nuôi Ong và thưởng thức trà mật Ong. Tham quan lò Kẹo Dừa – thưởng thức kẹo dừa truyền thống. Thưởng thức đờn ca tài tử Nam Bộ cùng trái cây miệt vườn theo mùa.
Trải nghiệm xuồng chèo trong rạch dưới 2 hàng dừa nước xanh mát. Trải nghiệm xe ngựa truyền thống dạo quanh đường làng.
Trưa: Xe và HDV đón quý khách di chuyến đến Bến Tre. Tham quan KDL sinh thái Việt Nhật: có trại nuôi cá sấu, nhím, mô hình nuôi Ếch,nuôi ba ba,., có võng nghĩ ngơi và tham quan vườn cây trái, vườn Dừa vá cánh đồng lúa.
Đặc biệt tại đây quý khách có thể tham giam gia chơi các trò chơi hoàn toàn miễn phí như đi xe đạp qua cây cầu, chèo thuyền tại rạch nước, đu dây, đi bộ cầu khỉ và nhiều trò chơi hấp dẫn mới lạ. Quý khách dùng cơm tại nhà hàng và tự do nghỉ ngơi.
Chiều: 14h30: Xe và HDV đưa quý khách khởi hành về lại TP.HCM.
18h00: Đến TP.HCM. Kết thúc hành trình tham quan. HDV thay mặt công ty chia tay và hẹn gặp lại quý khách trong những tour sau.',
    'Giá tour bao gồm
Xe du lịch đạt chuẩn phục vụ suốt tuyến.
Khách sạn trung tâm: 3 đêm tiêu chuẩn 3 sao đầy đủ tiện nghỉ ngủ từ 2-3 khách/phòng.
Ăn chính: 05 bữa ăn tại nhà hàng.
Ăn sáng: 02 bữa sáng tại khách sạn.
Thuyền tham quan Cồn Thới Sơn.
Thuyền tham quan chợ nổi Cái Răng.
Xuồng chèo truyền thống.
Xe ngựa truyền thống.
Áo phao cứu hộ, mỗi người được trang bị 01 cái.
Hướng dẫn viên phục vụ suốt tuyến, nhiệt tình, chu đáo ,chuyên nghiệp.
Thưởng trái cây và đờn ca tài tử.
Quà tặng: Nước suối, khăn lạnh và trái cây, trò chơi dân gian.
Bảo hiểm tai nạn du lịch: 100.000.000 VNĐ/ 01 Người/ 01 trường hợp.

Giá tour không bao gồm
Phụ thu phòng đơn ( phòng 1 người) phụ thu 300,000 vnđ cho khách sạn 3 sao ( 4 – 5 sao báo giá khi đặt tour).
10% VAT. Nếu Qúy khách có yêu cầu xuất hóa đơn đỏ.

Lưu ý
Hành trình có thể thay đổi thứ tự điểm đến tùy vào điều kiện thực tế do lịch trình tham quan trải nghiệm rất dễ bị ảnh hưởng bởi thời tiết nên trường hợp bất khả kháng mong Quý khách hiểu và thông cảm;
Khách sạn có thể ở xa trung tâm thành phố vào các mùa cao điểm.

Giá tour trẻ em
Trẻ em từ 04 đến dưới 10 tuổi mua 75% vé. Ngủ chung bố mẹ. Có chỗ ngồi trên xe, tiêu chuẩn ăn như người lớn.
Trẻ em dưới 04 tuổi: Không tính vé, gia đình tự lo ăn uống, ngồi trên lòng bố mẹ. (02 Người lớn được kèm 01 trẻ em), Kể từ trẻ em thứ 02 trở đi tính bằng 75% giá vé.
Trẻ em từ 11 tuổi giá vé như người lớn.

Quy định huỷ tour
Hủy tour trước 07 ngày so với ngày khởi hành: Phí hủy là 50% chi phí tour.
Huỷ tour trong vòng 07 ngày so với ngày khởi hành: Phí hủy là 100% chi phí tour.
Thời gian hủy tour tính theo ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ.',
    NULL,
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tp-hcm-tien-giang-chau-doc-ca-mau-2n1d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Khám phá & Trekking' LIMIT 1), 'FDT-4710', 'Hà Giang - Đồng Văn - Nho Quế - Sapa - Fansipan 5N4Đ',
    'TP.HCM', 'Hà Giang', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 37 DAY) + INTERVAL 7 HOUR,
    5650000, 4238000, 20, 17, 'https://fiditour.com/wp-content/uploads/2022/12/10-1.png',
    'Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang. Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp hình tại đồi chè Hàm Yên, ngắm dòng sông Lô hùng vĩ. • Đến thành phố Hà Giang, chụp hình kỷ niệm tại Km0…',
    'Ngày 1: Sáng: Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh từ 8h00 – 9h00), khởi hành đi Hà Giang.
Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang.
Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp hình tại đồi chè Hàm Yên, ngắm dòng sông Lô hùng vĩ.
• Đến thành phố Hà Giang, chụp hình kỷ niệm tại Km0 của Hà Giang. Điểm giao nhau của QL2, QL34 và QL4C hay còn gọi là Con đường hạnh phúc.
Tối: Quý khách ăn tối và tự do dạo chơi thăm Hà Giang về đêm.

Ngày 2: Hà Giang – Yên Minh – Đồng Văn – Lũng Cú
Sáng: Quý khách ăn sáng, trả phòng khách sạn.
7h00: Qúy khách lên xe khởi hành đi Cao nguyên đá Đồng Văn – Khám phá vẻ đẹp hoang sơ, hùng vĩ của núi rừng Đông Bắc
Dừng chân tại Cổng Trời Quản Bạ ngắm toàn bộ thị trấn Tam Sơn, xã Quản Bạ, dừng chân thăm & chụp hình lưu niệm tại Núi Đôi (núi Cô Tiên) – một thắng cảnh đẹp nổi tiếng của thị trấn và cũng là một minh chứng về lòng
chung thủy của nhân gian truyền lại từ đời này qua đời khác.
• Tham quan Phố Cáo với những ngôi nhà đặc trưng của người H’mông bởi những hàng rào đá cung quanh nhà.
• Thăm bản Sủng Là thăm ngôi nhà Cổ của người H’mông với tường trình bằng đất – nơi đã được sử dụng
làm bối cảnh để quay bộ phim nhựa “Chuyện của Pao” năm 2006 của đạo diễn Ngô Quang Hải được chuyển thể từ truyện ngắn “Tiếng đàn môi sau bờ rào đá” của nhà văn Đỗ
Bích Thủy đã giành được 4 giải Cánh diều vàng.
Quý khách dừng chân nghỉ ngơi và chụp hình hoa tam giác mạch gần dốc chín khoanh.

Ngày 3: Đồng Văn – Mèo Vạc – Hà Giang – Hà Nội
Sáng: Quý khách ăn sáng và trả phòng khách sạn.
• Qúy khách lên xe khởi hành đi chinh phục đèo Mã Pì Lèng trên đường đi Mèo Vạc, cũng là đoạn đẹp nhất trên con đường mang tên “Đường Hạnh phúc”.
• Chụp hình với vẻ đẹp hùng vĩ của hẻm vực Mã Pì Lèng sâu 800m – nơi địa hình bị chia cắt sâu nhất của Việt Nam.
• Du thuyền trên Sông Nho Quế: Lên thuyền xuôi dòng Nho Quế đến với Hẻm Tu sản, là hẻm vực sâu nhất của Việt Nam nằm trên dòng sông Nho Quế.
• Dòng Nho Quế chảy vào Việt Nam từ địa phận thôn Xéo Lủng, xã Lũng Cú, huyện Đồng Văn đi qua Hẻm núi Tu Sản chạy men theo chân đèo Mã Pì Lèng (Chi phí vé thuyền sông Nho Quế tự túc).
Chiều: Quý khách khởi hành về Hà Nội, ngắm cảnh núi non hùng vĩ Đông Bắc, nhận phòng khách sạn, ăn tối tại nhà hàng.
Tối: Quý khách tự do dạo chơi, ngắm cảnh Hồ Gươm huyền ảo, cổ kính, thăm khu phố cổ Hàng Ngang, Hàng Đào,…

Ngày 4: Hà Nội – Sapa – Fansipan
Sáng: 06h45 Quý khách có mặt tại điểm hẹn, lên xe khởi hành đi Sapa – nơi mà người Pháp xưa gọi là “kinh đô mùa hè của xứ Bắc Kỳ”, chạy theo đường cao tốc Nội Bài – Lào
Cai dài 245Km.
Quý khách có cơ hội ngắm phong cảnh tuyệt đẹp trên cung đường Tây Bắc, dừng chân nghỉ ngơi ,khám phá phong cảnh.
Ăn trưa tại Sapa.
Chiều: Quý khách khởi hành đi tham quan Khu Du lịch Fansipan với hệ thống cáp treo 3 dây hiện đại vừa khánh thành tháng 2/2016. Trải nghiệm cảm giác đi giữa biển mây,
ngắm toàn cảnh Sapa và thung lũng Mường Hoa, vườn quốc gia Hoàng Liên từ trên cao. Viếng chùa Bảo An, vượt gần 600 bậc thang, chinh phục “Nóc nhà Đông Dương” –
đỉnh Fansipan ở độ cao 3,143m (chi phí cáp treo tự túc).
Tối: Dạo chơi Sapa về đêm, tự do thưởng thức các món ăn đặc trưng của người dân tộc thiểu số vùng Tây Bắc: Thắng Cố, cơm lam, lợn cắp nách, khoai nướng, bắp nướng……

Ngày 5: Sa Pa – Cát Cát – Lào Cai – Sân bay Nội Bài
Sáng: Quý khách ăn sáng, khởi hành đi tham quan Bản Cát Cát. Đoàn đi bộ bắt đầu hành trình khám phá bản làng Cát Cát – Sin Chải của người H’Mông – do người Pháp phát
hiện và chọn nơi đây làm khu nghỉ dưỡng cho các quan chức từ đầu thế kỷ XX.
Đến với bản Cát Cát, du khách sẽ được thăm bản làng Cát Cát, trạm thủy điện Cát Cát, thác nước Cát Cát, tìm hiểu văn hóa, phong tục độc đáo của người dân nơi đây với nghề
truyền thống như dệt vải, chạm trổ bạc, rèn nông cụ, tục kéo vợ,…
Quý khách lên xe khởi hành về Lào Cai, nghỉ ngơi, ăn trưa tại nhà hàng.
Chiều: Quý khách thăm quan, mua sắm tại chợ Cốc Lếu, chụp hình lưu niệm tại cửa khẩu Hà Khẩu nơi tiếp giám với Trung Quốc. Quý khách khởi về Hà Nội, ngắm cảnh Tây Bắc hùng vỹ dọc đường.
Tối: Về đến Hà Nội. Xe đưa quý khách vào sân bay Nội Bài HDV làm thủ tục check in cho quý khách về lại Sài Gòn – Chào tạm biệt, kết thúc chương trình. (Chuyến bay 21h00)',
    'Giá tour bao gồm
Vé máy bay và hành lý khứ hồi (10kg xách tay + 23kg kí gửi) SGN/HAN/SGN hãng hàng không Vietnam Airlines
Xe ô tô phục vụ khách du lịch, máy lạnh suốt tuyến, tài xế nhiều năm kinh nghiệm.
Ăn sáng: theo chương trình tour tại khách sạn và nhà hàng.
Ăn Chính: 09 bữa chính, thực đơn phong phú từ 5-6 món/bữa ăn (tùy theo từng chuyến bay công ty du lịch sẽ sắp xếp phù hợp đảm bảo đủ 5 bữa ăn cho quý khách).
Khách sạn 3 sao tiêu chuẩn 2 người/phòng. Trường hợp khách có nhu cầu phòng 3 hoặc 4 sẽ được bố trí theo yêu cầu của khách.
Hà Giang : Hà An/ Cao Nguyên/ Silk River
Đồng Văn : Hoa Cương/ Hoàng Ngọc / Khải Hoàn .
Cao Bằng : Max Boutieque/ Los Angeles / Gia Qúy
Lạng Sơn : Mường Thanh
Quý khách được bao vé tham quan vào cổng Khu Du Lịch các điểm có trong chương trình.
Vui vẻ, nhiệt tình, nhiều kinh nghiệm, nói tiếng việt phục vụ đoàn suốt tuyến.
Nón du lịch, nước suối mỗi ngày.
Quý khách được tham gia bảo hiểm khi đi Du Lịch, mức bồi thường tối đa: 20.000.000 VNĐ/1 trường hợp.

Giá tour không bao gồm
Phụ thu phòng đơn : 1.800.000vnd (cho khách có nhu cầu ngủ riêng 1 người/ phòng)
Chi phí điện thoại cá nhân, ăn uống, vé tham quan ngoài chương trình.
Thuế VAT 8% (cho đến khi có thông báo mới)

Lưu ý
Thứ tự các điểm tham quan trong chương trình có thể thay đổi cho phù hợp với tình hình thực tế. Nhưng không hủy bỏ hoặc thay đổi mà không có sự thỏa thuận với đoàn.
Phụ thu phòng đơn: Trường hợp khách lẻ đi 1 mà ko ngủ ghép đoàn được hoặc khách muốn ở riêng 1 phòng.
Chương trình đi đường đèo dốc quanh co, đi xe nhỏ nên Quý khách vui lòng mang theo hành lý gọn nhẹ.
Trường hợp không đủ khách để khởi hành, quý khách sẽ được yêu cầu dời sang ngày khác.

Giá tour trẻ em
Em bé dưới 02 tuổi 500.000 VNĐ/BÉ bao gồm có thuế phí hàng không, bảo hiểm (Không bao gồm ghế ngồi trên xe) nhưng 2 vợ chồng chỉ được kèm 01 em bé dưới 02 tuổi, nếu bé thứ 02 tính giá trẻ em theo khung từ 2 đến dưới 5 tuổi.
Em Bé từ 02 tuổi đến dưới 05 tuổi: giá tour theo khung giá bên trên (02 vợ chồng được kèm theo 1 Bé, Bé thứ 2 cần mua theo xuất người lớn để đảm bảo chỗ ngủ phù hợp). Tiêu chuẩn Em Bé có ghế ngồi trên xe và ngủ chung với Cha Mẹ. Các chi phí ăn uống tham quan có phát sinh gia đình tự lo cho Bé.
Trẻ em từ 05 tuổi đến dưới 10 tuổi: giá tour theo khung giá bên trên (02 vợ chồng được kèm theo 1 Trẻ, Trẻ Em thứ 2 cần mua theo vé người lớn để đảm bảo chỗ ngủ phù hợp). Tiêu chuẩn Trẻ Em có ghế ngồi trên xe, suất ăn như người lớn, bảo hiểm và ngủ chung với Cha Mẹ.
Từ 10 tuổi trở lên được xem như người lớn.',
    NULL,
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/noi-bai-ha-giang-dong-van-nho-que-sapa-fansipan-5n4d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Khám phá & Trekking' LIMIT 1), 'FDT-4703', 'Hà Giang - Đồng Văn - Nho Quế 4N3Đ',
    'TP.HCM', 'Hà Giang', '4N3Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 40 DAY) + INTERVAL 7 HOUR,
    3550000, 2662000, 35, 30, 'https://fiditour.com/wp-content/uploads/2022/12/11-1.png',
    'Xe và HDV đón Quý khách tại sân bay Nội Bài (chuyến bay hạ cánh từ 8h00 – 9h00), khởi hành đi Hà Giang. Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang. Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp…',
    'Ngày 1: Đón khách – Tuyên Quang – Hà Giang ( Ăn: Trưa, Chiều)
Sáng: Xe và HDV đón Quý khách tại sân bay Nội Bài
(chuyến bay hạ cánh từ 8h00 – 9h00), khởi hành đi Hà Giang.
Quý khách dừng chân nghỉ ngơi và ăn trưa tại Tuyên Quang.
Chiều: Quý khách tiếp tục hành trình đi Hà Giang, dừng chân thăm quan, chụp hình tại đồi chè Hàm Yên, ngắm dòng sông Lô hùng vĩ.
Đến thành phố Hà Giang, chụp hình kỷ niệm tại Km0 của Hà Giang. Điểm giao nhau của QL2, QL34 và QL4C hay còn gọi là Con đường hạnh phúc.
Tối: Quý khách ăn tối và tự do dạo chơi thăm Hà Giang
Đồi chè Hàm Yên

Ngày 2: Hà Giang – Yên Minh – Đồng Văn – Lũng Cú
Sáng: Quý khách ăn sáng, trả phòng khách sạn.
7h00: Qúy khách lên xe khởi hành đi Cao nguyên đá Đồng Văn – Khám phá vẻ đẹp hoang sơ, hùng vĩ của núi rừng Đông Bắc
Dừng chân tại Cổng Trời Quản Bạ ngắm toàn bộ thị trấn Tam Sơn, xã Quản Bạ, dừng chân thăm & chụp hình lưu niệm tại Núi Đôi (núi Cô Tiên) – một thắng cảnh đẹp nổi tiếng của thị trấn và cũng là một minh chứng về lòng chung thủy của nhân gian truyền lại từ đời này qua đời khác.
• Tham quan Phố Cáo với những ngôi nhà đặc trưng của người H’mông bởi những hàng rào đá cung quanh nhà.
• Thăm bản Sủng Là thăm ngôi nhà Cổ của người
H’mông với tường trình bằng đất – nơi đã được sử dụng làm bối cảnh để quay bộ phim nhựa “Chuyện của Pao” năm 2006 của đạo diễn Ngô Quang Hải được chuyển thể từ truyện ngắn “Tiếng đàn môi sau bờ rào đá” của nhà văn Đỗ Bích Thủy đã giành được 4 giải Cánh diều vàng.
Quý khách dừng chân nghỉ ngơi và chụp hình hoa tam giác mạch gần dốc chín khoanh.
Phố Cáo

Ngày 3: Hà Giang – Yên Minh – Đồng Văn – Lũng Cú
Chiều: Thăm Cột Cờ Lũng Cú – nơi địa đầu Tổ quốc, điểm có vĩ độ cao nhất trên bản đồ của Việt Nam.
Dinh Vua Mèo – Vương Chính Đức nằm trong một thung lũng của xã Sà Phìn, đây là dòng họ giàu có và quyền uy nhất Châu Đồng Văn vào đầu thế kỷ 20.
Tối: Quý khách tự do khám phá Đồng Văn về đêm.
Cột cờ Lủng Cú

Ngày 4: Đồng Văn – Mèo Vạc – Hà Giang – Hà Nội
Sáng: Quý khách ăn sáng và trả phòng khách sạn.
• Qúy khách lên xe khởi hành đi chinh phục đèo Mã Pì Lèng trên đường đi Mèo Vạc, cũng là đoạn đẹp nhất trên con đường mang tên “Đường Hạnh phúc”.
• Chụp hình với vẻ đẹp hùng vĩ của hẻm vực Mã Pì Lèng sâu 800m – nơi địa hình bị chia cắt sâu nhất của Việt Nam.
• Du thuyền trên Sông Nho Quế: Lên thuyền xuôi dòng Nho Quế đến với Hẻm Tu sản, là hẻm vực sâu nhất của Việt Nam nằm trên dòng sông Nho Quế.
• Dòng Nho Quế chảy vào Việt Nam từ địa phận thôn Xéo Lủng, xã Lũng Cú, huyện Đồng Văn đi qua Hẻm núi Tu Sản chạy men theo chân đèo Mã Pì Lèng (Chi phí vé thuyền sông Nho Quế tự túc).
Đèo Mã Pí Lèng
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
o Vận chuyển: Xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình
o Lưu trú: Khách sạn tiêu chuẩn 3 sao. 2 khách người lớn/phòng. Nếu lẻ nam hoặc lẻ nữ sẽ ngủ ghép phòng 3 khách.
o Hướng dẫn viên: Tiếng Việt phục vụ suốt tuyến, vui vẻ, nhiệt tình.
o Các bữa ăn theo chương trình:
• 03 bữa ăn sáng.
• Bữa chính: 150.000vnđ/suất.
o Vé vào cửa một lượt tham quan các điểm theo chương trình.
o Nước và khăn trên xe ôtô: 01 chai nước 500ml + 01 khăn lạnh/người/ngày
o Bảo hiểm du lịch mức: 30.000.000 VND

Giá tour không bao gồm
✓ Chi phí cá nhân như: tiền giặt ủi, điện thoại, đồ uống trong các bữa ăn…
✓ Thuế VAT
✓ TIP cho HDV và tài xế
✓ Gía vé xe + thuyền sông Nho Quế tham khảo: 250.000vnđ/khách

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CMND/CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình.
Là tour miền núi, thường đi xe nhỏ nên đề nghị Quý khách không mang hành lý cồng kềnh, quá khổ và không mang nhiều hành lý. Nên mang balo thay vì mang những vali cứng.

Giá tour trẻ em
Trẻ em dưới 06 tuổi miễn phí dịch vụ, hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 01 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.',
    'https://fiditour.com/wp-content/uploads/2023/02/img_20240729221708.jpg
https://fiditour.com/wp-content/uploads/2023/02/pho-cao-1-1424.jpg
https://fiditour.com/wp-content/uploads/2023/02/Cot-co-Lung-Cu-nhin-tu-cao.jpg
https://fiditour.com/wp-content/uploads/2023/02/chinh-phuc-deo-ma-pi-leng-tu-dai-dinh-deo-cua-vung-nui-dat-bac-6-1642064878.jpeg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/noi-bai-ha-giang-dong-van-nho-que-4n3d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Nghỉ dưỡng biển đảo' LIMIT 1), 'FDT-3499', 'Quy Nhơn 3N2Đ',
    'TP.HCM', 'Quy Nhơn', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 43 DAY) + INTERVAL 7 HOUR,
    2990000, 2242000, 40, 33, 'https://fiditour.com/wp-content/uploads/2022/12/6-6.png',
    'Xe và HDV đón Quý khách tại sân bay. Quý khách di chuyển về Quy Nhơn. Bắt đầu chuyến tham Tháp Đôi – Cụm tháp với 02 ngọn tháp cổ có lối kiến trúc Angkor, được xây dựng từ thế kỷ thứ XII nằm trên bình diện phẳng ngay trong lòng thành phố…',
    'Ngày 1: City Quy Nhơn
Sáng: Xe và HDV đón Quý khách tại sân bay.
Quý khách di chuyển về Quy Nhơn. Bắt đầu chuyến tham Tháp Đôi – Cụm tháp với 02 ngọn tháp cổ có lối kiến trúc Angkor, được xây dựng từ thế kỷ thứ XII nằm trên bình diện phẳng ngay trong lòng thành phố Quy Nhơn.
Thăm quan KDL Ghềnh Ráng Tiên Sa – “Dốc Mộng Cầm, Đồi Thi Nhân”, viếng mộ “Hàn Mặc Tử”, “Bãi tắm Hoàng Hậu – Bãi Trứng”. Quý khách được nghe thuyết minh về cuộc đời sự nghiệp tài hoa của thi sỹ “Hàn Mặc Tử” – Một
của đời ngắn ngủi như đã kịp lóe sáng trên nền trời thơ ca Việt Nam và sống mãi trong lòng công chúng yêu thơ Hàn. Thưởng thức tài nghệ “bút lửa Dũ Kha” và cùng chia sẻ niềm đam mê thơ Hàn.
Trưa: Ăn trưa tại nhà hàng.
Sau bữa trưa, đoàn nhận phòng khách sạn nghỉ ngơi. Chiều tự do tắm biển, nghỉ ngơi.
Tối: Xe và HDV đưa quý khách ăn bữa tối tại nhà hàng. Nghỉ đêm tại Quy Nhơn.

Ngày 2: Khám phá đảo Hòn Khô – Kỳ Co – Lặn Ngắm San Hô – Eo Gió
Sáng: Quý khách ăn sáng tại khách sạn.
Sau đó, xe và HDV đón quý khách khởi hành đi “Nhơn Hải”, để khám phá “Hòn Khô – Kỳ Co”.
Vượt “cầu Thị Nại” – cây cầu vượt biển dài đầu tiên tại Việt Nam với chiều dài gần 2,5km. Tại đây Quý Khách có thể dừng chân, ngắm những tia nắng vàng chiếu trên “Đầm Thị Nại”, và nghe kể về những trận thủy chiến bi tráng giữa Champa và Đại Việt, giữa Tây Sơn và nhà Nguyễn (Nguyễn Ánh) trong suốt 5 thế kỷ.
Đến bến tàu Nhơn Hải, Quý khách lên cano siêu tốc qua “Bãi tắm Kỳ Co” – Một bãi tắm còn hoang sơ, trong sạch.
Tại đây, quý khách có thể tận mắt chứng kiến một cảnh đẹp thiên nhiên tuyệt đẹp, làm say đắm biết bao lòng người. Với màu nước trong xanh, bãi cát trắng dài và mịn, những cơn sóng biển êm ái chính là điểm đến lý tưởng thu hút nhiều du khách trong thời gian gần đây.
Sau đó, Quý khách lên lại Cano đến “Bãi San Hô” (Bãi Dứa) lặn ngắm san hô tự nhiên và hàng trăm loài cá đầy màu sắc tung tăng bơi lội.
Trưa: Tại bãi ngắm san hô Quý khách có thể tham gia một số hoạt động trò chơi như: “Phao chuối – Thuyền thúng đáy kính – Moto nước siêu tốc” (chi phí tự túc).
Quý khách dùng bữa trưa với các món Hải sản tươi sống. Sau bữa trưa, quý khách nghỉ ngơi thư giản tại nhà hàng.

Ngày 3: Quy Nhơn – Mua Sắm – Tiễn Sân Bay Phù Cát ( Ăn sáng , trưa )
Sáng: Quý khách ăn sáng tại khách sạn. Sau đó xe và HDV chở Qúy khách đi mua sắm đặc sản làm quà cho người thân và bạn bè: bánh ít lá gai, thịt bò khô, hải sản khô chế biến: mực ngào,…
Quý khách ăn trưa tại nhà hàng.
Đến giờ, Xe và HDV quý khách ra Sân bay Phù Cát, Quý khách đáp chuyến bay về lại điểm ban đầu. HDV Chào tạm biệt & hẹn gặp lại Quý khách!',
    'Giá tour bao gồm
Xe vận chuyển chất lượng tốt phục vụ theo chương trình. Đón tại Sân Bay/Trung tâm
thành phố Quy Nhơn
Hướng dẫn viên kinh nghiệm phục vụ suốt tuyến
04 bữa ăn chính có trong chương trình tiêu chuẩn 150.000đ/khách (uống trà đá) + 01
bữa full hải sản tại Nhơn Lí 180.000đ/ suất
02 bữa ăn sáng – tại khách sạn theo tiêu chuẩn
Ngủ 2 đêm khách sạn 3*: 02 khách/01Phòng (lẻ nam, nữ ngủ phòng 3).
Vé vào cổng 01 lần các điểm tham quan có trong chương trình.
Cano cao tốc sang đảo Kỳ Co; dụng cụ lặn ngắm san hô: Áo phao, kính lặn, tắm nước
ngọt
Phí vào đảo Kỳ Co
Phí du lịch an ninh biển đảo
Nước uống 0.5l/người/ngày, khăn lạnh
Bảo hiểm du lịch mức bồi thường tối đa 30.000.000vnđ/trường hợp

Giá tour không bao gồm
Phương tiện vận chuyển: Hà Nội/Tp.HCM– Quy Nhơn –Hà Nội/Tp.HCM
Nước uống trong các bữa ăn và chi phí ăn uống khác ngoài chương trình.
Phụ thu phòng đơn
Ăn sáng ngày đầu đến Quy Nhơn (50.000đ/suất)
Hóa đơn VAT

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport).
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình.
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại.
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá tour trẻ em
Trẻ em dưới 4 tuổi không tính giá tour; cha mẹ tự túc các chi phí (nếu có).
Trẻ em từ 5 – 7 tuổi tính 50% giá tour, Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ em từ 8-10 tuổi tính 70% giá tour. Có chỗ ngồi trên xe ngủ chung giường với bố
mẹ.
Trẻ từ 11 tuổi bằng giá người lớn. Ngủ giường riêng

Lưu ý:
Chương trình phụ thuộc vào thời tiết. Trường hợp không di chuyển Cano ra đảo,
chương trình sẽ khởi hành bằng đường bộ và không lặn ngắm san hô.
Thứ tự các điểm tham quan trong chương trình có thể thay đổi cho phù hợp với thời
gian hành trình. Tuy nhiên công ty vẫn đảm bảo các chương trình tuyến điểm cho quý
khách.
Giá tour không áp dụng các ngày lễ, tết
Giá tạm tính có thể thay đổi khi chi phí đầu vào như xăng dầu, giá vé tham quan, thực
phẩm,… thay đổi và sẽ được báo trước với đối tác, chậm nhất khi liên hệ.
Tùy thuộc vào đường bay và giờ bay của khách cty sẽ thiết kế chương trình tour sao
cho hợp lý và tối ưu nhất
Chương trình đón tiễn tại sân bay hoặc nhà ga Quy Nhơn buổi sáng từ 8h00 – 10h00,
tiễn các chuyến bay buổi chiều từ 15h00 – 17h00 ( phụ thu thêm chi phí tùy theo nhóm
khách)',
    NULL,
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/quy-nhon-3n2d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-3492', 'Đà Nẵng - Sơn Trà - Bảo Tàng Phật Học - Rừng Dừa Bảy Mẫu - Phố Cổ Hội An - Bà Nà Núi Chúa 3N2Đ',
    'TP.HCM', 'Đà Nẵng', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 46 DAY) + INTERVAL 7 HOUR,
    3350000, 2512000, 30, 30, 'https://fiditour.com/wp-content/uploads/2024/01/2.png',
    'Đón quý khách tại Đà Nẵng (Sân bay, Ga, điểm hẹn trung tâm) từ 07h00 đến 12h00 (Sau thời gian này, quý khách tự túc nhập đoàn hoặc book xe đón). Xe đưa đi ăn trưa đặc sản nổi tiếng Đà Nẵng “Bánh tráng thịt heo 2 đầu da & Mỳ Quảng”.Nhận…',
    'Ngày 1: Đón khách – Bán đảo sơn trà – Biển Mỹ Khê
Sáng: Đón quý khách tại Đà Nẵng (Sân bay, Ga, điểm hẹn trung tâm) từ 07h00 đến 12h00 (Sau thời gian này, quý khách tự túc nhập đoàn hoặc book xe đón). Xe đưa đi ăn trưa đặc sản nổi tiếng Đà Nẵng “Bánh tráng thịt heo 2 đầu da & Mỳ Quảng”.Nhận phòng Khách sạn 3* nghỉ ngơi.
Chiều: Lên Bán Đảo Sơn Trà mục kích phố biển Đà Nẵng trên cao, viếng Linh Ứng Tự – nơi có tượng Phật Bà 67m cao nhất Việt Nam và tắm biển Mỹ Khê Đà Nẵng – được tạp chí Forbes bình chọn là bãi biển quyến rũ nhất hành tinh năm 2006.
Tối: Ăn tối nhà hàng.
Tự do thưởng ngoạn du thuyền trên sông Hàn ngắm cảnh Đà Thành về đêm, chụp ảnh Cầu Quay Sông Hàn, cầu Rồng phun lửa và nước vào cuối tuần.
Chùa Linh Ứng

Ngày 2: Bảo tàng Phật học – Rừng dừa Bảy Mẫu – Phố cổ Hội An
Sáng: Dùng điểm tâm tại khách sạn.
Vòng qua Cầu Rồng lưu lại dấu ấn trên Cầu Tình Yêu, tản bộ thưởng thức không khí trong lành bên bờ Hàn Giang với tượng Cá Chép Hóa Long – Biểu tượng mong muốn vươn lên của người Đà Nẵng.
Tham quan Bảo Tàng Phật Học – Bảo tàng văn hóa Phật giáo đầu tiên ở Việt Nam, Chùa Quan Thế Âm – tọa lạc tại chân núi Kim Sơn, một trong năm ngọn Ngũ Hành Sơn và Làng Nghề Điêu Khắc Đá. Mua sắm đặc sản Qùa Miền
Trung.
Trưa: Ăn trưa nhà hàng.
Chiều: Quý khách khởi hành vào Hội An tham quan Rừng Dừa Bảy Mẫu. Khách đi bộ dọc theo con đường làng 5 phút đến bến thuyền.
Quý khách được trải nghiệm di chuyển trên những chiếc thuyền thúng – một phương tiện đặc trưng của làng chài thôn Vạn Lăng, xem màn lắc thúng chém nước đặc sắc của nghệ nhân lắc thúng của thôn Vạn Lăng.
Quý khách khởi hành vào Phố cổ Hội An bách bộ tham quan và mua sắm với: Chùa Cầu Nhật Bản, Nhà Cổ hàng trăm năm tuổi, Hội Quán Phước Kiến & Xưởng thủ công mỹ nghệ. Quý khách dạo quanh phố cổ về đêm, những chiếc đèn lồng sáng rực trong đêm càng khiến nơi đây trở nên thơ mộng.
Tối: Ăn tối nhà hàng tại Hội An với món Cao lầu trứ danh Phố Hội. Khởi hành về lại Đà Nẵng trên “tuyến đường 5 sao” Võ Nguyên Giáp, quý khách tự do nghỉ ngơi và khám phá thành phố Đà Nẵng về đêm.
Chùa Quan Thế Âm

Ngày 3: Bà Nà Núi Chúa – Chùa Thiên Mụ – Ca
Huế sông Hương (Ăn sáng, trưa option, tối)
Sáng: Dùng điểm tâm tại khách sạn. Trả phòng.
Khởi hành đi Bà Nà – Núi Chúa (Tự túc chi phí Option Bà Nà theo giá của Sun Group), nơi có những khoảnh khoắc giao mùa bất ngờ Xuân – Hạ – Thu – Đông trong một ngày.
Qúy khách sẽ tận hưởng cảm giác bồng bền khi ngồi trên Cabin lơ lững giữa chừng mây. Viếng chùa Linh Ứng với tượng Phật Thích Ca cao 27m, viếng đền thờ Bà Chúa Mẫu Thượng Ngàn.
Tham quan Cầu Vàng – Cây cầu độc đáo nằm trong vườn Thiên Thai ở Bà Nà Hill – được xây dựng trên độ cao 1.400m so với mặt nước biển, cây cầu gồm 8 nhịp và có độ dài là 150m. Cây cầu được nâng đỡ bởi đôi bàn tay khổng lồ. Người đi như lạc giữa tiên cảnh nơi có mây, trời
bao la.
Tham gia vui chơi tại công viên Fantasy Park: với các trò chơi phiêu lưu mới lạ như: Vòng Quay Tình Yêu, Phi Công Skiver, Đường Đua Lửa, Ngôi Nhà Ma và Khu trưng bày hơn 40 tượng sáp những nhân vật nổi tiếng trên thế giới…
Trưa: Ăn trưa Option Buffet tại Bà Nà (Nếu quý khách không đăng ký đi hoặc không ăn buffet Bà Nà thì tự túc chi phí ăn trưa và nhập đoàn)
Chiều: Quý khách tiếp tục vui chơi tại Bà Nà. Xe tiễn quý khách ra sân bay Đà Nẵng (các chuyến sau 18h00). Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách!
Bà Nà Núi Chúa
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Giá tour bao gồm:
o Vận chuyển: 01 xe vận chuyển máy lạnh đời mới, hiện đại, lái xe thân thiện, nhiệt tình
o Lưu trú: Tiêu chuẩn 3 sao. 2 khách người lớn/phòng. Nếu lẻ nam hoặc lẻ nữ sẽ ngủ ghép phòng 3 khách.
• Khách sạn 3* Đà Nẵng: Tuyết Sơn, Richico hotel & Apartment, Bantique, Soco, …
o Hướng dẫn viên: Tiếng Việt phục vụ suốt tuyến, vui vẻ, nhiệt tình.
o Các bữa ăn theo chương trình:
• 02 bữa ăn sáng Buffet
• Bữa chính: 130.000vnđ/suất.
o Vé các điểm tham quan.
o Thuyền thúng tham quan Rừng dừa Bảy Mẫu
o Phục vụ 02 chai nước suối Dasani 500ml/khách /ngày.
o Bảo hiểm du lịch: 30.000.000 VNĐ/vụ

Giá tour không bao gồm
✓ Vé máy bay khứ hồi.
✓ Chi phí cá nhân, uống tự gọi trong các bữa ăn,.. và tham quan vận chuyển ngoài chương trình.
✓ Combo Vé cáp treo Bà Nà & Ăn Buffet tại Bà Nà (tùy thuộc theo giá công bố của tập đoàn Sun Group.)
✓ Vé du thuyền Sông Hàn.
✓ Tip cho Hướng dẫn viên và tài xế

Lưu ý
Quý khách phải mang theo: giấy tờ tùy thân hợp pháp (CCCD hoặc Passport)
Quý khách nên mang theo: thuốc chống côn trùng, thuốc cảm sốt thông thường hoặc các thuốc đã được kê đơn riêng theo chỉ định của bác sĩ.
Quý khách là người ăn chay vui lòng mang thêm đồ ăn chay theo để đảm bảo khẩu vị của mình
Bất cứ dịch vụ nào trong tour nếu Quý khách không sử dụng cũng không được hoàn lại
Hướng dẫn viên có quyền sắp xếp lại thứ tự các điểm tham quan cho phù hợp điều kiện từng ngày khởi hành cụ thể nhưng vẫn đảm bảo tất cả các điểm tham quan trong chương trình

Giá vé tour trẻ em:
Trẻ em dưới 5 tuổi: miễn phí, cha mẹ tự lo các chi phí phát sinh (nếu có).
Trẻ em từ 5 – dưới 10 tuổi: 50% giá tour, ngủ chung với cha mẹ.
Trẻ em từ 10 tuổi trở lên: bằng vé nguời lớn.
02 người lớn được kèm 01 trẻ em dưới 05 tuổi. Từ trẻ thứ 02 trở lên, quý khách vui lòng trả 50% giá vé người lớn.
Tiêu chuẩn 50% vé: được 1 suất ăn + 1 ghế ngồi trên xe và ngủ chung giường với bố mẹ.
GIÁ VÉ MÁY BAY TRẺ EM: Theo qui định riêng của từng hãng hàng không
Trẻ em dưới 2 tuổi: 10% giá vé máy bay.
Trẻ em từ 2 – dưới 12 tuổi: 90% giá vé máy bay (Vietnam Airlines); 100% giá vé máy bay (Vietjet Air).
Trẻ em từ 12 tuổi trở lên: 100% giá vé máy bay',
    'https://fiditour.com/wp-content/uploads/2024/06/unnamed.jpg
https://fiditour.com/wp-content/uploads/2022/12/ve-dep-tam-linh-chua-quan-the-am-da-nang-20240929145230110.jpg
https://fiditour.com/wp-content/uploads/2024/01/le-hoi-carnival-ba-na-hill-da-nang-3.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/da-nang-son-tra-bao-tang-phat-hoc-rung-dua-bay-mau-pho-co-hoi-an-ba-na-nui-chua-3n2d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Nghỉ dưỡng biển đảo' LIMIT 1), 'FDT-3456', 'Phú Quốc 3N2Đ',
    'TP.HCM', 'Phú Quốc', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 49 DAY) + INTERVAL 7 HOUR,
    6690000, 5018000, 25, 25, 'https://fiditour.com/wp-content/uploads/2022/12/1-16.png',
    'Buổi sáng 7h45: HDV hỗ trợ quý khách làm thủ tục check in tại sân bay Tân Sơn Nhất, khởi hành đi Phú Quốc chuyến bay VJ325 lúc 9h55. 11h00: Quý khách đến Phú Quốc, tài xế và hướng dẫn viên đón tại sân bay Quốc tế Phú Quốc. Đưa quý khách…',
    'Ngày 1: TP HỒ CHÍ MINH – PHÚ QUỐC GRAND WOLD ( ĂN SÁNG-TRƯA-TỐI)
Buổi sáng 7h45: HDV hỗ trợ quý khách làm thủ tục check in tại sân bay Tân Sơn Nhất, khởi hành đi Phú Quốc chuyến bay VJ325 lúc 9h55.
11h00: Quý khách đến Phú Quốc, tài xế và hướng dẫn viên đón tại sân bay Quốc tế Phú Quốc. Đưa quý khách tham quan:
Dinh Cậu, Dinh Bà: Tham quan danh thắng tâm linh với cảnh biển hùng vĩ.
Trưa: Thưởng thức bữa trưa với ẩm thực địa phương. Nhận phòng khách sạn và nghỉ ngơi (nhận phòng từ 14h00, hỗ trợ sớm nếu có phòng trống).
Chiều: Tiếp tục tham quan:
Tượng Đài Bác Hồ: Cao 20,7m, trong đó thân tượng cao 18m, đế tượng cao 0,3m và bệ tượng cao 2,4m, được tạo bằng hợp kim đồng nặng hơn 93 tấn. Có chủ đề “Miền Nam trong trái tim tôi” mang ý nghĩa chính trị, biểu tượng về văn hóa, góp phần khẳng định chủ quyền biển, đảo của Việt Nam.
Khám phá Grand World – Thành phố không ngủ (Không tính phí vào cổng – Chi phí vui chơi tự túc)
Tọa lạc tại vị trí trung tâm Phú Quốc United Center, diện tích lên đến 85ha với kiến trúc cảnh quan rực rỡ lấy cảm hứng từ châu Âu. Được xây dựng lộng lẫy tại 4 tiểu khu: Quảng trường, Shanghai, Indochine, Mallorca.
Ngược dòng lịch sử với show “Tinh Hoa Việt Nam” : Show diễn thực cảnh ấn tượng, diễn ra hàng ngày lúc 20h15 (chi phí vé tự túc).
Tận hưởng cảm hứng Châu Âu qua show diễn Sắc màu Venice: Show diễn miễn phí, tái hiện câu chuyện tình yêu lãng mạn trong không gian Châu Âu.
Tối: Thưởng thức bữa tối đặc sản Bún Quậy Phú Quốc, sau đó xe đón khách:
Kết thúc ngày 1, quý khách nghỉ đêm tại khách sạn.
Option thêm: Tham quan công viên chủ đề Vinwonders & vườn thú VinSafari (chi phí tự túc)
Vườn thú Vinpearl Safari Phú Quốc là công viên sở thú hoang dã đầu tiên tại Việt Nam. Tại đây, du khách sẽ được trải nghiệm mô hình sở thú có 1-0-2, check-in sống ảo cùng các loài động vật quý hiếm hay chiêm ngưỡng những màn biểu diễn đỉnh cao
Công viên chủ đề VinWonders Phú Quốc là công viên chủ đề với hơn 100 trò chơi hấp dẫn với những trải nghiệm hấp dẫn với diện tích siêu khủng lên tới gần 50ha với 6 phân khu chủ đề đặc sắc lần đầu tiên xuất hiện tại Việt Nam.
Khu cảm giác mạnh – Thế giới phiêu lưu
Khu công viên nước – Thế giới lốc xoáy
Khu lâu đài trung tâm – Châu Âu trung cổ
Khu cổ tích – Thế giới diệu kỳ
Khu Viking – Ngôi làng bí mật
Cung điện hải vương
Dinh Cậu Dinh Bà

Ngày 2: CHECK-IN NAM ĐẢO PHÚ QUỐC ( ĂN SÁNG – TRƯA – TỐI )
Sáng: : Sau bữa sáng tại khách sạn, HDV và xe đón khách tham quan Nam Đảo:
Cơ sở nuôi cấy Ngọc Trai: Khám phá quá trình nuôi trai lấy ngọc và quan sát trực tiếp quy trình mổ trai. Quý khách có thể mua trang sức ngọc trai làm quà lưu niệm.
Chương trình Tàu câu cá– lặn ngắm san hô: Khởi hành từ cảng biển, trải nghiệm câu cá và lặn ngắm san hô với đầy đủ trang thiết bị.
Trưa: Thưởng thức bữa trưa trên tàu với chiến lợi phẩm vừa câu được.
Chiều: Tàu đưa quý khách trở lại đất liền, tiếp tục tham quan:
Hái lộc đầu năm tại Chùa Hộ Quốc: (Thiền Viện Trúc Lâm Hộ Quốc), đây cũng là một địa điểm tham quan tâm linh mới của Phú Quốc.
Cơ sở sản xuất nước mắm: Khám phá làng nghề truyền thống làm nên thương hiệu nước mắm Phú Quốc nổi tiếng thế giới.
Thị Trấn Hoàng Hôn: Địa điểm du lịch hàng đầu tại Phú Quốc, mang đậm phong cách Địa Trung Hải với các biểu tượng nổi bật như Cáp treo Hòn Thơm, Cầu Hôn, Tháp Đồng Hồ,…
*Option: Khách có thể lựa chọn ở lại xem show và tự túc di chuyển về sau, hoặc phát sinh thêm 100.000 đồng/khách khi dùng xe buyt của Sunwold.
Tối: Ăn tối tại nhà hàng thưởng thức ẩm thực địa phương, sau đó quý khách tự do khám phá Phú Quốc về đêm. Quý khách nghĩ đêm tại khách sạn.
Lưu ý: Quý khách có thể chọn lịch trình thay thế:
Option: Tour Cano Tham quan 4 Đảo (chi phí tự túc)
Lịch trình bao gồm:
8h00: Đón khách tại khách sạn, tham quan cơ sở nuôi cấy ngọc trai. Tham quan cơ sở nuôi cấy ngọc trai
Hòn Mây Rút: Check-in và tham quan.
Hòn Gầm Ghì: Bơi ngắm san hô miễn phí.
Hòn Rõi: Trải nghiệm công viên san hô đi bộ dưới đáy biển (chi phí tự túc).
Hòn Móng Tay: Ăn trưa, tắm biển, nghỉ ngơi, chụp ảnh, quay flycam (miễn phí).
Trở về khách sạn.
( Nếu quý khách chọn gói bao gồm thêm Cáp treo thì chương trình vẫn tiếp tục. Nếu quý khách không chọn gói Cáp treo, chương trình sẽ kết thúc, cano đưa quý khách về lại cảng. Tuỳ vào thời tiết các hòn đảo sẽ được linh động nhưng vẫn đảm bảo đủ 4 đảo đẹp nhất.)
Kết thúc ngày 2, quý khách nghỉ đêm tại khách sạn.
Hòn Mây Rút

Ngày 3: PHÚ QUỐC – HẸN GẶP LẠI! ( ĂN SÁNG – TRƯA )
Sáng: Quý khách thưởng thức bữa sáng tại khách sạn. Tự do tham quan và nghỉ ngơi tại khách sạn.
Gợi ý những hoạt động ( tự túc di chuyển ):
Đi chợ hải sản Dương Đông
Check-in và thưởng thức cà phê với view đồi núi và toàn cảnh thành phố đảo Ngọc
Mua sắm đặc sản
Dạo chơi, tắm biển
11h00: Quý khách Trả phòng xe và HDV đưa quý khách dùng cơm trưa tại nhà hàng.
Sau đó xe và HDV đưa tham quan và mua sắm tại Phú Quốc:
Cơ sở sản xuất Rượu Sim (loại vang riêng của đảo): Khám phá đặc sản vang Sim với hương vị độc đáo và tìm hiểu quy trình sản xuất. Quý khách có thể mua quà tặng người thân.
Vườn Tiêu Phú Quốc: Điểm check-in lý tưởng với hương vị tiêu cay nồng, nổi tiếng cả nước.
14h30: Quý khách di chuyển ra sân bay làm thủ tục về lại Hồ Chí Minh chuyến bay VJ1234 lúc 16h30 ( Mùng 4 tết) và VJ320 lúc 17h35 ( Mùng 5 tết). Gửi lời chào tạm biệt và hẹn gặp lại Quý khách trong những chuyến đi gần nhất.
Chia tay đoàn, cảm ơn và hẹn gặp lại quý khách!
Cơ sở sản xuất Rượu Sim
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
Phương tiện: Xe ô tô du lịch hiện đại, điều hòa, đời mới, phục vụ đưa đón theo chương trình.
Lưu trú: Khách sạn/resort với phòng tiện nghi, điều hòa, tivi, nóng lạnh khép kín. Tiêu chuẩn 2 người/phòng. Trường hợp lẻ nam hoặc nữ, sẽ ngủ ghép 3 người/phòng.
Hoạt động: Tàu câu cá và lặn ngắm san hô (bao gồm ống câu, áo phao,…).
Bữa ăn:
02 bữa sáng tại khách sạn (theo gói phòng
03 bữa chính cho chương trình 3N2Đ tại nhà hàng, định mức 150.000 đồng/người/bữa.
01 bữa ăn trên tàu câu cá.
01 bữa tối bún quậy ngày 1.
Vé máy bay khứ hồi Hồ Chí Minh- Phú Quốc- Hồ Chí Minh ( Bao gồm 7 kg hành lý xách tay, chưa bao gồm hành lý ký gửi)
Hướng dẫn viên: HDV nhiệt tình, kinh nghiệm, am hiểu kiến thức tuyến điểm phục vụ đoàn.
Nước uống, khăn lạnh: Mỗi ngày 01 chai nước và 01 khăn lạnh.
Bảo hiểm du lịch: Mức bảo hiểm cao nhất 30.000.000 đồng/người/vụ.

Giá tour không bao gồm
Thuế VAT.
Chi phí cá nhân: Chi phí ngủ phòng đơn và các chi phí ngoài chương trình.
Bảng giá vé tham khảo tham quan ngoài chương trình:
VinWonders: 950.000đ/vé người lớn – 710.000đ/vé trẻ em.
Safari: 650.000đ/vé người lớn – 490.000đ/vé trẻ em.
Combo VinWonders & Safari: 1.350.000đ/vé người lớn – 1.000.000đ/vé trẻ em.
Cáp treo 2 chiều: 600.000đ/vé người lớn – 450.000đ/vé trẻ em.
Cáp treo 2 chiều & ăn trưa: 900.000đ/vé người lớn – 650.000đ/vé trẻ em.

Quy định trẻ em
– Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
– Trẻ em từ 2 tuổi đến dưới 11 tuổi (Không có chế độ giường riêng).
– Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% (Có chế độ giường riêng).
– Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Quy định đăng ký và thanh toán
Quý khách cung cấp danh sách họ tên đầy đủ theo đúng CMTND/ CCCD. Sau khi nhận phiếu đăng ký tour, quý khách thanh toán 75 % tiền cọc giữ chỗ trong vòng 12 giờ kể từ lúc xác nhận dịch vụ và 25% còn lại trước ngày khởi hành 05 ngày.',
    'https://fiditour.com/wp-content/uploads/2024/12/dinh-cau-phu-quoc-5.jpg
https://fiditour.com/wp-content/uploads/2024/12/hon-may-rut-3-1348.jpg
https://fiditour.com/wp-content/uploads/2024/12/ruou-sim-1674182508827426257041.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/phu-quoc-3n2d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-3413', 'Hà Nội - Tràng An - Bái Đính - Hạ Long - KDL Yên Tử 4N3Đ',
    'TP.HCM', 'Ninh Bình', '4N3Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 52 DAY) + INTERVAL 7 HOUR,
    3750000, 2812000, 35, 33, 'https://fiditour.com/wp-content/uploads/2022/12/9-1.png',
    'Xe và HDV đón Quý khách tại sân bay Nội Bài, đưa về khách sạn, nhận phòng, nghỉ ngơi, ăn trưa tại nhà hàng. Chiều: Quý khách thăm chùa Trấn Quốc –Ngôi chùa Trấn Bắc cổ kính nhất Việt Nam với 1.500 năm tuổi nằm trên bán đảo cồn Quy linh…',
    'Ngày 1: Đón khách tại sân bay – Hà Nội
Sáng: Xe và HDV đón Quý khách tại sân bay Nội Bài, đưa về khách sạn, nhận phòng, nghỉ ngơi, ăn trưa tại nhà hàng.
Chiều: Quý khách thăm chùa Trấn Quốc –Ngôi chùa Trấn Bắc cổ kính nhất Việt Nam với 1.500 năm tuổi nằm trên bán đảo cồn Quy linh thiêng, với truyền thuyết và huyền thoại về Hồ Tây, hồ Trúc Bạch.
Tiếp tục thăm quan Đền Ngọc Sơn, Cầu Thê Húc, hồ Hoàn Kiếm – Trực tiếp chứng kiến cụ Rùa dài 2,1m, ngang 1,2m được trưng bày tại đền Ngọc Sơn.
Sau đó, Quý khách ghé thăm Văn Miếu – Quốc Tử Giám – Nơi đựoc xem như Trường Đại học đầu tiên của Việt Nam với 82 tấm bia Tiến sỹ còn lưu danh sử sách.
Tối: Quý khách tự do dạo chơi thăm phố cổ Hà Nội, dạo hồ Hoàn Kiếm, mua sắm tại chợ đêm sầm uất…
Hồ Hoàn Kiếm

Ngày 2: Hà Nội – Bái Đính– Tràng An – Hạ Long
Sáng: Quý khách ăn sáng, trả phòng khách sạn, lên xe khởi hành đi Ninh Bình theo QL1A qua Hà Nam.
Đến Ninh Bình, Quý khách cầu lễ phật tại Chùa Bái Đính- ngôi chùa lớn nhất Việt Nam với 500 pho tượng La Hán, tượng phật đồng lớn nhất Việt Nam cao 10m nặng 100 tấn. Quý khách ăn trưa tại nhà hàng thưởng thức đặc sản dê núi đá.
Chiều: Quý khách ra bến lên đò thăm Quần thể Danh thắng Tràng An – Di sản được UNESCO công nhận là di sản văn hóa và thiên nhiên Thế giới, giúp cho Việt Nam lần dầu lọt vào danh sách 30 di sản hỗn hợp Thế Giới.
Lên thuyền xuôi dòng Sào Khê uốn lượn giữa cánh đồng lúa, nơi những dải đá vôi, thung lũng và những sông ngòi đan xen tạo nên một không gian huyền ảo, kỳ bí , ghé thăm Hang sáng , Hang tối , Hang nấu rượu…
15h00: Quý khách rời Ninh Bình, theo Quốc lộ 10 đi Hạ Long, trên đường đi Quý khách sẽ được cảm nhận, khám phá cuộc sống, phong cảnh đặc trưng của Đồng Bằng Bắc Bộ với cảnh làng quê thanh bình qua các tỉnh Nam Định, Thái Bình, Hải Phòng. Đến Hạ Long, nhận phòng, ăn tối tại nhà hàng.
Tối: Quý khách tự do dạo chơi, mua sắm hàng hóa tại khu chợ Đêm Hạ Long sầm uất với các sản phẩm đặc trưng, lên cầu Bãi Cháy – cây cầu dây văng dài nhất Việt Nam .
Tràng An

Ngày 3: Hạ Long – KDL Yên Tử – Hà Nội
Sáng: Quý khách ra bến lên tàu, tham quan Vịnh Hạ Long – Di sản thiên nhiên thế giới được UNESSCO công nhận năm 1994, chiêm ngưỡng vẻ đẹp huyền bí của hàng ngàn đảo đá và các hang động kì thú: Động Thiên Cung, hang Đầu Gỗ…ngắm cảnh Làng Chài, hòn Ấm, hòn Rùa,
hòn Đỉnh Hương, hòn Chó Đá, hòn Gà Chọi…
Chiều: Quý khách khởi hành đi Khu danh thắng đất Phật Yên Tử – đất tổ của Thiền Phái Trúc Lâm, tham quan Vườn Tháp Tổ, Chùa Hoa Yên ( Chi phí cáp treo tự túc ).
16h00: Quý khách lên xe về Hà Nội, ghé Hải Dương tham quan cửa hàng bánh Đậu Xanh, bánh cốm và các mặt hàng đặc sản khác của Miền Bắc. Tới Hà Nội, nhận phòng, ăn tối tại nhà hàng, nghỉ đêm.
Tối: Xe đưa Quý khách ra sân bay Nội Bài (chuyến bay sau 21h00) – Chào tạm biệt, kết thúc chương trình.
Vịnh Hạ Long
Lưu ý: Chương trình tour có thể thay đổi phù hợp với tình hình giao thông, điều kiện thời tiết thực tế hoặc sự thay đổi lịch bay do hãng hàng không. Công ty du lịch được quyền thay đổi hoặc hủy bỏ bất kỳ điểm tham quan nào có thể gây ảnh hưởng đến sự an toàn của Quý khách (mọi thay đổi sẽ được thông báo trước).',
    'Giá tour bao gồm
o Vận chuyển: 01 xe 45 chỗ đời mới, vận chuyển suốt hành trình.
Tàu thăm quan vịnh Hạ Long tuyến Thiên Cung- Đầu Gỗ, thuyền thăm KDL Tràng An
Xe điện khứ hồi lên chùa Bái Đính, Khu DL Yên Tử
o Lưu trú: 2 khách người lớn/phòng. Nếu lẻ nam hoặc lẻ nữ sẽ ngủ ghép phòng 3 khách.
o Hà Nội: Anise, First Eden, Moonview…
o Hạ Long: Seastar, Newyork, Bảo Hân…
o Hướng dẫn viên: Tiếng Việt phục vụ suốt tuyến, vui vẻ, nhiệt tình.
o Các bữa ăn theo chương trình:
• Bữa ăn sáng ăn sáng ngày đi.
• Bữa chính: 150.000vnđ/suất.
o Bảo hiểm du lịch mức bồi thường cao nhất 100.000.000 vnd/ vụ.
o Nón du lịch.
o Thuế VAT theo luật định.
o Vé tham quan theo chương trình tour.
o Nón LH Fiditour + nước tinh khiết 02 chai 0,5 lít/ khách/ ngày
o Banner chụp hình đoàn.

Giá tour không bao gồm
✓ Chi phí phòng đơn VIP 1.000.000 vnd/phòng/đêm
✓ Chi phí cá nhân như: tiền giặt ủi, điện thoại, đồ uống trong các bữa ăn…
✓ Tiền TIP cho HDV và tài xế
✓ Vé cáp treo KDL Yên Tử khứ hồi : 320.000đ/vé.
✓ Chi phí di chuyển, tham quan, ăn uống ngoài chương trình.

Chính sách giá trẻ em
– Tính theo năm sinh, không tính theo ngày tháng sinh.
Trẻ em dưới 06 tuổi miễn phí dịch vụ ( không quá 10% tổng số người lớn), hỗ trợ bảo hiểm du lịch, 01 chỗ ngồi trên xe, tàu, nước uống…
Trẻ em từ 06 – 10 tuối: 75% giá tour (có suất ăn riêng như người lớn) được hưởng: 1 chỗ trên xe, thuyền, vé tham quan và ngủ chung giường với ba mẹ.
Trẻ em 11 tuổi trở lên tính như người lớn.

Lưu ý
Tuổi tính theo năm sinh. Ví dụ sinh năm 2016 đến nay 2022 tính 06 tuổi.
Yêu cầu cung cấp chiều cao trẻ em nếu tham gia chương trình công viên, một số điểm thăm quan có đo chiều cao khi vào cổng ( vé phải đặt và thanh toán trước 01 ngày)
Giá vé công viên, điểm đo chiều cao dưới 1m: miễn phí
Từ 1m -1,3m tính 75% giá vé
Từ 1,3m trở lên tính như người lớn
Viếng Lăng Bác đóng cửa sáng thứ 2 & thứ 6 hàng tuần',
    'https://fiditour.com/wp-content/uploads/2022/12/ho-hoan-kiem-1-0927.jpg
https://fiditour.com/wp-content/uploads/2024/01/khu-du-lich-trang-an-2.webp
https://fiditour.com/wp-content/uploads/2022/12/vinh-ha-long-3-1624.jpg',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-noi-trang-an-bai-dinh-ha-long-kdl-yen-tu-4n3d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour trong nước' LIMIT 1), 'FDT-3390', 'Xứ Sở Ngàn Hoa Đà Lạt 3N2Đ',
    'TP.HCM', 'Đà Lạt', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 55 DAY) + INTERVAL 7 HOUR,
    3190000, 2392000, 20, 14, 'https://fiditour.com/wp-content/uploads/2022/12/4-16.png',
    'TOUR DU LỊCH ĐÀ LẠT 08h00-11h00: Đón khách tại sân bay Xe và hướng dẫn viên đón đoàn tại Sân bay Liên Khương. Về trung tâm thành phố Đà Lạt (Lịch trình sẽ linh động theo chuyến bay của khách hàng). Đoàn ăn trưa tại Nhà hàng. Sau đó tiếp…',
    'Ngày 1: Sân bay – Đà Lạt
TOUR DU LỊCH ĐÀ LẠT
08h00-11h00: Đón khách tại sân bay
Xe và hướng dẫn viên đón đoàn tại Sân bay Liên Khương.
Về trung tâm thành phố Đà Lạt (Lịch trình sẽ linh động theo chuyến bay của khách hàng). Đoàn ăn trưa tại Nhà hàng. Sau đó tiếp tục chương trình tour tham quan cùng đoàn vào buổi chiều.
14h00-15h30: Chinh phục núi LangBiang – nóc nhà Tây Nguyên (cao 1929m) Khi lên tới nơi, bạn sẽ được chiêm ngưỡng một khu du lịch tuyệt đẹp được hòa mình vào thiên nhiên núi rừng. Có thể ngắm trời, ngắm mây và còn ngắm được toàn cảnh thành phố Đà Lạt. (Chi phí xe jeep tự túc)
16h00: Kết thúc chương trình tour xe đưa quý khách về khách sạn nhận phòng, nghỉ ngơi. Quý khách tự túc ăn tối
Sân bay – Đà Lạt (bao gồm ăn trưa)
18:00: Tự do khám phá thành phố
Quý khách tự do khám phá Đà Lạt về đêm hoặc chọn cho mình những chương trình đặc sắc của Đà Lạt về đêm:
• Option 1: Chương trình giao lưu Văn hóa Cồng chiêng Đà Lạt đặc sắc. Đến đây quý khách sẽ cùng hòa mình vào đêm hội với những lời ca, tiếng hát, điệu múa, tiếng cồng chiêng của những chàng trai, cô gái trong buôn làng. Quý khách sẽ càng thêm yêu mến mảnh đất và con người Đà Lạt.
Các tiết mục trong chương trình:
1. Giao lưu Cồng Chiêng với người dân tộc bản địa
2. Uống rượu Cần, thịt nướng đặc sản của người dân tộc bản địa
3. Nhảy múa cùng các chàng trai cô gái bản địa
4. Tham gia các trò chơi dân gian
Giá vé xem show: 300.000/Khách
• Option 2: Thưởng thức nhạc Trịnh tại các phòng trà (Diễm Xưa, Memory,…), xem các show ca nhạc của các ca sĩ nổi tiếng (Lululola, Mây Lang Thang, Amazing show, Memory show,..)
Giá vé xem show: Tùy thuộc vào các hạng ghế ngồi.
Núi LangBiang – nóc nhà Tây Nguyên

Ngày 2: Khám phá thành phố Đà Lạt
7h00-8h00: Quý khách dùng buffet sáng tại khách sạn
8h00-9h30: Tham quan KDL Fresh Đà Lạt
Được mệnh danh là thiên đường của rất nhiều loài hoa, khung cảnh nên thơ, bạn có thể bắt gặp dễ dàng tại xứ sở tình yêu này. Nhưng để tìm kiếm một “bức tranh” Đà Lạt thu nhỏ ấn tượng trong lòng du khách thì Fresh Garden thật sự là nơi khiến bạn phải ghé thăm, nơi đây sở hữu những cánh đồng hoa rực rỡ, rộng bao la với đa dạng các loài hoa nhiều màu sắc tạo nên một bức tranh tuyệt đẹp
10h00-11h30: Tham quan Trang trại Puppy Farm
Điểm tham quan “hot” nhất hiện nay (hơn 36 loài chó quý hiếm, Lạc đà Alpaca và ngựa lùn Pony…)
Ngoài ra, Quý khách sẽ tham quan vườn bí ngô + dâu tây công nghệ cao + dưa leo baby, dưa pepino + cà chua cherry + vườn dương xỉ, sen đá, các vườn hoa (theo mùa)
11h-12h30: Quý khách dùng cơm trưa tại Nhà Hàng, nghỉ ngơi sau đó tiếp tục chương trình buổi chiều.
Khám phá thành phố Đà Lạt (Bao gồm Ăn sáng, trưa)
13h00-15h00: Tham quan Mongo Land
Một vẻ đẹp bình yên trong trẻo giữa núi rừng cùng các hàng cây xanh tươi mát và những chú thú cưng như: Dê mini, Cừu,
Thỏ Việt, Thỏ Holland Lop Hà Lan, Bọ Ú,… tha hồ cho quý khách trải nghiệm và checkin ảnh xinh
Trải nghiệm trượt phao khô với đường trượt đẹp và dài nhất Đà Lạt, trượt phao khô tại Mongo Land là trò chơi khiến bạn cảm thấy chưa chơi thì rén, nhưng đã chơi rồi thì chỉ có thể là “quá ghiền” vì trượt siêu mướt, siêu êm, siêu
mát!
15h30-16h00: Kết thúc chương trình tour, Xe và Hướng Dẫn viên sẽ đưa quý khách về lại khách sạn nghỉ ngơi. Quý khách tự túc ăn tối
Buổi tối quý khách tự do dạo chợ đêm, thưởng thức các món đặc sản như: sữa đậu nành, bánh tráng nướng, bắp nướng, khoai lang nướng,…
Mongo Land

Ngày 3: Tạm biệt thành phố ngàn hoa
7h00-10h30: Dùng buffet sáng tại khách sạn và làm thủ tục trả phòng
Quý khách tham quan, tự do mua sắm tại Chợ Đà Lạt
Xe đưa Quý khách ra Sân bay kết thúc chương trình tour Đà Lạt 4 ngày 3 đêm.
(Giờ tiễn sân bay sẽ linh động theo chuyến bay của khách hàng)',
    'Giá tour bao gồm
1.Vận chuyển: Xe đời mới máy lạnh 16 Chỗ – 29 Chỗ (Tùy theo lượng khách ghép trong ngày)
2.Lưu trú: Khách sạn 3* 4*: Tiêu chuẩn phòng 2-3 khách / phòng … – Khách sạn 3* tham khảo: Rum Vàng, Mai Vàng, Hoàng Minh Châu…
– Khách sạn 4* tham khảo: Kings Hotel, Sammy, Marigold…
3.Ăn uống:
a. Ăn sáng: 02 bữa. Ăn buf et tại khách sạn
b. Ăn trưa: 02 bữa. Suất ăn 160.000/ khách
4.Vé tham quan: Các điểm có trong chương trình tour
5.Nước suối tour: 500ml / ngày / chai
6.Bảo hiểm: 20.000.000 đ/Người/trường hợp
7.Hướng dẫn viên: nhiệt tình, vui vẻ phục vụ đoàn suốt tuyến.

Giá tour không bao gồm
1. Chi phí cá nhân: Giặt ủi, điện thoại, ăn uống ngoài chương trình ….
2. Vé xe jeep
3. Ăn tối.
4. Thuế VAT
5. Vé xem show Giao lưu văn hóa Cồng Chiêng và show ca nhạc.

Giấy tờ mang theo
– Các giấy tờ bắt buộc mang theo dưới đây phải đảm bảo còn giá trị sử dụng và phải đúng với thông tin đã đăng ký khi mua tour.
– Đối với khách mang quốc tịch Việt Nam
+ Khách từ 14 tuổi trở lên, phải có một trong các giấy tờ sau: Hộ chiếu; Giấy chứng minh nhân dân; Giấy chứng minh, chứng nhận của các lực lượng vũ trang; Thẻ Đại biểu Quốc hội; thẻ Đảng viên; thẻ Nhà báo; Giấy phép lái xe ô tô, mô tô; Thẻ kiểm soát an ninh cảng hàng không, sân bay; Thẻ nhận dạng của các hãng hàng không Việt Nam;
+ Khách dưới 14 tuổi, đi cùng người lớn, phải có một trong các giấy tờ sau: Hộ chiếu; Giấy khai sinh (bản chính, bản trích lục, sao y công chứng); Giấy chứng sinh (trường hợp dưới 01 tháng tuổi chưa có giấy khai sinh) (bản chính, bản trích lục, sao y công chứng); Giấy chứng nhận của tổ chức xã hội đối với trẻ em do tổ chức xã hội đang nuôi dưỡng (có giá trị sử dụng trong thời gian 6 tháng kể từ ngày xác nhận);
– Đối với khách mang quốc tịch nước ngoài: Hộ chiếu; Giấy thông hành

Điều kiện thay đổi, hoãn hủy
– Thời gian hủy được tính cho ngày làm việc, không tính thứ 7, Chủ Nhật và các ngày Lễ, Tết.
– Khách hàng chủ động hủy tour:
+ Trước từ 30 ngày trở lên so với ngày khởi hành: Chi trả 10% giá tour
+ Trước từ 20 đến 29 ngày so với ngày khởi hành: Chi trả 25% giá tour
+ Trước từ 10 đến 19 ngày so với ngày khởi hành: Chi trả 50% giá tour
+ Trước từ 05 đến 09 ngày so với ngày khởi hành: Chi trả 90% giá tour
+ Trước từ 05 ngày trở xuống so với ngày khởi hành: Chi trả 100% giá tour

Quy định phụ thu
Trẻ em dưới 05 tuổi – Miễn Phí – Bố Mẹ lo toàn bộ chi phí cho bé nếu có phát sinh. 02 người lớn chỉ được kèm 01 đến 02 trẻ em
Trẻ em từ 06 – 10 tuổi thu 75% – bao gồm tất cả các chi phí & ghế ngồi riêng trên xe, ngủ chung giường với bố mẹ. 02 người lớn chỉ được kèm 01 trẻ em.
Trẻ em từ 11 tuổi – tính vé người lớn
Phụ thu phát sinh phòng đơn : Từ 800.000 – 1.000.000/Đêm/Phòng 2 khách ( Khách sạn 3* 4*) đối với trường hợp khách yêu cầu ở 1 người 1 phòng riêng.',
    'https://fiditour.com/wp-content/uploads/2022/12/chinh_phuc_noc_nha_tay_nguyen_tai_khu_du_lich_langbiang_16fff27d85.webp
https://fiditour.com/wp-content/uploads/2022/12/mongo12_637938374025034110.jpg
https://fiditour.com/wp-content/uploads/2022/12/cho-da-lat-co-gi-vui-1.png',
    'ACTIVE', 'DOMESTIC')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/xu-so-ngan-hoa-da-lat-3n2d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14728', 'Đông Tây Hoa Kỳ 10N9Đ',
    'Hà Nội / TP.HCM', 'Hoa Kỳ', '10N9Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 58 DAY) + INTERVAL 7 HOUR,
    94900000, 71175000, 35, 31, 'https://fiditour.com/wp-content/uploads/2025/12/Du-lich-My-11-ngay-10-Dem.jpg',
    '12.30: Đoàn Sài gòn có mặt tại Sân bay Tân Sơn Nhất làm thủ tục bay đi Taipei. 14.00: Xe đưa đoàn ra Sân bay quốc tế Nội Bài đáp chuyến bay đi Taipei. 21.00: Hạ cánh xuống Taipei, hai đoàn gặp nhau, làm thủ tục transit và chuẩn bị đáp…',
    'Ngày 1: HÀ NỘI/SÀI GÒN – TAIPEI – LOS ANGELES ( ĂN/NGHỈ TRÊN MÁY BAY )
12.30: Đoàn Sài gòn có mặt tại Sân bay Tân Sơn Nhất làm thủ tục bay đi Taipei.
14.00: Xe đưa đoàn ra Sân bay quốc tế Nội Bài đáp chuyến bay đi Taipei.
21.00: Hạ cánh xuống Taipei, hai đoàn gặp nhau, làm thủ tục transit và chuẩn bị đáp chuyến bay đi New York.
21.40: Hạ cánh xuống sân bay Los Angeles (LAX), xe ô tô đưa đoàn đi ăn tối.
Sau bữa tối, Quý khách về khách sạn làm thủ tục nhận phòng và nghỉ ngơi.
Nghỉ đêm tại Los Angeles.
Ghi chú: Do chênh lệch múi giờ nên ngày khởi hành ở Việt Nam bay đến Mỹ vẫn là ngày đầu tiên (Ví dụ: Ngày khởi hành là ngày 1/10 tại Việt Nam thì ngày đến Mỹ vẫn là ngày 1/10 tính theo giờ địa phương).

Ngày 2: LOS ANGELES – HOLLYWOOD – SANTA MONICA
07.00: Đoàn dùng điểm tâm sáng tại khách sạn.
08:30: Đoàn tiếp tục tham quan:
Thăm quan Đại Lộ Danh Vọng (Hollywood Walk of Fame) – nơi lưu danh những ngôi sao nổi tiếng có đóng góp lớn trong làng điện ảnh, truyền hình, âm nhạc của Hoa Kỳ.
Thăm quan Nhà hát Kodak – nơi diễn ra lễ trao giải Oascar danh giá hành năm của làng điện ảnh Mỹ.
Thăm quan Nhà hát Trung Hoa – nơi công chiếu giới thiệu những bộ phim Hollywood trước khi tung ra thị trường.
12:30: Đoàn ăn trưa tại nhà hàng.
13.30: Quý khách tham quan thành phố cảng Santa Monica:
Cảng du thuyền Santa Monica – Bến tàu bao gồm nhiều khu vực khác nhau, đầu tiên là đoạn đường nối với các phần dành cho phương tiện, xe đạp hoặc người đi bộ, dẫn đến giao lộ của đại lộ Colorado với đại lộ Ocean, được đánh dấu bằng vòm màu trắng và xanh lam của cảng du thuyền Santa Monica, trước tòa nhà màu hồng của Del Frisco’s Grille..
Vòng xoay vui vẻ Santa Monica – Vòng quay ngựa gỗ Santa Monica, một phần lịch sử đầy mê hoặc của những năm 20, nơi đã trải qua một thời kỳ cải tạo, nó vẫn giữ được tất cả sự quyến rũ của nó. Khi vòng đu quay hoạt động, 44 con ngựa (không con nào giống con nào) cùng với một con thỏ, một con dê và hai chiếc xe trượt tuyết di chuyển nhịp nhàng. (chi phí các trò chơi tự túc)
Biển báo đường 66 “Cuối Đường mòn” – Ngay bên ngoài Công ty tôm Bubba Gump, bạn sẽ thấy biển báo “Tuyến đường 66, cuối con đường mòn”. Khi bến tàu chính thức được trao danh hiệu “điểm dừng cuối cùng trên Đường 66” (Con đường Mẹ đi từ Chicago đến Santa Monica), biển báo đường cũ đã được đưa trở lại đây. Nơi đây cũng có một ki-ốt bán những kỷ vật của con đường lịch sử.
18:30: Quý khách ăn tối tại nhà hàng địa phương.
Nghỉ đêm tại Los Angeles.

Ngày 3: LOS ANGELES – SAN DIEGO – LOS ANGELES
07.00: Đoàn dùng điểm tâm sáng tại khách sạn
08.00: Xe đưa đoàn khởi hành đi San Diego – thành phố đông người Việt sinh sống xếp thứ 4 của tiểu bang Cali và là thành phố biển đẹp nhất nhì nước Mỹ.
USS Midway – là hàng không mẫu hạm có hải trình phục vụ 47 năm, là mẫu hạm phục vụ lâu nhất của quân đội Mỹ trong thế kỷ 20, từ cuối chiến tranh TG II (WWII) cho đến cuộc chiến giải phóng Kuwait 1991, trước khi ” về hưu” vào năm 1992. Trong đó, đáng nhớ nhất là USS Midway đã từng tham gia 2 cuộc chiến: chiến tranh Vietnam và cuộc chiến vùng vịnh (bão sa mạc) 1991. Quý khách chụp ảnh bên ngoài.
Chụp hình với bức tượng chàng lính Hải quân và cô y tá nổi tiếng – một trong những biểu tượng của thành phố cảng xinh đẹp. Chiêm ngưỡng nụ hôn đẹp nhất lịch sử nước Mỹ.
Mua sắm và dạo bộ trong khu phố cổ 400 năm tuổi Balboa La Jolla với khu biệt thự mang đậm kiến trúc Tây Ban Nha.
12.00: Dùng bữa trưa tại nhà hàng.
13.00: Chiều đoàn tiếp tục tham quan (nếu còn thời gian)
Hòn đảo thơ mộng Colorado, tham quan và chụp hình tại khách sạn 5* cổ kính hotel Del Coronado với bãi cát dài thơ mộng – nơi từng tiếp đón nhiều chính khách và doanh nhân nổi tiếng thế giới.
Cây cầu tuyệt đẹp bắc qua vịnh San Diego
17.00: Đoàn khởi hành về Los Angeles. Quý khách tự do mua sắm.
18.30: Quý khách ăn tối tại nhà hàng địa phương.
20.00: Xe đưa đoàn về khách sạn nghỉ ngơi.
Nghỉ đêm tại Los Angeles.
Tuỳ chọn:
Chuyến đi sẽ hấp dẫn hơn nếu Quý khách đăng ký chương trình khám phá thành phố biên giới Tijuana của Mexico.

Ngày 4: LOS ANGELES – SEVEN MAGIC MT – LAS VEGAS
07.00: Đoàn dùng điểm tâm sáng. Làm thủ tục trả phòng khách sạn.
08.00: Đoàn khởi hành về lại Las Vegas, trên đường quý khách ghé qua:
Seven Magic Mountain hay còn được biết đến với tên gọi công viên đá 7 màu là một tác phẩm nghệ thuật sắp đặt vô cùng độc đáo tọa lạc ngay bên cạnh xa lộ Interstate, thuộc khu vực phía Nam của Las Vegas.
Đặt chân đến tham quan công viên đá 7 màu ở Mỹ, bạn chắc chắn sẽ phải ngỡ ngàng trước sự sáng tạo của con người cũng như sự kỳ diệu của tạo hóa. Điểm nhấn chính của công viên nằm ở 7 cột đá khổng lồ xếp chồng lên nhau một cách cực kỳ ngoạn mục. Để thực hiện được tác phẩm này, người ta đã phải sử dụng 33 tảng đá vôi cực lớn, mỗi tảng nặng từ 10 đến 25 tấn, xếp chồng chúng lên nhau tạo thành 7 tòa tháp, cao từ 9 đến 11 mét. Mỗi tảng đá lại được sơn một màu sắc khác nhau, tạo nên một vẻ đẹp rực rỡ khiến bất cứ ai khi đặt chân đến cũng phải ngẩn ngơ ngắm nhìn.
Chiều: Đến Las Vegas, đoàn đi dạo, tham quan thành phố Las Vegas trên Đại lộ chính Las Vegas Strip: Từ cầu vượt Tropicana, chụp hình Tượng sư tử MGM và Casino New York, (nếu còn thời gian) đoàn tham quan Casino Venetian với hệ thống kênh rạch quanh co và những chiếc thuyền Gondola ngược xuôi ngay tại sảnh chờ…
18.30: Dùng ăn tối tại nhà hàng. Đoàn về khách sạn nghỉ ngơi hoặc quý khách tham quan Las Vegas – thành phố không ngủ, Quý khách sẽ không khỏi ngạc nhiên khi thành phố này không bao giờ có khái niệm về thời gian và giấc ngủ. Ngay cả khi màn đêm buông xuống, cả thành phố vẫn sáng bừng trong ánh đèn, vẫn nhộn nhịp, vẫn huyên náo như chưa muốn nghỉ ngơi.
Option tour:
Quý khách có thể tự do thưởng thức các liveshow đặc sắc về đêm “Le Rêve” tại Wynn với hàng trăm nữ vũ công cũng là VĐV bơi lặn chuyên nghiệp xuất hiện ngược trên mặt nước (vé tự túc và phải đăng ký trước), hoặc Show “O” tại Bellagio (vé tự túc, giá vé tùy thời điểm), … hay quý khách có thể tự do khám phá Las Vegas về đêm.
Nghỉ đêm tại Las Vegas.

Ngày 5: LAS VEGAS – HẺM NÚI ĐÁ ĐỎ – WASHINGTON DC
09.00: Đoàn dùng điểm tâm sáng tại nhà hàng.
10.00: Hướng dẫn viên đưa Quý khách tham quan HẺM NÚI ĐÁ ĐỎ – RED ROCK GRAND CANYON – Đây là nơi lưu giữ dấu tích sinh sống của các bộ lạc da đỏ và các loại động vật đặc biệt trên sa mạc như đại bàng American Eagle, rùa sa mạc, thỏ sa mạc … Đây còn là nơi có nhiều vách đá sa thạch màu đỏ rực rỡ trải dài hàng cây số, và là phim trường tự nhiên của nhiều bộ phim nổi tiếng.
Tối: Đoàn ăn tối
Sau bữa tối, Đoàn ra sân bay làm thủ tục bay đi Washington DC – Thủ đô của Hoa Kỳ được thành lập vào năm 1790 ( thời gian bay 5 tiếng liên tục)
Nghỉ đêm trên máy bay.

Ngày 6: WASHINGTON DC CITY TOUR
Sáng: Hạ cánh. Đoàn ăn sáng nhà hàng
09.30: Quý khách ghé thăm:
Bảo tàng Hàng Không và Không Gian Hoa Kỳ – Nơi ghi lại lịch sử phát triển của ngành hàng không, trưng bày các mẫu máy bay chiến đấu, máy bay dân dụng theo trình tự phát triển. Tại đây Quý khách sẽ đi qua từng giai đoạn phát triển của ngành hàng không vũ trụ của Hoa Kỳ cũng như của thế giới.
12.00: Đoàn ăn trưa tại nhà hàng địa phương.
Sau bữa trưa, Xe ô tô đưa đoàn khởi hành đi tham quan thủ đô Washington DC
Nhà Trắng (chụp ảnh bên ngoài) – Nơi làm việc của đương kim tổng thống Hoa Kỳ, nơi đón tiếp các nguyên thủ quốc gia.
Điện Capitol – Tòa nhà lưỡng viện Hoa Kỳ, một thiết kế kiến trúc độc đáo. Nơi đây là đối trọng quyền lực với Nhà Trắng, cùng với Tòa án tối cao tạo thành thế chân vạc quyền lực trong thể chế chính trị “Tam quyền phân lập” của Liên Bang Mỹ.
Nhà tưởng niệm Lincoln – Tổng thống tài năng nhất nước Mỹ, người đã có công xóa bỏ chế độ nô lệ và thống nhất 36 bang của Hoa Kỳ.
Black wall – Bức tường đen – tưởng niệm cựu chiến binh chiến tranh Việt Nam.
Tưởng niệm cựu chiến binh chiến tranh Triều Tiên.
Đài tưởng niệm Washington (chụp ảnh từ bên ngoài) – Tổng thống đầu tiên của Hoa Kỳ, người đọc bản Tuyên ngôn khai sinh nước Mỹ, một tướng lĩnh tài ba.
18.30: Đoàn dùng bữa tối tại nhà hàng địa phương. Sau bữa tối, xe đưa đoàn về khách sạn.
Nghỉ đêm tại Washington DC.

Ngày 7: WASHINGTON DC – PHILADELPHIA – NEW YORK
07.00: Đoàn dùng điểm tâm sáng tại khách sạn. Quý khách làm thủ tục trả phòng.
08.00: Xe đưa đoàn khởi hành đi New York, trên đường đi Trên đường đi đoàn có cơ hội dừng chân tại Christiana Mall tại Newark – thuộc tiểu bang Delaware – đây là 1 trong 4 tiểu bang miễn thuế của Hoa Kỳ. Quý khách có thể mua sắm các sản phẩm đắt tiền, có giá trị cao như nước hoa, iPhone, iPad … mà không phải trả thêm thuế.
Lưu ý: Chương trình này sẽ chỉ thực hiện được nếu thời gian cho phép và theo sự sắp xếp của trưởng đoàn mà không ảnh hưởng đến thời gian tham quan của chương trình chính.
12.00: Đoàn dùng bữa trưa tại nhà hàng.
Sau bữa trưa, đoàn tiếp tục khởi hành về New York. Quý khách ghé tham quan thành phố Philadelphia.
Dinh độc lập Independence Hall – là nơi diễn ra cuộc họp thống nhất 13 bang của nước Mỹ và nhiều sự kiện lịch sử khác.
Tháp chuông tự do – nơi bảo tồn quả chuông lớn đã đánh lên hồi chuông tự do trong ngày thành lập nước Mỹ
18.30: Đoàn dùng bữa tối tại nhà hàng địa phương. Sau bữa tối, xe đưa đoàn về khách sạn.
Nghỉ đêm tại New York. .

Ngày 8: NEW YORK CITY TOUR
07.30: Đoàn dùng điểm tâm sáng tại khách sạn.
08.30: Quý khách khám phá thành phố New York – Một trong những trung tâm tài chính kinh tế lớn nhất thế giới.
Quý khách lên Du thuyền tham quan Tượng Nữ Thần Tự Do – Biểu tượng của nước Mỹ, biểu tượng của tinh thần Mỹ – tinh thần tự do. Tượng nữ thần tự do tên đầy đủ là (Nữ thần tự do soi sáng thế giới) là một tác phẩm điêu khắc theo phong cách tân cổ điển với kích thước cực lớn đặt trên đảo Liberty tại cảng New York. Tác phẩm này do kiến trúc sư Frédéric Bartholdi người pháp thiết kế và được khánh thành vào ngày 28 tháng 10 năm 1886.
Tham quan chụp hình với biểu tượng con bò phố Wall – Charging Bull.
Phố tài chính Wall Street – Nơi tọa lạc của sàn giao dịch chứng khoán New York và các trung tâm tài chính ngân hàng. Nơi đây còn được xem là trung tâm tài chính của thế giới. Mỗi chuyển động của phố Wall ảnh hưởng đến tình hình tài chính toàn cầu.
911 Memorial – đài tưởng niệm các nạn nhân vụ 11 tháng 9, được xây dựng trên nền Trung tâm Thương mại Thế giới hay còn được gọi là Ground Zero.
12.00: Đoàn ăn trưa tại nhà hàng địa phương.
Sau bữa trưa, đoàn tiếp tục chương trình tham quan thành phố New York với các địa danh
– Trung tâm thương mại sầm uất, nơi đặt đại bản doanh của kênh truyền hình NBC và tập trung các thương hiệu thời trang xa xỉ.
Đại lộ số 5 – 5th Avenue – Trung tâm thời trang của nước Mỹ, nơi tập trung các sàn Catwalk và các thương hiệu thời trang lớn của thế giới.
Quảng trường thời đại (Time Square) – Quảng trường trung tâm thành phố New York rực rỡ với những ánh đèn màu và bảng quảng cáo. Đây là nơi thị trưởng thành phố phát biểu trước công chúng và tổ chức những sự kiện lớn của New York.
Cầu Brooklyn – Biểu Tượng Vượt Thời Gian Ở New York. Công trình này được xem như một thành tựu xuất sắc của kỹ thuật ở thế kỷ XIX, khi lần đầu tiên sử dụng thép làm dây cáp và các tháp đá granite, tạo thành lối đi an toàn và đẹp mắt. Kể từ khi hoạt động vào năm 1883, cây cầu đã trở thành niềm tự hào của New York và cả nước Mỹ, một thành tựu kiến trúc xuất sắc khiến cả thế giới ngưỡng mộ sau gần 140 năm.

Ngày 9: MÁY BAY
01.05: Đoàn đáp chuyến bay về Việt Nam (thời gian bay là hơn 11h bay liên tục)
Do lệch tuyến đổi ngày, Quý khách nghỉ đêm trên máy bay và đến Taipei vào ngày hôm sau.

Ngày 10: TAIPEI – HÀ NỘI / SÀI GÒN
04.45: Đến sân bay Đài Bắc, Quý khách làm thủ tục nối chuyến và mua sắm hàng miễn thuế tại sân bay Đào Viên – một trong những sân bay được đánh giá là có hoạt động và các mặt hàng miễn thuế đa dạng và phong phú top 10 trên thế giới.
08.25: Máy bay cất cánh về HÀ NỘI / SÀI GÒN.
10.35: Về tới sân bay Nội Bài / Tân Sơn Nhất, Quý khách làm thủ tục nhập cảnh và nhận lại hành lý.
Kết thúc chương trình. Chia tay và hẹn gặp lại Quý khách.
KẾT THÚC CHƯƠNG TRÌNH THAM QUAN VÀ KHÁM PHÁ NƯỚC MỸ!',
    'Bữa ăn tôm hùm kiểu mỹ đặc biệt 45 usd/khách
Xe đón tiễn sân bay Nội Bài
Phương tiện vận chuyển tại Hoa Kỳ: Từ 16-19 khách – 26 seat coach; từ 20 đến 24 khách – 36 seats minibus; 25 pax up – 46-56 seats.
Bảo hiểm du lịch với mức bảo hiểm 50,000 USD
Phí thăm quan thắng cảnh: Liberty Island, Công Viên đá bảy màu, Red Rock Canyon
Hướng dẫn viên đi theo đoàn suốt tuyến từ Việt Nam
02 chai nước/người/ ngày tại Mỹ
Quà tặng du lịch: Ổ cắm đa năng + Mũ
Chi phí phòng đơn – Phụ thu nếu khách có nhu cầu
Chi phí cá nhân: điện thoại, tiền giặt, hành lý quá cước.
Chi phí yêu cầu dịch vụ ngoài giờ với xe ($110/đoàn/giờ) và HDV($50/đoàn/giờ)
Lệ phí xin visa Hoa Kỳ: 6.500.000 VNĐ (Có thể thay đổi theo quy định của ĐSQ Mỹ), lệ phí này không được hoàn lại vì bất cứ lý do nào.
Tiền tip cho HDV và lái xe nước ngoài $100/khách/hành trình
Chi phí dời ngày và đổi chặng bay (nếu có yêu cầu)
Chi phí ngoài giờ cho HDV và lái xe (nếu có yêu cầu)

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Bước 1 (đăng ký):
Điền đơn theo mẫu gửi về công ty (gửi trực tiếp/fax/email),
Ảnh 5x5cm, nền trắng, không đeo kính, vén tóc gọn gàng.
Mặt hộ chiếu (có bị trú nơi sinh, hộ chiếu còn hạn trên 6 tháng)
Hướng dẫn thủ tục visa.
Ký hợp đồng dịch vụ giữa khách hàng với Công ty và đóng tiền đặt cọc cho chuyến đi (40.000.000 VNĐ)

Bước 2 (thực hiện):
CTDL điền đơn visa điện tử cho Quý khách, hẹn ngày phỏng vấn, đóng lệ phí phỏng vấn cho khách hàng.
Quý khách chuẩn bị hồ sơ theo hướng dẫn.
Quý khách tham dự phỏng vấn visa tại ĐSQ/LSQ Hoa Kỳ.

Bước 3 (kết quả):
ĐẠT VISA: Quý khách đóng đủ tiền tour khởi hành.

Đạt visa nhưng không khởi hành:
Vì lý do bất khả kháng: thời tiết, chiến tranh, bệnh tật nặng, tang gia, chuyến bay bị trì hoãn do thời tiết/ kỹ thuật…thì:
Công ty sẽ bảo lưu tiền đặt cọc và ghép đoàn trong thời hạn 3 tháng
Công ty sẽ hoàn trả lại tiền tour cho quý khách sau khi đã trừ lại các chi phí dịch vụ đã thực hiện.
Khách hủy không đi:
Nếu báo hủy ngay sau khi đặt cọc Quý khách sẽ chịu phạt 35% tiền tour trên tổng số khách hủy.
Nếu báo hủy trong vòng 15 – 10 ngày Quý khách sẽ phải chịu phạt 50% tiền tour trên tổng số khách hủy.
Nếu báo hủy trong vòng 09 – 07 ngày Quý khách sẽ phải chịu phạt 80% tiền tour trên tổng số khách hủy.
Nếu báo hủy trong vòng 04 – 06 ngày Quý khách sẽ phải chịu phạt 90% tiền tour trên tổng số khách hủy.
KHÔNG ĐẠT VISA: Hoàn tiền đặc cọc tour sau khi trừ phí nộp Đại Sứ Quán (6.500.000VNĐ) và thuế YR ($25) là phí quản trị hệ thống của hãng hàng không.',
    'https://fiditour.com/wp-content/uploads/2025/12/fgwrqweqweqwfre-1.jpg
https://fiditour.com/wp-content/uploads/2025/12/sandiego_019_6606_up.jpg
https://fiditour.com/wp-content/uploads/2025/12/v-vc-bfgh-min.jpg
https://fiditour.com/wp-content/uploads/2025/12/avt-hem-nui-Linh-Duong.webp
https://fiditour.com/wp-content/uploads/2025/12/nha-tuong-niem-lincoln-5.webp
https://fiditour.com/wp-content/uploads/2025/12/20231115_103737-1-1.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-noi-sai-gon-dong-tay-hoa-ky-10n9d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14745', 'Bắc & Nam New Zealand 9N8Đ',
    'Hà Nội', 'New Zealand', '9N8Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 61 DAY) + INTERVAL 7 HOUR,
    109900000, 82425000, 20, 17, 'https://fiditour.com/wp-content/uploads/2025/12/stock-photo-eiffel-tower-paris-france-112137761.avif',
    'Đoàn Hà Nội: 16:00: Xe và Hướng dẫn viên đón Quý khách tại điểm hẹn trong trung tâm thành phố, đưa ra sân bay Nội Bài, đáp chuyến bay CZ8178 (19.45– 22.25) của hàng không China Southern Airlines 4*đi Quảng Châu. Đoàn HCM: 13:00: Xe và…',
    'Ngày 1: HÀ NỘI – QUẢNG CHÂU ( ĂN/NGHỈ TRÊN MÁY BAY )
Đoàn Hà Nội: 16:00: Xe và Hướng dẫn viên đón Quý khách tại điểm hẹn trong trung tâm thành phố, đưa ra sân bay Nội Bài, đáp chuyến bay CZ8178 (19.45– 22.25) của hàng không China Southern Airlines 4*đi Quảng Châu.
Đoàn HCM: 13:00: Xe và Hướng dẫn viên đón Quý khách tại điểm hẹn trong trung tâm thành phố, đưa ra sân bay Tân Sơn Nhất, đáp chuyến bay CZ374 (16.10– 20.00) của hàng không China Southern Airlines 4*đi Quảng Châu.
Đến Quảng Châu, đoàn nối chuyến (thời gian nối chuyến: 2 tiếng 10 phút) đi New Zealand.
Quý khách ăn và nghỉ đêm trên máy bay.

Ngày 2: QUẢNG CHÂU – AUCKLAND
00:10: Quý khách đáp chuyến bay đi Auckland trên chuyến bay CZ305 (00:10 – 16:15)
16:15: Đặt chân đến Auckland “Thành phố của những cánh buồm”.
Xe và HDV địa phương đón đoàn tại sân bay, đưa đi ăn tối tại nhà hàng địa phương. Sau bữa tối, đoàn về khách sạn nhận phòng, nghỉ ngơi để lấy lại sức sau chặng bay dài, chuẩn bị cho hành trình khám phá đầy hứng khởi vào ngày hôm sau.
Nghỉ đêm tại khách sạn Mercure Auckland hoặc 4* tương đương tại Auckland

Ngày 3: AUCKLAND – MATAMATA – ROTORUA
Sáng: Quý khách ăn sáng sớm tại khách sạn . Xe đưa đoàn rời Auckland đi Matamata, thị trấn nhỏ nổi tiếng toàn cầu nhờ phim trường Hobbiton – bối cảnh trong bộ phim “Chúa tể những chiếc nhẫn” và “The Hobbit”. Quý khách dạo bước trên những thảm cỏ xanh mướt, ngắm nhìn các ngôi nhà Hobbit xinh xắn nép mình trong đồi cỏ.
Tham quan cây “Party Tree”, cây cầu đá và các bối cảnh gắn liền với những thước phim kinh điển. Thưởng thức một cốc bia hoặc nước táo tại Green Dragon Inn (chi phí đã bao gồm trong vé tham quan).
12:00 – Ăn trưa tại nhà hàng địa phương.
13:30 – Đoàn tiếp tục hành trình đến Rotorua, thành phố nằm trên vùng đất địa nhiệt độc đáo của New Zealand. Tham quan:
Te Puia Thermal Reserve: chiêm ngưỡng suối nước nóng, hồ bùn sôi và đặc biệt là phun trào Geyser Pohutu – cao nhất Nam Bán Cầu.
Tìm hiểu về văn hóa người Maori với các công trình khắc gỗ và điêu khắc truyền thống.
17:30 – Về khách sạn tại Rotorua nhận phòng, nghỉ ngơi.
18:30 – Ăn tối tại nhà hàng địa phương. Quý khách có thể thưởng thức chương trình biểu diễn văn hóa Maori đặc sắc (chi phí tự túc).
20:30 – Tự do dạo chơi thành phố Rotorua về đêm hoặc thư giãn với dịch vụ ngâm khoáng nóng tự nhiên (chi phí tự túc).
Nghỉ đêm tại khách sạn Rydges Rotorua or Ibis Rotorua 4* tương đương tại Rotorua

Ngày 4: ROTORUA – WAITOMO – AUCKLAND
Sáng: Sau khi ăn sáng tại khách sạn. Xe đưa đoàn rời Rotorua đi Waitomo, vùng đất nổi tiếng với hệ thống hang động đá vôi kỳ vĩ hàng triệu năm tuổi.
Waitomo Glowworm Caves: xuống thuyền xuôi theo dòng sông ngầm để chiêm ngưỡng hàng ngàn đom đóm phát sáng lấp lánh trên vòm hang, tạo nên khung cảnh huyền ảo như bầu trời đêm.
Tìm hiểu quá trình hình thành thạch nhũ và măng đá độc đáo trong lòng hang.
Trưa: Ăn trưa tại nhà hàng địa phương.
13:30 – Khởi hành về lại Auckland. Trên đường đi, đoàn chiêm ngưỡng cảnh quan đồng quê xanh mướt đặc trưng của đảo Bắc New Zealand.
16:30 – Đến Auckland, xe đưa đoàn tham quan :
Auckland Harbour Bridge : cây cầu nổi tiếng nối liền trung tâm thành phố với North Shore, nơi thường diễn ra hoạt động nhảy bungy độc đáo.
Sky Tower (biểu tượng thành phố, cao 328m): ngắm toàn cảnh Auckland từ đài quan sát trên cao.
Tối : Ăn tối tại nhà hàng địa phương.
Nghỉ đêm tại khách sạn Mercure Auckland hoặc 4* tương đương tại Auckland

Ngày 5: AUCKLAND – QUEENTOWN
Sáng: Ăn sáng tại khách sạn, làm thủ tục trả phòng. Xe đưa đoàn ra sân bay làm thủ tục chuyến bay nội địa đi Queenstown– thành phố du lịch nổi tiếng thế giới, nằm e ấp bên hồ Wakatipu với dãy Remarkables hùng vĩ phía sau.(khoảng 01h30 phút bay)
09:00 Xe đưa đoàn tham quan thành phố nghỉ dưỡng nổi tiếng Queenstown – nơi được mệnh danh là “thủ đô phiêu lưu của thế giới”.
Lake Wakatipu : hồ nước trong xanh với hình dáng uốn lượn độc đáo, được bao quanh bởi dãy Remarkables hùng vĩ.
Queenstown Gardens: công viên xanh mát nằm bên bờ hồ với nhiều loài hoa rực rỡ và cảnh quan yên bình.
10:00 : Đoàn trải nghiệm hành trình bằng cáp treo Skyline Gondola lên đỉnh núi Bob’s Peak, ngắm nhìn toàn cảnh Queenstown và hồ Wakatipu từ trên cao. Tại đây, quý khách có thể thử trò chơi Luge trượt dốc đầy thú vị (chi phí tự túc).
Trưa : Ăn trưa tại nhà hàng địa phương.
Chiều: HDV tiếp tục đưa đoàn đi tham quan:
Arrowtown: thị trấn khai thác vàng từ thế kỷ XIX. Quý khách dạo bộ trên những con phố nhỏ rợp bóng cây, ngắm nhìn các ngôi nhà gỗ cổ kính và thưởng thức không khí bình yên nơi miền núi.
16:00 – Trở lại trung tâm Queenstown. Đoàn có thời gian tự do mua sắm tại các cửa hiệu đặc sản, quà lưu niệm hoặc dạo quanh phố chính.
Tối: Ăn tối tại nhà hàng địa phương.
Nghỉ đêm tại khách sạn Mercure Queenstown Resort hoặc 4* tương đương tại Queenstown

Ngày 6: QUEENSTOWN – MILFORD SOUND – QUEENSTOWN
Sáng: Quý khách ăn sáng sớm tại khách sạn sau đó đoàn khởi hành đi Milford Sound, một trong những vịnh hẹp đẹp nhất hành tinh, được UNESCO công nhận là Di sản Thiên nhiên Thế giới.
Trên đường đi, quý khách được chiêm ngưỡng cung đường tuyệt đẹp xuyên qua Công viên Quốc gia Fiordland, nơi núi non, sông hồ, rừng già và thác nước đan xen tạo nên khung cảnh hùng vĩ. Xe dừng nghỉ tại một số điểm ngắm cảnh nổi tiếng:
Eglinton Valley: thung lũng rộng lớn với thảm cỏ xanh mướt trải dài giữa những dãy núi cao.
Mirror Lakes: mặt hồ phẳng lặng soi bóng núi non hùng vĩ, tạo nên những bức ảnh tuyệt đẹp.
Homer Tunnel : đường hầm xuyên núi dài gần 1,3 km, dẫn vào thế giới vịnh hẹp huyền bí.
11:30 – Đến Milford Sound. Quý khách lên du thuyền tham quan vịnh trong khoảng 1 giờ 45 phút.Ngắm nhìn những vách núi đá dựng đứng cao tới 1.200m đổ thẳng xuống biển.
Chiêm ngưỡng thác nước Stirling và Bowen trắng xóa, tung bọt nước mát lạnh. Nếu may mắn, du khách còn có thể bắt gặp hải cẩu nằm phơi nắng, chim cánh cụt nhỏ hay cá heo tung tăng bơi lội ngay cạnh thuyền.
Trưa: Thưởng thức bữa trưa ngay trên du thuyền, giữa khung cảnh thiên nhiên hùng vĩ – một trải nghiệm khó quên.
Chiều : Xe và HDV đưa đoàn quay về Queenstown. Trên đường trở lại, quý khách tiếp tục được ngắm cảnh đẹp của Fiordland dưới ánh chiều tà.
Tối: Ăn tối tại nhà hàng địa phương.
21:00 – Quý khách tự do khám phá Queenstown by night: dạo bộ bên hồ Wakatipu lung linh ánh đèn, ghé quán bar, quán café ven hồ hoặc thưởng thức đặc sản nổi tiếng Fergburger (chi phí tự túc)
Nghỉ đêm tại khách sạn Mercure Queenstown Resort hoặc 4* tương đương tại Queenstown

Ngày 7: QUEENSTOWN – CROMWELL – NÚI COOK – HỒ TEKAPO – CHRISTCHURCH
Sáng: Ăn sáng tại khách sạn, làm thủ tục trả phòng. Xe khởi hành về phía Nam theo cung đường xuyên qua những cánh đồng xanh bất tận của Canterbury Plains – vùng đồng bằng lớn nhất New Zealand. Hai bên đường là hình ảnh những đàn cừu, bò thảnh thơi gặm cỏ, khung cảnh bình yên như tranh.
HDV đưa Quý khách đi tham quan:
Núi Cook (Aoraki): ngọn núi cao nhất New Zealand (3.724m), nơi được mệnh danh là “nóc nhà của Nam Thái Bình Dương”. Trên đường đi, đoàn dừng chân ngắm cảnh hồ Pukaki – nổi tiếng với màu xanh ngọc độc đáo nhờ băng tan từ dãy Alps
Mount Cook National Park: đoàn có thời gian tự do dạo bước dọc các con đường mòn ngắn (Hooker Valley Track – tùy thời tiết), hít thở bầu không khí trong lành và chiêm ngưỡng những dãy núi phủ tuyết trắng quanh năm. Đây cũng là thiên đường cho những bức ảnh “để đời”.
Trưa: Ăn trưa tại nhà hàng địa phương .
Xe và HDV đưa đoàn đi tham quan:
Hồ Tekapo : viên ngọc xanh của đảo Nam. Mặt hồ long lanh màu ngọc bích, phản chiếu dãy Southern Alps phía xa. Đặc biệt: tại hồ Tekapo, New Zealand, hoa lupin nở rộ đẹp nhất từ giữa tháng 11 đến đầu tháng 1 hàng năm. Thời điểm tốt nhất để ngắm hoa là vào cuối tháng 11 hoặc đầu tháng 12, khi hoa bắt đầu nở rộ và phủ kín các sườn đồi xung quanh hồ, tạo nên khung cảnh rực rỡ sắc màu.
Nhà thờ Good Shepherd: ngôi nhà thờ bằng đá nhỏ bé, nằm đơn sơ bên bờ hồ, phía sau là khung cảnh núi non tráng lệ – một trong những điểm chụp hình đẹp nhất New Zealand.
Tượng chó chăn cừu: biểu tượng tri ân dành cho những chú chó đã góp phần lớn trong quá trình khai phá và phát triển ngành nông nghiệp nơi đây.
Chiều: Đoàn khởi hành về Christchurch – thành phố mệnh danh là “Garden City – Thành phố vườn” của New Zealand.
Tối : Ăn tối tại nhà hàng địa phương.
Nghỉ đêm tại khách sạn Carnmore Hotel Chrischurch hoặc 4* tương đương tại Christchurch

Ngày 8: CHRISTCHURCH – HÀ NỘI
Sáng: Ăn sáng tại khách sạn, làm thủ tục trả phòng. Xe đưa đoàn đi tham quan :
Công viên Hagley : lá phổi xanh rộng lớn nằm giữa lòng thành phố.
Cathedral Square: quảng trường trung tâm, nơi tọa lạc nhà thờ chính tòa nổi tiếng.
Botanic Gardens: vườn thực vật rực rỡ sắc hoa theo mùa.
Avon River: con sông nhỏ uốn quanh thành phố, mang lại vẻ đẹp yên bình
Trưa: Ăn trưa tại nhà hàng địa phương.
Chiều: Tự do dạo phố, mua sắm quà lưu niệm tại trung tâm thương mại Christchurch.
Tối : Ăn tối tại nhà hàng địa phương.
19:30 – Xe đưa đoàn ra sân bay quốc tế Christchurch , làm thủ tục chuyến bay về Việt Nam. Chuyến bay CZ618 (22:30-05:20+1) từ Christchurch đi Quảng Châu. Quý khách nghỉ đêm trên máy bay.
Quý khách nghỉ ngơi trên máy bay

Ngày 9: QUẢNG CHÂU – HÀ NỘI
GIÁ TOUR
GIÁ TOUR TRỌN GÓI:
(Giá dành cho khách lẻ ghép đoàn, đơn vị VNĐ )
NGÀY ĐI – NGÀY VỀ
GIÁ TOUR
TRẺ EM
( Từ 2 tuổi – 11 tuổi )
PHỤ PHÍ PHÒNG ĐƠN
(Nếu có)
10/01 – 18/01/2026
109.900.000
98.910.000
19.990.000
14/02 – 22/02/2026
(27 Tết âm lịch)',
    'Lưu ý:
Em bé dưới 02 tuổi: thu phí 35% giá của người lớn; cha mẹ tự túc các dịch vụ liên quan tới bé.
Trẻ em từ 02 – dưới 10 tuổi: 90% giá của người lớn (toàn bộ dịch vụ hưởng như người lớn, ngủ chung giường với bố/mẹ)
Trẻ em từ 10 tuổi trở lên: 100% giá tour người lớn (toàn bộ dịch vụ hưởng như người lớn, có chế độ giường riêng.

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Hồ sơ cần thiết khi xin visa
Hộ chiếu gốc (Cả hộ chiếu cũ và hộ chiếu mới)
Nộp bản gốc trong vòng 2 ngày sau khi xác nhận đặt tour. Công ty sẽ trả lại bản gốc cho Quý khách sau khi hoàn tất quá trình lăn vân tay
01 ảnh nền trắng
Kích thước 4 cm X 6 cm nền trắng, chụp trước, không bị cản trở, gần đây (dưới 6 tháng). Ảnh phải có cận cảnh mặt và cổ sao cho khuôn mặt tượng trưng cho 70 – 80% ảnh.
Giấy tờ chứng minh nghề nghiệp (scan bản gốc):
Khách hàng đang công tác tại công ty/cơ quan: Hợp đồng lao động, bảng lương 3 tháng, sổ BHXH đơn xin nghỉ phép đi du lịch
Khách hàng là Giám đốc Doanh Nghiệp: Giấy ĐKKD, Báo cáo thuế 3 tháng, Giấy nộp tiền ngân sách nhà nước, sao kê tài khoản công ty 3 tháng gần nhất có dấu ngân hàng
Khách hàng là Chủ Hộ Đăng Ký Kinh Doanh cá thể: Giấy ĐKKD, biên lai nộp thuế
Khách hàng là hưu trí: Thẻ hưu hoặc sổ hưu, Bảng lương hưu hoặc sao kê tài khoản nhận lương hưu 3 tháng gần nhất
Khách hàng là sinh viên, học sinh: thẻ học sinh, đơn xin nghỉ học có xác nhận nhà trường
Giấy tờ chứng minh khả năng tài chính cá nhân: (Scan bản gốc)
Sao kê tài khoản lương/ tài khoản giao dịch nhiều nhất trong 6 tháng gần nhất và số dư cuối kỳ sao kê tối thiểu là 50.000.000vnđ (bản gốc có dấu ngân hàng, chỉ lấy sao kê khi có yêu cầu. Đề nghị không đi xin sao kê sớm quá tránh trường hợp giá trị sao kê không còn hiệu lực)
Sổ tiết kiệm tối thiểu 200.000.000VNĐ (photo mặt sổ), Xác nhận số dư STK (bản gốc có dấu đỏ của ngân hàng) Đề nghị chỉ đi lấy sao kê khi Sales thông báo, không đi xin sao kê sớm quá tránh trường hợp giá trị sao kê không còn hiệu lực
Xác nhận hạn mức thẻ tín dụng ( nếu có)
Sổ đỏ (photo công chứng)
Đăng ký xe ô tô (nếu có)
Đăng ký xe ô tô (nếu có – photo công chứng)
Xác nhận số dư tài khoản chứng khoán/trái phiếu (nếu có)
Hợp đồng thuê nhà photo công chứng nếu có
Giấy tờ nhân thân và mối quan hệ ràng buộc tại Việt Nam
Đăng ký kết hôn (nếu đã lập gia đình) (photo công chứng)
Sổ hộ khẩu photo
Căn cước công dân photo
Giấy khai sinh của các con photo công chứng ( Nếu có)
6.Tờ khai thông tin cá nhân theo mẫu',
    'https://fiditour.com/wp-content/uploads/2025/12/Auckland-Itinerary.jpg.webp
https://fiditour.com/wp-content/uploads/2025/12/nvdcg7f6jmvac32twcqw-scaled.jpg
https://fiditour.com/wp-content/uploads/2025/12/shutterstock_426993838-2100x975-1.jpg
https://fiditour.com/wp-content/uploads/2025/12/img-1536148717-8276-24942-0C0FCCD3-F283-6819-1DA7A16D2CF204E3__aWxvdmVrZWxseQo_CropResizeWzE5MDAsMTAwMCw3NSwianBnIl0.jpg
https://fiditour.com/wp-content/uploads/2025/12/eglinton-valley-1067.jpg
https://fiditour.com/wp-content/uploads/2025/12/78105-Lake-Tekapo.webp',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-2026-ha-noi-bac-nam-new-zealand-9n8d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14683', 'Hoa Kỳ 12N11Đ',
    'Hà Nội / TP.HCM', 'Hoa Kỳ', '12N11Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 64 DAY) + INTERVAL 7 HOUR,
    129900000, 97425000, 35, 31, 'https://fiditour.com/wp-content/uploads/2025/12/Du-lich-My-11-ngay-10-Dem.jpg',
    '08.00 Xe đưa đoàn ra Sân bay quốc tế Nội Bài đáp chuyến bay đi Taipei. 08.00 Đoàn Sài Gòn có mặt tại Sân bay Tân Sơn Nhất làm thủ tục bay đi Taipei. 15.55 Hạ cánh xuống sân bay Taipei, đoàn làm thủ tục transit và chuẩn bị đáp chuyến bay đi…',
    'Ngày 1: HÀ NỘI/SÀI GÒN – TAIPEI – NEW YORK ( ĂN/NGHỈ TRÊN MÁY BAY )
08.00 Xe đưa đoàn ra Sân bay quốc tế Nội Bài đáp chuyến bay đi Taipei.
08.00 Đoàn Sài Gòn có mặt tại Sân bay Tân Sơn Nhất làm thủ tục bay đi Taipei.
15.55 Hạ cánh xuống sân bay Taipei, đoàn làm thủ tục transit và chuẩn bị đáp chuyến bay đi New York lúc 17.10
20.45 Hạ cánh xuống sân bay John F.Kennedy (New York), xe ô tô đưa đoàn về khách sạn nghỉ ngơi. (Ăn tối Dinner box)
Nghỉ đêm tại New York.
Ghi chú: Do chênh lệch múi giờ nên ngày khởi hành ở Việt Nam bay đến New York vẫn là ngày đầu tiên (Ví dụ: Ngày khởi hành là ngày 1/10 tại Việt Nam thì ngày đến New York vẫn là ngày 1/10 tính theo giờ địa phương).

Ngày 2: NEW YORK CITY TOUR
07.30: Đoàn dùng điểm tâm sáng tại khách sạn.
08.30: Quý khách khám phá thành phố New York – Một trong những trung tâm tài chính kinh tế lớn nhất thế giới.
Quý khách lên Du thuyền tham quan Tượng Nữ Thần Tự Do – Biểu tượng của nước Mỹ, biểu tượng của tinh thần Mỹ – tinh thần tự do. Tượng nữ thần tự do tên đầy đủ là (Nữ thần tự do soi sáng thế giới) là một tác phẩm điêu khắc theo phong cách tân cổ điển với kích thước cực lớn đặt trên đảo Liberty tại cảng New York. Tác phẩm này do kiến trúc sư Frédéric Bartholdi người pháp thiết kế và được khánh thành vào ngày 28 tháng 10 năm 1886.
Tham quan chụp hình với biểu tượng con bò phố Wall – Charging Bull.
Phố tài chính Wall Street – Nơi tọa lạc của sàn giao dịch chứng khoán New York và các trung tâm tài chính ngân hàng. Nơi đây còn được xem là trung tâm tài chính của thế giới. Mỗi chuyển động của phố Wall ảnh hưởng đến tình hình tài chính toàn cầu.
911 Memorial – đài tưởng niệm các nạn nhân vụ 11 tháng 9, được xây dựng trên nền Trung tâm Thương mại Thế giới hay còn được gọi là Ground Zero.
12.00: Đoàn ăn trưa tại nhà hàng địa phương.
Sau bữa trưa, đoàn tiếp tục chương trình tham quan thành phố New York với các địa danh
Cầu Brooklyn – Biểu Tượng Vượt Thời Gian Ở New York. Công trình này được xem như một thành tựu xuất sắc của kỹ thuật ở thế kỷ XIX, khi lần đầu tiên sử dụng thép làm dây cáp và các tháp đá granite, tạo thành lối đi an toàn và đẹp mắt. Kể từ khi hoạt động vào năm 1883, cây cầu đã trở thành niềm tự hào của New York và cả nước Mỹ, một thành tựu kiến trúc xuất sắc khiến cả thế giới ngưỡng mộ sau gần 140 năm.
Rockerfeller Center – Trung tâm thương mại sầm uất, nơi đặt đại bản doanh của kênh truyền hình NBC và tập trung các thương hiệu thời trang xa xỉ.
Đại lộ số 5 – 5th Avenue – Trung tâm thời trang của nước Mỹ, nơi tập trung các sàn Catwalk và các thương hiệu thời trang lớn của thế giới.
Quảng trường thời đại (Time Square) – Quảng trường trung tâm thành phố New York rực rỡ với những ánh đèn màu và bảng quảng cáo. Đây là nơi thị trưởng thành phố phát biểu trước công chúng và tổ chức những sự kiện lớn của New York.
Tối: Dùng bữa tối tại nhà hàng địa phương.
Nghỉ đêm tại New York.

Ngày 3: NEW YORK – WASHINGTON DC
07.00: Đoàn dùng điểm tâm sáng tại khách sạn. Quý khách làm thủ tục trả phòng.
08.00: Xe đưa đoàn khởi hành đi Washington – Thủ đô của Hoa Kỳ được thành lập vào năm 1790, trên đường đi Quý khách ghé tham quan thành phố Philadelphia.
Dinh độc lập Independence Hall – là nơi diễn ra cuộc họp thống nhất 13 bang của nước Mỹ và nhiều sự kiện lịch sử khác.
Tháp chuông tự do – nơi bảo tồn quả chuông lớn đã đánh lên hồi chuông tự do trong ngày thành lập nước Mỹ (tuỳ điều kiện bảo dưỡng quý khách xem từ bên ngoài hoặc vào trong sờ lên tháp chuông)
12.00: Đoàn dùng bữa trưa tại nhà hàng.
Sau bữa trưa, đoàn tiếp tục khởi hành về DC. Trên đường đi đoàn có cơ hội dừng chân tại Christiana Mall tại Newark – thuộc tiểu bang Delaware – đây là 1 trong 4 tiểu bang miễn thuế của Hoa Kỳ. Quý khách có thể mua sắm các sản phẩm đắt tiền, có giá trị cao như nước hoa, iPhone, iPad … mà không phải trả thêm thuế.
Lưu ý: Chương trình này sẽ chỉ thực hiện được nếu thời gian cho phép và theo sự sắp xếp của trưởng đoàn mà không ảnh hưởng đến thời gian tham quan của chương trình chính.
18.30: Đoàn dùng bữa tối tại nhà hàng địa phương. Sau bữa tối, xe đưa đoàn về khách sạn.
Nghỉ đêm tại Washington DC.

Ngày 4: WASHINGTON DC – LAS VEGAS
07.00: Dùng điểm tâm sáng tại khách sạn
08.00: Làm thủ tục trả phòng và xe ô tô đưa đoàn khởi hành đi tham quan thủ đô Washington DC.
Nhà Trắng (chụp ảnh bên ngoài) – Nơi làm việc của đương kim tổng thống Hoa Kỳ, nơi đón tiếp các nguyên thủ quốc gia.
Điện Capitol – Tòa nhà lưỡng viện Hoa Kỳ, một thiết kế kiến trúc độc đáo. Nơi đây là đối trọng quyền lực với Nhà Trắng, cùng với Tòa án tối cao tạo thành thế chân vạc quyền lực trong thể chế chính trị “Tam quyền phân lập” của Liên Bang Mỹ.
Nhà tưởng niệm Lincoln – Tổng thống tài năng nhất nước Mỹ, người đã có công xóa bỏ chế độ nô lệ và thống nhất 36 bang của Hoa Kỳ.
Black wall – Bức tường đen – tưởng niệm cựu chiến binh chiến tranh Việt Nam.
Tưởng niệm cựu chiến binh chiến tranh Triều Tiên.
Đài tưởng niệm Washington (chụp ảnh từ bên ngoài) – Tổng thống đầu tiên của Hoa Kỳ, người đọc bản Tuyên ngôn khai sinh nước Mỹ, một tướng lĩnh tài ba.
12.30: Đoàn ăn trưa.
Xe đưa đoàn ra sân bay đáp chuyến bay đi Las Vegas – thành phố không ngủ của Hoa Kỳ
(Thời gian khoảng 5 tiếng bay)
Lưu ý: Chuyến bay và lịch trình ngày 4 -5 trong chương trình có thể thay đổi tùy thuộc tình hình thời tiết và điều kiện của hãng hàng không dịp cao điểm lễ tết)
Tối: Đoàn hạ cánh xuống sân bay Las Vegas, xe đưa đoàn đi ăn tối tại nhà hàng và đưa về khách sạn nghỉ ngơi.
Nghỉ đêm tại Las Vegas.

Ngày 5: LAS VEGAS – VƯỜN QUỐC GIA ZION – PAGE
07.00: Đoàn dùng điểm tâm sáng. Sau bữa sáng, đoàn khởi hành tham quan:
CÔNG VIÊN QUỐC GIA ZION – ỐC ĐẢO KHỔNG LỒ CỦA NƯỚC MỸ (khoảng 3 giờ đồng hồ di chuyển bằng ô tô) – Là công viên đầu tiên của bang Utah, công viên quốc gia Zion là một trong ba cái tên được liệt kê vào danh sách “Tam đại mỹ cảnh” của bờ Tây nước Mỹ, nằm trên cao nguyên giàu có về hệ động thực vật và đất đai màu mỡ. Zion, mang ý nghĩa “vườn địa đàng”. Ở vườn quốc gia Zion, người ta có thể dễ dàng tìm thấy những cái cây với hình thù kỳ lạ và màu sắc vô cùng đặc biệt tưởng chừng chỉ có trong thần thoại
12.30: Đoàn ăn trưa. Chiều đoàn tiếp tục tham quan:
Khe núi hẹp mang tên The Narrows. Khe núi sâu, nước dâng cao tầm đến bụng người. Các động sa thạch xung quanh khá bé, chỉ vừa đủ một người len lỏi qua. Bao quanh The Narrows là làn nước mát trong vắt, nhìn rõ từng viên đá xinh xắn dưới tận đáy. Sự mềm mại, uyển chuyển và uốn lượn của dòng sông Trinh Nữ này đã khiến vườn địa đàng Zion vừa mạnh mẽ, rắn rỏi lại vừa dịu dàng một cách đầy mê hoặc.
Bên cạnh dòng sông Trinh Nữ, đến Zion, quý khách đặt chân lên cung đường mang tên Riverside Walk. Đây là cung đường thu hút bậc nhất, trải dài 2 km, với vách đá dựng đứng sừng sững dọc hai bên, Riverside Walk giúp du khách cảm nhận và trải nghiệm vườn địa đàng Zion một cách tuyệt vời và hoàn hảo nhất.
19.00: Ăn tối tại nhà hàng địa phương Sau bữa tối, xe đưa đoàn về khách sạn nghỉ ngơi.
Nghỉ đêm tại Page.

Ngày 6: PAGE – HẺM NÚI LINH DƯƠNG – MONUMENT VALLEY – PAGE
07.00: Đoàn dùng điểm tâm sáng. Sau bữa sáng, đoàn khởi hành tham quan:
Hẻm núi Linh Dương – tuyệt tác của tạo hóa: Hiếm có nơi nào khác trên thế giới cho du khách thấy các đường cong tuyệt mỹ của núi đá sa thạch được chạm khắc bởi gió, nước và thứ ánh sáng ma mị xuyên qua khe núi như ở hẻm núi Linh Dương (Antelope Canyon). Hẻm núi này tọa lạc trên vùng đất Navajo, thuộc tiểu bang Arizona, miền Tây Nam nước Mỹ. Đây là điểm đến mơ ước của rất nhiều khách du lịch và nhiếp ảnh gia. Antelope Canyon giống như viên ngọc huyền bí đối với những ai từng được chiêm ngưỡng vẻ đẹp ấy.
12.30: Đoàn ăn trưa. Chiều đoàn tiếp tục tham quan:
Thung lũng Monument thung lũng huyền thoại trên các bộ phim nổi tiếng là một tuyệt tác thung lũng đá của người thổ dân da Đỏ Navajo. Nằm giữa hai bang Arizona và Utah của nước Mỹ, Thung lũng tượng đài Monument Valley là một phần của cao nguyên Colorado lộng lẫy. Vùng đất rộng chừng 100 km2 được bao trùm bởi đất đỏ và cát lắng đọng từ những con sông uốn mình quanh thung lũng. Hình thành chủ yếu từ những vách đá bằng sa thạch cao chót vót khoác lên mình bộ áo màu đỏ rực, sáng bừng. Vẻ đẹp nghệ thuật từ phong cảnh choáng ngợp chính là lý do khiến các nhà làm phim mê mẩn và khát khao được khắc họa lại qua từng bộ phim huyền thoại.
19.00: Ăn tối tại nhà hàng địa phương Sau bữa tối, xe đưa đoàn về khách sạn nghỉ ngơi.
Nghỉ đêm tại Page.

Ngày 7: PAGE – HORSESHOE BEND – LAS VEGAS
07.00: Đoàn dùng điểm tâm sáng. Sau bữa sáng, đoàn khởi hành tham quan:
Horseshoe Bend – Tuyệt tác thiên nhiên kỳ diệu hình móng ngựa – là một điểm đến thuộc vườn quốc gia Glen Canyon, tọa lạc tại sa mạc Arizona, miền Tây Hoa Kỳ. Đây là nơi gặp gỡ của con sông Colorado hiền hòa xanh ngọc với vùng đá sa thạch có niên đại hàng trăm triệu năm tuổi. Xuôi theo dòng chảy vô tận, con sông Colorado đã khéo léo điêu khắc lên vách núi những kỳ quan tuyệt diệu, trong đó có cấu trúc độc đáo hình móng ngựa, Horseshoe Bend. Vẻ đẹp hoàn hảo hội tụ tại đây chắc chắn sẽ khiến du khách không khỏi choáng ngợp.
12.30: Đoàn ăn trưa trên đường quay lại Las Vegas. Quý khách tham quan Las Vegas – thành phố không ngủ, Quý khách sẽ không khỏi ngạc nhiên khi thành phố này không bao giờ có khái niệm về thời gian và giấc ngủ. Ngay cả khi màn đêm buông xuống, cả thành phố vẫn sáng bừng trong ánh đèn, vẫn nhộn nhịp, vẫn huyên náo như chưa muốn nghỉ ngơi
Quý khách đi dạo, tham quan thành phố Las Vegas về đêm thật rực rỡ và hoành tráng trên Đại lộ chính Las Vegas Strip: Từ cầu vượt Tropicana, chụp hình Tượng sư tử MGM và Casino New York, tham quan Casino Venetian với hệ thống kênh rạch quanh co và những chiếc thuyền Gondola ngược xuôi ngay tại sảnh chờ…
19.00: Ăn tối tại nhà hàng địa phương Sau bữa tối, xe đưa đoàn về khách sạn nghỉ ngơi.
Option tour: Quý khách có thể tự do thưởng thức các liveshow đặc sắc về đêm “Le Rêve” tại Wynn với hàng trăm nữ vũ công cũng là VĐV bơi lặn chuyên nghiệp xuất hiện ngược trên mặt nước (vé tự túc và phải đăng ký trước), hoặc Show “O” tại Bellagio (vé tự túc, giá vé tùy thời điểm), … hay quý khách có thể tự do khám phá Las Vegas về đêm.
Nghỉ đêm tại Las Vegas.

Ngày 8: LAS VEGAS – LOS ANGELES – QUẬN CAM
07.00: Đoàn dùng điểm tâm sáng. Làm thủ tục trả phòng khách sạn.
08.00: Đoàn khởi hành về lại Los Angeles, trên đường đoàn dừng chân mua sắm Outlet Barstow – nằm ở phía Tây hoang mạc Mojave. Quý khách có thể tìm được những món hàng hiệu với giá cả phải chăng,
Trưa: Quý khách ăn trưa tại khu mua sắm.
13.30: Tiếp tục hành trình đến Los Angeles. Đoàn tham quan khu vực Little Saigon nơi có cộng đồng người Việt sinh sống đông đúc. Quý khách tự do mua sắm và tham quan Thương Xá Phước Lộc Thọ nổi tiếng và là nơi tọa lạc văn phòng của Fly USA tại Bờ Tây Nước Mỹ.
18.30: Dùng ăn tối tại nhà hàng. Đoàn về khách sạn nghỉ ngơi
Nghỉ đêm tại Los Angeles

Ngày 9: LOS ANGELES – SAN DIEGO – LOS ANGELES
07.00: Đoàn dùng điểm tâm sáng tại khách sạn
08.00: Xe đưa đoàn khởi hành đi San Diego – thành phố đông người Việt sinh sống xếp thứ 4 của tiểu bang Cali và là thành phố biển đẹp nhất nhì nước Mỹ.
USS Midway – là hàng không mẫu hạm có hải trình phục vụ 47 năm, là mẫu hạm phục vụ lâu nhất của quân đội Mỹ trong thế kỷ 20, từ cuối chiến tranh TG II (WWII) cho đến cuộc chiến giải phóng Kuwait 1991, trước khi ” về hưu” vào năm 1992. Trong đó, đáng nhớ nhất là USS Midway đã từng tham gia 2 cuộc chiến: chiến tranh Vietnam và cuộc chiến vùng vịnh (bão sa mạc) 1991. Quý khách chụp ảnh bên ngoài.
Chụp hình với bức tượng chàng lính Hải quân và cô y tá nổi tiếng – một trong những biểu tượng của thành phố cảng xinh đẹp. Chiêm ngưỡng nụ hôn đẹp nhất lịch sử nước Mỹ.
Mua sắm và dạo bộ trong khu phố cổ 400 năm tuổi Balboa La Jolla với khu biệt thự mang đậm kiến trúc Tây Ban Nha.
12.00: Dùng bữa trưa tại nhà hàng.
13.00: Chiều đoàn tiếp tục tham quan
Cây cầu tuyệt đẹp bắc qua vịnh San Diego
Hòn đảo thơ mộng Colorado, tham quan và chụp hình tại khách sạn 5* cổ kính hotel Del Coronado với bãi cát dài thơ mộng – nơi từng tiếp đón nhiều chính khách và doanh nhân nổi tiếng thế giới.
17.00: Đoàn khởi hành về Los Angeles. Quý khách tự do mua sắm.
18.30: Quý khách ăn tối tại nhà hàng địa phương.
20.00: Xe đưa đoàn về khách sạn nghỉ ngơi.
Nghỉ đêm tại Los Angeles.

Ngày 10: LOS ANGELES – SANTA MONICA – HOLLYWOOD – LAX
07.00: Đoàn dùng điểm tâm sáng tại khách sạn. Trả phòng.
08:30: Quý khách tham quan thành phố cảng Santa Monica:
Cảng du thuyền Santa Monica – Bến tàu bao gồm nhiều khu vực khác nhau, đầu tiên là đoạn đường nối với các phần dành cho phương tiện, xe đạp hoặc người đi bộ, dẫn đến giao lộ của đại lộ Colorado với đại lộ Ocean, được đánh dấu bằng vòm màu trắng và xanh lam của cảng du thuyền Santa Monica, trước tòa nhà màu hồng của Del Frisco’s Grille..
Vòng xoay vui vẻ Santa Monica – Vòng quay ngựa gỗ Santa Monica, một phần lịch sử đầy mê hoặc của những năm 20, nơi đã trải qua một thời kỳ cải tạo, nó vẫn giữ được tất cả sự quyến rũ của nó. Khi vòng đu quay hoạt động, 44 con ngựa (không con nào giống con nào) cùng với một con thỏ, một con dê và hai chiếc xe trượt tuyết di chuyển nhịp nhàng. (chi phí các trò chơi tự túc)
Biển báo đường 66 “Cuối Đường mòn” – Ngay bên ngoài Công ty tôm Bubba Gump, bạn sẽ thấy biển báo “Tuyến đường 66, cuối con đường mòn”. Khi bến tàu chính thức được trao danh hiệu “điểm dừng cuối cùng trên Đường 66” (Con đường Mẹ đi từ Chicago đến Santa Monica), biển báo đường cũ đã được đưa trở lại đây. Nơi đây cũng có một ki-ốt bán những kỷ vật của con đường lịch sử.
12:30: Đoàn ăn trưa tại nhà hàng.
13.30: Đoàn tiếp tục tham quan:
Thăm quan Đại Lộ Danh Vọng (Hollywood Walk of Fame) – nơi lưu danh những ngôi sao nổi tiếng có đóng góp lớn trong làng điện ảnh, truyền hình, âm nhạc của Hoa Kỳ.
Thăm quan Nhà hát Kodak – nơi diễn ra lễ trao giải Oascar danh giá hành năm của làng điện ảnh Mỹ.
Thăm quan Nhà hát Trung Hoa – nơi công chiếu giới thiệu những bộ phim Hollywood trước khi tung ra thị trường.
Quý khách ăn tối tại nhà hàng, Xe đưa đoàn ra sân bay đáp chuyến bay đi Taipei.

Ngày 11: TRÊN MÁY BAY
Ba bữa

Ngày 12: TAIPEI – HÀ NỘI/SÀI GÒN
GIÁ TOUR
GIÁ TOUR TRỌN GÓI:
(Giá dành cho khách lẻ ghép đoàn, đơn vị VNĐ )
NGÀY KHỞI HÀNH
GIÁ TOUR
TRẺ EM
( Từ 2 tuổi – 11 tuổi )
PHỤ PHÍ PHÒNG ĐƠN
(Nếu có)',
    'Bữa ăn tôm hùm kiểu mỹ đặc biệt 45 usd/khách
Xe đón tiễn sân bay Nội Bài
Phương tiện vận chuyển tại Hoa Kỳ: Từ 16-19 khách – 26 seat coach; từ 20 đến 24 khách – 36 seats minibus; 25 pax up – 46-56 seats.
Bảo hiểm du lịch với mức bảo hiểm 50,000 USD
Phí thăm quan thắng cảnh: Liberty Island, Hẻm núi Linh Dương, Vườn Quốc Gia Zion, thung lũng Monument
Hướng dẫn viên đi theo đoàn suốt tuyến từ Việt Nam
02 chai nước/người/ ngày tại Mỹ
Quà tặng DL : Ổ cắm đa năng + Mũ
Chi phí phòng đơn – Phụ thu nếu khách có nhu cầu
Chi phí cá nhân: điện thoại, tiền giặt, hành lý quá cước.
Chi phí yêu cầu dịch vụ ngoài giờ với xe ($150/đoàn/giờ) và HDV($60/đoàn/giờ)
Lệ phí xin visa Hoa Kỳ: 6.500.000 VNĐ (Có thể thay đổi theo quy định của ĐSQ Mỹ), lệ phí này không được hoàn lại vì bất cứ lý do nào.
Tiền tip cho HDV và lái xe nước ngoài $120/khách/hành trình
Chi phí dời ngày và đổi chặng bay (nếu có yêu cầu)
Chi phí ngoài giờ cho HDV và lái xe (nếu có yêu cầu)

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý:
Trẻ em từ 12 tuổi trở lên tính bằng người lớn
Trong trường hợp Quý khách đăng ký 1 người lớn đi cùng bé dưới 12 tuổi, vui lòng đóng tiền tour cho bé ngủ giường riêng.
Thứ tự các điểm tham quan có thể được sắp xếp thay đổi cho phù hợp với đường bay, giờ bay của hàng không nhưng số lượng các điểm tham quan đảm bảo không đổi.
Hộ chiếu (Passport) của quý khách phải còn thời hạn trên 6 tháng kể từ ngày nhập cảnh về Việt Nam.
Chương trình tour có thể thay đổi về ngày khởi hành, hàng không, khách sạn, trật tự các điểm thăm quan, điểm đầu, điểm cuối có thể thay đổi nhưng số đêm lưu trú khách sạn tại Hoa Kỳ bằng nhau và tổng các điểm tham quan không thay đổi.
Chương trình được xác nhận chính thức vào ngày họp đoàn, trước ngày khởi hành 2-3 ngày.
Giá tour có thể thay đổi nếu hàng không tăng phu phí hàng không vào ngày khởi hành
CTDL không nhận khách có thai từ 5 tháng trở lên tham gia tour du lịch Mỹ
Giờ nhận phòng khách sạn tại Mỹ là 14.00 và trả phòng là 12.00',
    'https://fiditour.com/wp-content/uploads/2025/12/con-pho-nhon-nhip-tap-nap-tai-wall-street-1-1.jpg
https://fiditour.com/wp-content/uploads/2025/12/20231115_103737-1-1.jpg
https://fiditour.com/wp-content/uploads/2025/12/nha-tuong-niem-lincoln-5.webp
https://fiditour.com/wp-content/uploads/2025/12/hoa-ky.jpeg
https://fiditour.com/wp-content/uploads/2025/12/avt-hem-nui-Linh-Duong.webp
https://fiditour.com/wp-content/uploads/2025/12/3ABCAB14-9A18-7217-0349A6EF42E00881.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-noi-sai-gon-hoa-ky-12n11d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14756', 'Khai Phong - Lạc Dương - Hoa Sơn - Tây An 6N6Đ',
    'TP.HCM', 'Trung Quốc', '6N6Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 67 DAY) + INTERVAL 7 HOUR,
    24490000, 18368000, 25, 20, 'https://fiditour.com/wp-content/uploads/2025/12/xian-0.jpg',
    'Đến sân bay Quảng Châu/ Thẩm Quyến, Đoàn làm thủ tục nhập cảnh Trung Quốc và đáp chuyến bay nội địa đến với Trịnh Châu (Giờ bay chi tiết theo ngày khởi hành). Hướng Dẫn đón đoàn dùng bữa trưa tại nhà hàng. Sau đó, đoàn di chuyển đến thành…',
    'Ngày 1: TRỊNH CHÂU – KHAI PHONG ( ĂN TRƯA, TỐI )
Đến sân bay Quảng Châu/ Thẩm Quyến, Đoàn làm thủ tục nhập cảnh Trung Quốc và đáp chuyến bay nội địa đến với Trịnh Châu (Giờ bay chi tiết theo ngày khởi hành). Hướng Dẫn đón đoàn dùng bữa trưa tại nhà hàng.
Sau đó, đoàn di chuyển đến thành phố Khai Phong, thuộc tỉnh Hà Nam, Trung Quốc với bề dày lịch sử hơn 4100 năm và từng là kinh đô của 8 triều đại.
Tham quan dạo chơi tại công viên Thanh Minh Thượng Hà Viên là danh lam thắng cảnh cấp quốc gia, khu công viên chủ đề tuyệt đẹp tái hiện văn hóa, lịch sử thời nhà Tống. Các trò chơi dân gian được tái hiện như: đá bóng nữ, đu dây trên mặt nước, gà bay, múa bóng cung đình, múa rối trên nước và múa theo nhạc Trung Hoa… Buổi tối, Quý khách thưởng thức hoa đăng, xem Đả Thiết Hoa – một hoạt động dân gian truyền thống phổ biến nhất ở khu vực Hà Nam và Sơn Tây, những bông hoa sắt sáng rực kết hợp với ánh sáng tạo nên một không gian vô cùng sống động.
Đoàn dùng bữa tối tại nhà hàng và nghỉ đêm tại Khai Phong.

Ngày 2: KHAI PHONG – ĐĂNG PHONG
Quý khách ăn sáng tại khách sạn.
Đoàn tham quan Khai Phong Phủ – một biểu tượng văn hóa và lịch sử của Trung Quốc gắn liền với câu chuyện của Bao Thanh Thiên. Với diện tích hơn 4 hecta, Phủ Khai Phong là khu danh thắng cấp 4AAAA bao gồm một loạt các công trình như sân bãi, thành lầu, nha môn và công đường xử án. Nơi đây tái hiện lại đầy đủ từ nơi làm việc, nơi nghỉ ngơi của quan lại, bộ đầu, binh lính và cả nhà lao giam để giữ phạm nhân chờ ngày xét xử.
Thiết Tháp được xây dựng vào năm 1049, được mệnh danh là “Thiên Hạ Đệ Nhất Tháp” với các chi tiết tráng men, thân tháp được kết nối từ nhiều viên gạch có rãnh và lỗ, đan xen khít vào nhau, hơn 28 hình dạng gạch khác nhau.
Xe đưa đoàn dùng bữa trưa tại nhà hàng và khởi hành đi Đăng Phong.
Khám phá Thiếu Lâm Tự (bao gồm xe điện), tham quan điện Tây Vương Thánh Nhân, võ đường Thiên Phật tự, Rừng Tháp…, đến đây quý khách sẽ được xem màn biểu diễn “Kungfu Thiếu Lâm Tự” nổi tiếng. Nơi nổi tiếng nhất đối với phần lớn du khách Việt khi đến đây tham quan có lẽ là Tàng Kinh các, nơi từng lưu giữ các bộ kinh sách quý về Phật pháp.
Khu vực tòa tháp Tháp Lâm – rừng tháp là một trong những nơi linh thiêng ở chùa Thiếu Lâm Tự – nơi an nghỉ của các tăng lữ đức cao vọng trọng của chùa Thiếu Lâm.
Xe đưa đoàn dùng bữa tối và nghỉ đêm tại Đăng Phong.

Ngày 3: ĐĂNG PHONG – LẠC DƯƠNG
Quý khách ăn sáng tại khách sạn, làm thủ tục trả phòng và di chuyển về thành Lạc Dương – từng là một cố đô hết sức hưng thịnh, là quê hương của ngài Đường Tam Tạng Trần Huyền Trang.
Tham quan hang đá Long Môn (bao gồm xe điện) – kỳ quan Phật giáo cổ xưa trên Thế Giới – trải qua hơn 400 năm xây dựng. Nơi đây là kiệt tác chạm khắc tiêu biểu cho thời kỳ phát triển rực rỡ của Phật giáo Trung Quốc cổ đại. Trải qua hơn 400 năm xây dựng, tính đến nay, di tích này đã có hơn 1.500 năm lịch sử với hơn 10.000 tượng Phật, hang Tân Dương, hang Cổ Dương, chùa Phụng Tiên với tượng Phật Lư Sá cao 17 mét. Đoàn dùng bữa trưa tại nhà hàng.
Ứng Thiên Môn được biết đến với tên gọi khác là Ngũ Phụng Lâu xây dựng vào năm 605, là một trong những cổng thành đặc biệt của thành phố Lạc Dương.
Thành cổ Lạc Nghị – LuoYi là tên cổ của thành Lạc Dương, gồm tháp Văn Phong, văn miếu phủ Hà Nam, di tích tường thành cổ Jinyuan… là điểm du lịch văn hóa nơi du khách có thể vui chơi, khám phá và thưởng thức ẩm thực địa phương…
Xe đưa đoàn dùng bữa tối tại nhà hàng, tự do khám phá Lạc Dương hoặc Quý khách đăng ký xem buổi biểu diễn Tầm tích Lạc Thần Phú (chi phí tự túc).
Đoàn nghỉ đêm tại Lạc Dương.

Ngày 4: LẠC DƯƠNG – HOA SƠN
Quý khách ăn sáng tại khách sạn, làm thủ tục trả phòng và đáp chuyến tàu cao tốc dự kiến G2021 (09:24 – 10:24) từ Lạc Dương đến Hoa Sơn. Xe đón đoàn dùng bữa trưa tại nhà hàng.
Đoàn đến với “Khu du lịch Núi Hoa Sơn” được mệnh danh là Ngũ Nhạc Danh Sơn – tức 5 ngọn núi gắn liền với lịch sử cổ đại Trung Hoa qua nhiều triều đại gồm: Thái Sơn, Hoa Sơn, Hành Sơn, Hằng Sơn và Tung Sơn. Hoa Sơn nằm cách thủ phủ Tây An 100km về phía Đông thuộc tỉnh Thiểm Tây, thuộc dãy Tần Lĩnh; Hoa Sơn không đơn thuần là một ngọn núi, mà còn là biểu tượng trường tồn của văn hóa và lịch sử Trung Quốc. Với chiều cao ấn tượng 2154.9 mét, ngọn núi hiên ngang được biết đến như một trong những kỳ quan thiên nhiên tuyệt mỹ và hiểm trở bậc nhất thế giới. Quý khách chiêm ngưỡng phong cảnh Hoa Sơn trứ danh từ cáp treo Bắc Phong (bao gồm xe và cáp treo khứ hồi Bắc Phong).
Xe đưa đoàn dùng bữa tối và nghỉ đêm tại Hoa Sơn.

Ngày 5: HOA SƠN – TÂY AN
Quý khách ăn sáng tại khách sạn, đoàn khởi hành khám phá đội quân đất nung:
Khu danh thắng Lăng mộ Tần Thủy Hoàng và đội quân đất nung Binh Mã Dũng là một trong mười điểm đến hấp dẫn du khách nhất tại Trung Quốc, được UNESCO công nhận là di sản văn hóa thế giới (bao gồm xe điện một chiều và tai nghe thuyết minh).
Đoàn dùng bữa trưa với chủ đề “Đại Tần tiểu yến tiệc” với văn hóa truyền thống nhà Tần làm chủ để chính và cùng thưởng thức ẩm thực mang phong cách nhà Tần.
Tường thành cổ Tây An đây là bức tường thành được đánh giá là hoàn thiện và được bảo tồn tốt nhất hiện còn tồn tại ở Trung Quốc và cũng là một trong những hệ thống phòng thủ quân sự thời cổ đại có quy mô lớn nhất thế giới được xây dựng vào thể kỷ 14.
Chiều: Quý khách khám phá con phố Đại Đường Bất Dạ Thành, đây là phố đi bộ lớn duy nhất mô phỏng các tòa nhà và nền văn hóa thịnh vượng dưới thời nhà Đường. Nơi đây tổ chức rất nhiều hoạt động văn hóa, nghệ thuật, lễ hội mang sắc màu truyền thống thời Đường và cũng là một danh lam thắng cảnh địa phương nổi tiếng về đêm thu hút rất nhiều du khách ghé thăm bởi ánh đèn lung linh lấp lánh thắp sáng xuyên đêm. Quý khách tự do khám phá ẩm thực Tây An (Đoàn ăn tối tự túc).
Đoàn nghỉ đêm tại Tây An.

Ngày 6: TÂY AN – QUẢNG CHÂU/ THẨM QUYẾN – HCM
Quý khách ăn sáng tại khách sạn, làm thủ tục trả phòng, xe đưa đoàn đến thăm Tháp Đại Nhạn – chùa Đại Nhạn, được xây dựng vào năm 652, dưới triều đại nhà Đường ban đầu có cấu trúc năm tầng tháp. Đây là nơi mà Đường Tam Tạng đã lập một khu dịch thuật kinh khổng lồ để dịch Kinh Phật từ tiếng Phạn sang chữ Hán sau khi thỉnh kinh từ Ấn Độ về.
Tham quan, mua sắm tại trung tâm thương mại Joy City. Xe đưa đoàn dùng bữa trưa tại nhà hàng, sau đó di chuyển ra sân bay làm thủ tục xuất cảnh (Giờ bay chi tiết theo ngày khởi hành). quá cảnh tại Quảng Châu/ Thẩm Quyến và nối chuyến về TP. HCM (Giờ bay chi tiết theo ngày khởi hành).
Đến TP.HCM, HDV chia tay đoàn. Hẹn gặp lại Quý khách.
** Chú ý : Thứ tự chương trình có thể thay đổi theo sự sắp xếp của Hướng Dẫn Viên để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan đã nêu trong chương trình',
    'Giá tour trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý:
Trước khi đăng ký tour du lịch xin Quý khách vui lòng đọc kỹ chương trình tour, điều khoản, giá tour bao gồm cũng như không bao gồm trong chương trình.
Trường hợp quý khách đã có visa sẽ được trừ lại 500.000 VNĐ
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân (hình ảnh, thông tin trong bản gốc bị mờ, không rỏ rang, hộ chiếu hết hạn hoặc không đúng qui định….), công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Công dân phải hoàn thành nghĩa vụ nộp thuế với nhà nước và không vi phạm pháp luật mới được xuất cảnh. Trong trường hợp cá nhân còn nợ thuế, không được phép xuất cảnh thì Công ty không chịu trách nhiệm bồi hoàn thiệt hại.
Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp trước 7 ngày khởi hành, đoàn không đủ khách, công ty có trách nhiệm và sẽ hoàn trả tiền tour.
Quý khách đã phẩu thuật thẩm mỹ vui lòng làm lại hộ chiếu mới theo hình ảnh ở thời điểm hiện tại. Nếu không nhập cảnh được do ảnh hộ chiếu khác hình ảnh thực tế, công ty du lịch không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn. (Đối với Khách hàng tách đoàn, Chi phí tách đoàn Phía cty Trung Quốc sẽ thu phí tách đoàn).
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Cty sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Trung Quốc.
Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.

Thủ tục xin visa đoàn trung quốc
Hộ chiếu: Scan hoặc chụp hình, lưu ý không được mất góc, để dẹt 180 độ, không dính ngón tay.
Hình 4×6: hình mới nhất trong vòng 6 tháng đến hiện tại, nền trắng, chụp rõ ngũ quan, không cười, không đeo trang sức, không dùng phần mềm chỉnh sửa photoshop.',
    'https://fiditour.com/wp-content/uploads/2025/12/1Kaifeng_Longting.jpg
https://fiditour.com/wp-content/uploads/2025/12/z7308414676024_78c2a50fd9fd33b63352fe6993f721a9.jpg
https://fiditour.com/wp-content/uploads/2025/12/ECB2021A27CA95FDD05C9FEA65CD9B75ADC83900_size1230_w1351_h900.png
https://fiditour.com/wp-content/uploads/2025/12/Huashan-Cable-Car.jpg
https://fiditour.com/wp-content/uploads/2025/12/z7308549843183_4ac0bad5aa55f26481513be80c3f7832.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-2026-hcm-khai-phong-lac-duong-hoa-son-tay-an-6n6d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14645', 'Đức - Áo - Ý - Thụy Sỹ - Pháp 11N10Đ',
    'Hà Nội', 'Châu Âu', '11N10Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 70 DAY) + INTERVAL 7 HOUR,
    85900000, 64425000, 20, 18, 'https://fiditour.com/wp-content/uploads/2025/12/stock-photo-eiffel-tower-paris-france-112137761.avif',
    '19h30: Xe và Hướng dẫn viên đón Quý khách tại điểm hẹn trong trung tâm thành phố, đưa ra sân bay Nội Bài, đáp chuyến bay VN35 HANMUC 23:50 06:05 của hàng không Vietnam Airlines đến Munich, Đức. Nghỉ đêm trên máy bay',
    'Ngày 1: HÀ NỘI – MUNICH ( NGHỈ ĐÊM TRÊN MÁY BAY )
19h30: Xe và Hướng dẫn viên đón Quý khách tại điểm hẹn trong trung tâm thành phố, đưa ra sân bay Nội Bài, đáp chuyến bay VN35 HANMUC 23:50 06:05 của hàng không Vietnam Airlines đến Munich, Đức.
Nghỉ đêm trên máy bay

Ngày 2: MUNICH – HALLSTATT – VILLACH
06h05: Quý khách đến Munich, làm thủ tục nhập cảnh.
Sau đó, xe đưa đoàn tham quan Munich – một trong những trung tâm kinh tế, giao thông và văn hóa quan trọng nhất ở Đức và là Thành phố cổ kính nhưng phồn hoa, Munich kế thừa những di sản kiến trúc văn hóa lâu đời cả những công trình kiến trúc cổ đại xen lẫn hiện đại. Thành phố không có nhà chọc trời vì theo quy định mọi công trình kiến trúc – xây dựng của thành phố đều không được cao quá 109m. Thành phố Munich là thành phố lớn thứ ba của Đức sau Berlin và Hamburg. Hàng năm, Munich là nơi tổ chức lễ hội bia Oktoberfest lớn nhất thế giới thu hút hàng triệu lượt du khách đến tham quan. Munich cũng là một trong những điểm đến nổi tiếng của du lịch Đức nói riêng và du lịch Châu Âu nói chung.
Đoàn đi tham quan:
Tháp đồng hồ Rathaus-Glockenspiel: Tháp đồng hồ nổi bật với 43 quả chuông và 32 bức tượng lớn, mô tả đám cưới của công tước Wilhelm V.
Quảng trường trung tâm Marienplatz: Quảng trường Đức Mẹ Marienplatz có từ năm 1158, là khu chợ trung tâm và là nơi tổ chức lễ hội, các cuộc thi đấu tài năng thời Trung cổ. Trước tòa thị chính được xem là nơi tập trung các hoạt động văn hóa và là điểm thu hút khách du lịch vào bậc nhất.
Qúy khách tự do thăm quan mua sắm
12h00: Quý khách ăn trưa tại nhà hàng.
Quý khách khởi hành tới làng cổ Hallstatt (205km – hơn 3h di chuyển) – thị trấn bên hồ đẹp nhất thế giới, được UNESCO công nhận Di Sản Văn Hoá Thế Giới.
HDV đưa Quý khách đi tham quan:
Làng cổ Hallstatt: Xứ sở thần tiên của nước Áo xinh đẹp. Ngôi làng nằm bên bờ hồ Hallstätter See, được bao quanh bởi dãy Alps hùng vĩ và rừng cây xanh với thảm thực vật đa dạng.
Hồ Hallstätter See có mặt nước trong xanh phản chiếu những ngôi nhà cổ kính, tạo nên một khung cảnh kiến trúc hòa hợp với thiên nhiên đẹp như tranh vẽ giữa trời tây.
Quảng trường chợ trung tâm Hallstatt: Là trung tâm chính của thị trấn, nơi đây là điểm gặp gỡ phổ biến của người dân địa phương và điểm thu hút đa số khách du lịch. Tại quảng trường có bức tượng Chúa Ba Ngôi và xung quanh là các quán cà phê xinh đẹp, nhà hàng cùng những quầy lưu niệm. Trong suốt cả năm, nơi đây diễn ra các sự kiện khác nhau như lễ rước kiệu Corpus Christi truyền thống vào mùa xuân, các buổi hòa nhạc và chợ Giáng sinh đáng yêu vào mùa đông
Sau khi tham quan Hallstatt đoàn khởi hành về Villach (cách 175 km) – thành phố lớn thứ nhì ở bang Kärnten và lớn thứ bảy ở Áo, nằm ở miền nam nước Áo, tọa lạc bên sông Drau và là đầu mối giao thông quan trọng của Áo và toàn vùng Alpe-Adria và tự do tham quan. Đây là một trong những thành phố đẹp ở Áo có lịch sử phát triển từ rất lâu đời. Du khách khi tới đây sẽ dễ dàng phải xao xuyến trước phong cảnh đẹp ngất ngây được bao quanh vùng nông thôn yên tĩnh.
Tối: Quý khách ăn tối tại nhà hàng
Nghỉ đêm tại khách sạn Harry´s home hoặc 4* tương đương tại Villach

Ngày 3: VILLACH – VENICE – MESTRE/PADOVA
Sáng: Quý khách ăn sáng tại khách sạn. Sau đó quý khách tạm biệt nước Áo và bắt đầu di chuyển đến thành phố Venice (cách 240km – 3h di chuyển) đầy thơ mộng. Venice là một thành phố tuyệt vời, nằm ở phía Đông Bắc của Italia, khi đến đây, du khách có thể hình dung một cách tổng quan Venice trông giống như một mạng nhện khổng lồ được tạo lên bởi 118 đảo và 175 kênh đào, các đảo nối với nhau bởi 444 cây cầu. Venice luôn giữ được vẻ đẹp vừa lãng mạn, thơ mộng, vừa yên ả, êm đềm.
Trưa: Quý khách ăn trưa tại nhà hàng
Chiều: Đoàn khởi hành tới bến thuyền, sau đó quý khách lên thuyền tới đảo Venice. Dọc theo các kênh đào ngắm nhìn các kiến trúc tuyệt vời và các nhà thờ cổ.
Quảng trường thánh Piazza San Marco: một quần thể rộng lớn với nhà thờ Basilica di San Marco, tháp chuông Campanile, tháp đồng hồ Torre dell’Orologio, và khu vực quảng trường dài 175m, rộng 82m, và có sức chứa hàng nghìn người.
Tháp chuông St. Mark: nằm ở Quảng trường San Marco gần nhà thờ. Tháp chuông mở cửa hàng ngày từ sáng sớm đến chiều tối và phục vụ muộn hơn vào tháng 7 và tháng 8.
Cung điện Doge’s Palace: từng là nơi ở của Doge, người cai trị của Venice sau khi xây dựng nên một đế chế ở vùng đất này, cung điện nguy nga tráng lệ này là trụ sở của chính phủ và có kiến trúc và trang trí mang phong cách Gothic
Thăm quan cây cầu Bridge of Sighs – cầu than thở có tên gốc Ponte dei Sospiri, là một trong những cây cầu nổi tiếng nhất thành Venice, Italy. Ponte dei Sospiri được thiết kế cong mỹ miều, làm từ đá vôi trắng và có các cửa sổ hình chữ nhật bé xíu phủ lưới bên ngoài. Trong thế kỷ 17, nhiệm vụ của cây cầu này là dẫn tù nhân từ phòng thẩm vấn ở cung điện Doge tới phòng giam ở nhà tù Prigioni.
Tự do thăm quan, chiêm ngưỡng, mua sắm đồ lưu niệm những sản phẩm thủy tinh được tạo ra từ cát mịn và cách pha mầu độc đáo bằng kim loại được các nghệ nhân sáng tạo khéo léo tạo ra những sản phẩm độc nhất vô nhị, từ những chiếc đèn chùm lộng lẫy đến các vật dụng nhỏ xinh xắn không chỉ là món quà tuyệt vời mà còn là món đồ tượng trưng văn hóa tinh thần của người dân nơi đây.
Trải nghiệm thuyền Gondola: dập dềnh trên những kênh đào của thành phố Venice nên thơ và vô cùng lãng mạn trên hòn đảo được mệnh danh là “City of Love” (chi phí tự túc)
Thưởng thức món kem Ý nổi tiếng tại nơi đây (Chi phí tự túc)
17h00: Quý khách lên thuyền quay trở lại đất liền
Tối: Quý khách dùng bữa tại nhà hàng
Nghỉ đêm tại AC Hotel Padova by Marriott hoặc 4* tương đương tại Padova/Treviso.

Ngày 4: MESTRE – MILAN
Sáng: Sau khi ăn sáng tại khách sạn, quý khách khởi hành tới Milan (275 km – hơn 3h di chuyển) – “thủ đô thời trang” của thế giới. Ở đây du khách sẽ cảm nhận được nhiều góc cạnh đa dạng khác ngoài thương hiệu thời trang thế giới bất di dịch của thành phố này. Nếu có dịp khám phá sâu hơn vào nhiều ngõ ngách của thành phố, du khách sẽ thấy bức tranh muôn màu của nó, có nền chính đặc sắc là nét kiến trúc đặc trưng đầy khoe mẽ nhưng hết sức kín đáo.
12h00: Quý khách ăn trưa tại nhà hàng
Sau bữa trưa, HDV đưa Quý khách đi tham quan:
Quảng trường Piazza del Duomo: từ đây, du khách có thể chiêm ngưỡng rất nhiều công trình nổi tiếng của Ý, đồng thời hiểu hơn về văn hóa, lối sống của người dân nơi đây
Nhà thờ Milan Duomo: có quy mô lớn nhất nước Ý và xếp thứ hai tại Châu Âu. Được xây dựng trong thời gian dài hơn 6 thế kỷ, du khách sẽ choáng ngợp trước sự hoành tráng với nhà thờ cao 108 mét này. Tổng thể kiến trúc của nhà thờ Duomo di Milano mang phong cách kiến trúc Gothic kết hợp Roman vô cùng độc đáo.
Nhà hát Opera La Scala – biểu tượng nghệ thuật và lịch sử ở Milan, đây là một trong những nhà hát nổi tiếng nhất thế giới. Với lịch sử lâu đời và vẻ đẹp kiến trúc độc đáo, La Scala thu hút những người yêu nghệ thuật và âm nhạc từ khắp nơi.
Tượng đài Leonardo Da Vinci: nằm ở quảng trường Piazza della Scala của Milan và được khánh thành vào năm 1872. Đài tưởng niệm này được dùng để tưởng nhớ vị nghệ sĩ tuyệt vời Leonardo da Vinci cũng như thể hiện tình cảm đối với người nghệ sĩ vĩ đại này.
Castello Sforzesco: pháo đài thời trung cổ nằm ở Milan, miền Bắc nước Ý. Nó được xây dựng vào thế kỷ 15 bởi Francesco Sforza, Công tước Milan. Đây là một trong những tòa thành cổ lớn nhất ở Châu Âu
Khám phá khu mua sắm Galleria Vittorio Emanuele II: phòng trưng bày mua sắm còn hoạt động lâu đời nhất của Ý và là địa danh chính của Milan
18h30: Quý khách ăn tối tại nhà hàng
Quý khách có thể tự do dạo chơi tại khu vực Navigli, nơi có nhiều quán cà phê, nhà hàng và nghệ sĩ đường phố và trung tâm mua sắm sôi động
Nghỉ đêm tại khách sạn Best Western Hotel Golden Mile hoặc 4* tương đương tại Milan

Ngày 5: MILAN – COMO – ENGELBERG/LUCERNE
Sáng: Sau khi ăn sáng tại khách sạn, Quý khách khởi hành đi thăm quan Hồ Como (50km ~ 1h di chuyển) – viên ngọc quý xinh đẹp của nước Ý, với dãy núi Alps phủ tuyết trắng và những ngôi làng đẹp như tranh vẽ trên mặt nước bao bọc. Hồ có hình chữ Y lộn ngược với hai nhánh nối với nhau tại Bellagio. Ở bên nhánh trái Quý khách sẽ tìm thấy các thị trấn như Cernobbio, Blevio, Tremezzo và Nesso. Nếu Quý khách muốn ngắm hoa tử đằng tím quanh hồ Como thì nhớ ghé thăm vào tháng 4 khi loài hoa này vào mùa.
Sau đó đoàn di chuyển tới Thị trấn Engelberg (cách 205 km ~ 3h di chuyển) – một thị trấn nhỏ, nép mình dưới thung lũng xanh mướt, sát cạnh ngọn núi tuyết nổi tiếng Titlis.
Quý khách ăn trưa tại nhà hàng.
Chiều: Quý khách có thể tham quan Núi tuyết Titlis. Quý khách mua vé cáp treo để chiêm ngưỡng vẻ đẹp hùng vĩ được tuyết bao phủ của dãy núi Alps. Trải nghiệm cáp treo quay 360o trên không đầu tiên của thế giới, chiêm ngưỡng phong cảnh tuyệt đẹp từ sông băng ở độ cao 3200m (so mực nước biển). Cáp treo kéo dài 45 phút vượt qua rặng núi hùng vĩ cao vút phủ trắng tuyết, sườn dốc đứng, qua những hồ nước, những cánh rừng thông, thung lũng xanh rì ngập tràn hoa để tới dãy Alps ngắm nhìn kẽ nứt sông băng. (chưa gồm vé cáp treo đỉnh núi Titlis)
Sau đó xe đưa Quý khách tới thành phố Lucerne (45km – 50p di chuyển) – thành phố nhỏ bé nằm bên bờ hồ xinh đẹp, với các thị trấn mang dáng dấp thời Trung cổ, cùng cảnh quan thơ mộng là một trong những địa điểm thu hút khách du lịch nhiều nhất ở Thụy Sĩ. Thăm quan:
Cầu cổ Chapel: cây cầu có mái che cổ nhất ở châu Âu, bắc qua dòng sông Reuss. Điều thú vị là khi tản bộ trên cây cầu này, du khách sẽ được chiêm ngưỡng những bức họa cổ nổi tiếng treo dọc hai bên thành cầu. Cùng với Tháp nước Waaseturn nằm kề bên, cầu Chapel được xem là biểu tượng nhận diện của thành phố này khi xuất hiện trên các tấm bưu thiếp.
Hồ Lucerne – Đẹp và thơ mộng tựa như tranh vẽ.
Tự do mua sắm tại siêu thị đồng hồ Thụy Sỹ lớn nhất của Lucerne – siêu thị Bucherer
Tối: Quý khách ăn tối tại nhà hàng.
Đoàn nghỉ ngơi tại khách sạn 3* tại Lucerne/Engelberg.

Ngày 6: ISELTWALD – INTERLAKEN – ZURICH – TITISEE
Sáng: Sau khi ăn sáng tại khách sạn, Đoàn di chuyển thăm quan và chụp ảnh Làng Iseltwald (80 km) – một ngôi làng nhỏ và xinh đẹp với những căn nhà gỗ nép mình bên ven hồ Brienz tạo nên cảnh sắc đặc trưng của Thụy Sĩ. Làng Iseltwald còn là nơi có những cảnh quay đắt giá đầy mê hoặc trong bộ phim Crash Landing on You (Hạ cánh nơi anh).
Xe và HDV đưa Đoàn đến Thị trấn Interlaken – là một thị trấn nằm ở khu vực trung tâm của Thụy Sĩ, được bao quanh bởi những ngọn núi hùng vĩ và hồ nước tuyệt vời. Thị trấn nằm giữa hai hồ nước lớn là hồ Thun và hồ Brienz, tạo nên không gian thiên nhiên tuyệt vời với cảnh đẹp hùng vĩ và hấp dẫn. Thị trấn Interlaken cũng là nơi hai nhân vật chính của bộ phim “Hạ cánh nơi anh” Yoon Se-ri và Ri Jung-hyuk đi dạo quanh thị trấn và trải qua những khoảnh khắc lãng mạn và đầy cảm xúc.
Sau đó, xe và HDV đưa đoàn khởi hành đi Zurich (110km ~ hơn 1h50 di chuyển) – thành phố lớn nhất Thụy Sĩ, nằm bên bờ hồ Zurich và sông Limmat. Đây là trung tâm thương mại và văn hóa quan trọng, nổi tiếng với vẻ đẹp cổ kính, kiến trúc độc đáo và các bảo tàng nghệ thuật. Zurich còn được biết đến với chất lượng cuộc sống cao.
Đoàn dùng bữa trưa tại nhà hàng.
Đoàn tham quan:
Đồi Lindenhof: Từ đây Quý khách có thể phóng tầm mắt qua phía bên kia của thành phố, ngăn cách bởi dòng sông Limmat xanh ngắt và cực kì trong. Ở Thụy Sĩ hồ nước, dòng sông nào cũng sạch vô cùng.
Nhà thờ Grossmunster: Nhà thờ này nổi bật với 2 tòa tháp “sinh đôi” vươn mình lên cao đầy uy nghiêm là 1 trong 3 nhà thờ chính của thành phố
Hồ Zürich: Hồ nước tự nhiên lớn nhất Thụy Sĩ và được công nhận là một trong những hồ nước tự nhiên đẹp nhất thế giới. Được bao quanh bởi hàng loạt ngôi nhà, công trình kiến trúc rực rỡ sắc màu, mặt hồ yên sóng, xanh trong, tất cả vẽ nên bức tranh vô cùng lung linh, tuyệt mỹ.
Đoàn tiếp tục đến Titisee (98km ~ 1h50’ di chuyển) – hồ nước tuyệt đẹp nằm ở trung tâm Rừng Đen – Black Forest (Schwarzwald) tại Đức, nổi tiếng với cảnh quan thiên nhiên hùng vĩ và các hoạt động ngoài trời như bơi lội, chèo thuyền và đi bộ đường dài. Đến nơi đoàn tham quan:
Hồ Titisee có diện tích khoảng 1,3 km² và độ sâu trung bình là Hồ được hình thành từ sự tan chảy của băng hà Feldberg trong kỷ Pleistocen, tạo nên một cảnh quan tuyệt đẹp với những bờ hồ được bao quanh bởi rừng cây xanh tươi.
Quí khách tham quan cửa hàng và nơi sản xuất đồng hồ cuckoo, hay còn gọi là đồng hồ chim cúc cu, là một biểu tượng văn hóa đặc trưng của vùng Rừng Đen (Schwarzwald) ở Đức,. Những chiếc đồng hồ này nổi tiếng với thiết kế tinh x xảo và âm thanh đặc trưng của chim cúc cu vang lên mỗi giờ.
Sau đó đoàn di chuyển đến Freiburg, đoàn ăn tối tại nhà hàng.
Nghỉ đêm tại khách sạn 3* tại Freiburg.

Ngày 7: TITISEE – COLMAR – CHỢ GIÁNG SINH/TỰ DO MUA SẮM
Sáng: Sau khi ăn sáng tại khách sạn, đoàn khởi hành đi Colmar (90 km) – Đây là thành phố lớn thứ ba của vùng Alsace, sau Strasbourg và Mulhouse. Thành phố được ví von như tiểu Venice “La petite Venise” với những căn nhà gỗ nhỏ xinh bên bờ kênh.
HDV đưa Quý khách đi thăm quan làng cổ Colmar một ngôi làng nhỏ xinh xắn vùng Alsace nước Pháp. Hãy tưởng tượng một thị trấn nhỏ yên bình với những con đường lát đá men theo những con kênh.
Hai ngôi nhà cổ Maison des Têtes và Maison Pfister: được xây dựng theo lối kiến trúc Trung cổ với những bức vẽ trên tường đã xỉn màu theo thời gian; trong đó ngôi nhà Maison Pfister từng được dùng làm hình mẫu thiết kế cho bộ phim viễn tưởng nổi tiếng của Nhật Bản mang tên “Howl’s Moving Castle”
La Petite Venice – Tiểu Venice của nước Pháp: những căn nhà gác mái dốc ngói lợp được phối màu tạo thành những hoa văn tinh tế, những con đường lát đá hoa cương chẻ thành từng ô vuông xinh xắn giữa các ban công đều trồng những khóm hoa màu sắc rực rỡ; tất cả tạo cho Colmar một không gian thơ mộng, quyến rũ, lãng mạn như bước ra từ cổ tích.
Đoàn dùng bữa trưa tại nhà hàng.
Sau bữa trưa, đoàn tham quan chợ giáng sinh tại Colmar.
Vào mùa Giáng sinh, vẻ đẹp cổ kính của Colmar càng trở nên quyến rũ hơn. Những ngôi nhà gỗ nhiều màu sắc được trang trí bằng đèn và các ornament Giáng sinh, tạo nên một khung cảnh như bước ra từ truyện cổ tích. Chợ Giáng sinh Colmar là một trong những chợ Giáng sinh nổi tiếng nhất nước Pháp. Với hơn 180 gian hàng được bày trí tại 6 địa điểm khác nhau trong thành phố, chợ Giáng sinh Colmar mang đến không gian lễ hội đậm chất truyền thống. Du khách có thể tìm thấy đủ loại đồ thủ công mỹ nghệ, đồ trang trí Giáng sinh và các món ăn đặc trưng của vùng Alsace.
Quý khách dùng bữa tối tại nhà hàng.
Nghỉ đêm tại khách sạn 4* tại Colmar/Mulhouse.

Ngày 8: COLMAR – PARIS
07h00: Ăn sáng tại khách sạn
08h00: Đoàn khởi hành đi Saint Dizer (cách Colmar 240km ~ 3,5h di chuyển).
Quý khách ăn trưa tại nhà hàng.
13h30: Xe đưa đoàn khởi hành về Paris (215km – hơn 3h di chuyển) – là thủ đô của nước Pháp và cũng là trung tâm hành chính của vùng Île de la France (một trong những khu vực kinh tế quan trọng nhất thế giới). Nằm ở phía Bắc nước Pháp, khu vực trung tâm của châu Âu, Paris được xây dựng hai bên bờ sông Seine với tâm là đảo Île de la France Île de la Cité. Paris có một lịch sử lâu đời, gắn liền với lịch sử Pháp và cả châu Âu. Ngày nay, thành phố tiếp tục là một trung tâm văn hóa, kinh tế của cả thế giới.
Tối: Quý khách ăn tối tại nhà hàng.
Nghỉ đêm tại khách sạn Brit Hotel Paris Rosny sous bois hoặc 4* tương đương

Ngày 9: PARIS
07h00: Ăn sáng tại khách sạn.
08h00: HDV đưa đoàn đi tham quan:
Đại lộ Champs – Elysees – dài gần 2km và rộng 70m, Đại lộ Champs-Élysées tập trung tất cả những tinh hoa về kiến trúc, lịch sử, văn hóa, những shop thời trang thời thượng, những nhà hàng sang trọng và những nhà hát lớn nhất của Paris đầy hoa lệ.
Khải hoàn môn Arc De Triomphe – là một trong những công trình nổi tiếng nhất Paris và cùng với đại lộ Champs-Elysées đây là địa điểm tổ chức các lễ hội, sự kiện quan trọng của thành phố được khởi công xây dựng vào năm 1806 trên quảng trường Étoile, theo quyết định của hoàng đế Napoléon Bonaparte, sau chiến thắng Austerlitz, như là một công trình vinh danh quân đội, kỉ niệm chiến thắng lẫy lừng của các đạo quân Pháp. Nhưng Đệ nhất đế chế của hoàng đế Napoléon khiến sụp đổ việc thi công Khải Hoàn Môn bị đình lại. Tới năm 1825, công trình mới được tiếp tục. Năm 1836, Khải Hoàn Môn được vua Louis-Philippe khánh thành.
Bảo tàng Louvre – là một cung điện cũ của Hoàng gia Pháp, nằm ở trung tâm thủ đô Paris, phần lớn diện tích cung điện được sử dụng cho bảo tàng Louvre, một trong những bảo tàng lớn nhất thế giới. Tại đây, Quý khách sẽ được chiêm ngưỡng bản gốc tác phẩm hội họa lừng danh Monalisa (tham quan bên ngoài)
12h00: Quý khách Ăn trưa tại nhà hàng
Quý khách tiếp tục thăm quan
Tháp Eiffel – biểu tượng của Paris (quý khách chụp ảnh bên tháp Eiffel)
Đi du thuyền dọc sông Seine – Quý khách có cơ hội được ngắm nhìn thành phố với các công trình tuyệt mỹ hai bên (Bao gồm vé du thuyền)
Tham quan nhà thờ Đức Bà Paris – là một biểu tượng văn hóa nổi tiếng của toàn thể người dân nước Pháp. Nó là niềm tự hào, niềm kiêu hãnh của toàn thể người dân Pháp nói riêng và của cả nhân loại nói chung. Nhà Thờ Đức Bà Paris là trung tâm của thành phố Paris và của cả nước Pháp bởi vì mọi khoảng cách gần xa đều được tính từ nơi này và trước Nhà Thờ là tấm bảng đồng ghi rõ “Cây Số Không” (Kilomètre Zéro). Nhà thờ đã biến thành một huyền thoại sống mà người ta không ngừng khám phá trở lại những khía cạnh mới qua những thời gian và không gian khác nhau.
Tự do tham quan và mua sắm tại Galeries Lafayette – đây là một trong 10 trung tâm mua sắm sang trọng nhất thế giới – là điểm đến thú vị mà du khách không nên bỏ lỡ khi đến với nước Pháp. Galeries Lafayette nằm ở đại lộ Haussmann, gồm ba khu lớn. Cửa hàng thời trang nam giới nằm ở góc phố Mogador và đại lộ Haussmann gồm 4 tầng bán hàng, trong đó tầng hai là siêu thị thực phẩm và rượu. Lối ra từ tàu điện ngầm và RER dẫn thẳng vào của hàng này. Phía đối diện qua góc phố Mogador là cửa hàng thời trang nữ gồm 7 tầng, bên trên tầng của hai cửa hàng này được nối với nhau bằng chiếc cầu trên phố Mogador, cũng là nơi bán kính thời trang. Cuối cùng là khu Lafayette Maison nằm đối diện với cửa hàng thời trang nam qua đại lộ Haussmann, là nơi bán các đồ nội thất sang trọng.
18h30: Ăn tối tại nhà hàng.
Nghỉ đêm tại khách sạn Brit Hotel Paris Rosny sous bois hoặc tương đương.

Ngày 10: PARIS – HÀ NỘI
Sáng: Quý khách ăn sáng và làm thủ tục trả phòng khách sạn.
09h30: HDV và Xe đưa quý khách ra sân bay để đáp chuyến bay VN018 từ Paris về Hà Nội CDG – HAN/ VN018 (13.10-06.30)
Quý khách nghỉ ngơi trên máy bay.

Ngày 11: NỘI BÀI/HÀ NỘI
06h30: Về đến sân bay Nội Bài, Quý khách làm thủ tục nhập cảnh lại Việt Nam, xe và HDV đưa quý khách về lại điểm đón ban đầu, chia tay và hẹn gặp lại quý khách trong những hành trình tiếp theo.
HDV chia tay và hẹn gặp lại quý khách
Lưu ý: Hành trình thăm quan có thể thay đổi thứ tự điểm đến tùy vào điều kiện thời tiết thực tế nhưng vẫn đảm bảo đủ điểm thăm quan như chương trình',
    'Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Thủ tục xin visa
Hộ chiếu gốc mới nhất (kèm theo hộ chiếu cũ nếu có) – Hộ chiếu sử dụng cần có giá trị ít nhất 6 tháng tính đến ngày xuất cảnh và còn ít nhất hai trang visa trống
02 ảnh nền trắng – Kích thước 3,5 cm x 4,5 cm phóng to mặt 80%, rõ mặt, hở trán, tai (ảnh mới chụp trong vòng 6 tháng gần đây).
Giấy tờ chứng minh nghề nghiệp
Khách hàng đang công tác tại công ty/cơ quan: Hợp đồng lao động bản sao y công chứng, bảng lương 6 tháng bản gốc hoặc sao kê lương, Bản chụp màn hình VSSID tiếng anh, đơn xin nghỉ phép đi du lịch (bản gốc)
Khách hàng là Giám đốc Doanh Nghiệp: Giấy ĐKKD bản sao y, Báo cáo thuế 6 tháng, Giấy nộp tiền ngân sách nhà nước.
Khách hàng là Chủ Hộ Đăng Ký Kinh Doanh cá thể: Giấy ĐKKD bản sao y, biên lai nộp thuế.
Khách hàng là hưu trí: Quyết định hưu hoặc Thẻ hưu hoặc sổ hưu sao y công chứng
Khách hàng là sinh viên, học sinh: Thẻ học sinh sao y công chứng, đơn xin nghỉ học có xác nhận nhà trường (bản gốc)
Giấy tờ chứng minh khả năng tài chính cá nhân:
Sao kê tài khoản lương/ tài khoản giao dịch nhiều nhất trong 6 tháng gần nhất và số dư cuối kỳ sao kê tối thiểu là 50.000.000vnđ hoặc nhiều hơn.
Sổ tiết kiệm tối thiểu 200.000.000VNĐ (photo mặt sổ), Xác nhận số dư STK (bản gốc có dấu đỏ của ngân hàng)
Đề nghị chỉ đi lấy sao kê khi Sales thông báo, không đi xin sao kê sớm quá tránh trường hợp giá trị sao kê không còn hiệu lực
Sổ đỏ (photo công chứng)
Đăng ký xe ô tô (nếu có – photo công chứng)
Hợp đồng thuê nhà photo công chứng nếu có
Giấy tờ nhân thân và mối quan hệ ràng buộc tại Việt Nam
Đăng ký kết hôn (nếu đã lập gia đình) (photo công chứng)
Sổ hộ khẩu photo hoặc xác nhận cư trú CT07 Bản gốc
Căn cước công dân photo
Giấy khai sinh của các con photo công chứng ( Nếu có)
Tờ khai thông tin cá nhân theo mẫu',
    'https://fiditour.com/wp-content/uploads/2025/11/image.jpg
https://fiditour.com/wp-content/uploads/2025/11/TourCungDienDogeVaVuongCungThanhDuongSaintMarkVoiVeVaoCuaNhanh.jpg
https://fiditour.com/wp-content/uploads/2025/11/Italya_Nha-tho-Duomu-.png
https://fiditour.com/wp-content/uploads/2025/11/engelberg-blick-ueber-den-ort-01-1500x1000-1.jpg
https://fiditour.com/wp-content/uploads/2025/11/6ys6z5or3xkoh6excphjgz3oot42_shutterstock_1450103699.webp
https://fiditour.com/wp-content/uploads/2025/11/anh-bai-blog-web-4-1024x768-1.webp',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/ha-noi-duc-ao-y-thuy-sy-phap-11n10d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14555', 'Bắc Kinh - Tô Châu - Hàng Châu - Thượng Hải 7N6Đ',
    'Hà Nội', 'Trung Quốc', '7N6Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 73 DAY) + INTERVAL 7 HOUR,
    22490000, 16868000, 20, 18, 'https://fiditour.com/wp-content/uploads/2025/11/du-lich-hang-chau-trung-quoc-cam-nang-du-lich-xuan-ha-thu-dong-6875ba757037a.jpg',
    '06h00: Xe đón Quý khách tại điểm tập trung rời Hà Nội ra sân bay Nội Bài làm thủ tục chuyến bay VN512 (10h00 – 14h30) rời Hà Nội đi Bắc Kinh. Đến Bắc Kinh, Xe đón Quý khách về khách sạn nhận phòng nghỉ. Quý khách dùng bữa tối tại nhà hàng…',
    'Ngày 1: HÀ NỘI – BẮC KINH ( ĂN NHẸ TRÊN MÁY BAY, TỐI )
06h00: Xe đón Quý khách tại điểm tập trung rời Hà Nội ra sân bay Nội Bài làm thủ tục chuyến bay VN512 (10h00 – 14h30) rời Hà Nội đi Bắc Kinh.
Đến Bắc Kinh, Xe đón Quý khách về khách sạn nhận phòng nghỉ.
Quý khách dùng bữa tối tại nhà hàng với món đặc sản Vịt Quay Bắc Kinh.
Nghỉ đêm tại khách sạn.

Ngày 2: BẮC KINH
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn khởi hành đi tham quan:
Vạn Lý Trường Thành – kỳ quan duy nhất có thể nhìn thấy từ mặt trăng – Quý khách trải nghiệm cảm giác thú vị khi đặt từng bước trên con đường kiệt tác này.
Trưa: Sau khi tham quan Bức tường thành thế kỷ, Quý khách dừng chân dùng bữa tại nhà hàng địa phương.
Chiều: Quý khách thăm quan:
Phố cổ Nam La – níu chân khách bởi vẻ đẹp cổ kính và bầu không khí văn hóa đậm đà mà còn níu chân thực khách bởi nền ẩm thực phong phú, đa dạng. Dạo bước dọc theo con ngõ, du khách có thể bắt gặp vô số nhà hàng và quán ăn lâu đời, nơi lưu giữ những tinh hoa ẩm thực Bắc Kinh xưa…
(Vào tháng 3–4 mùa hoa anh đào đoàn sẽ tham quan Công Viên Ngọc Uyên Đàm – là 1 trong 11 công viên lớn của Bắc Kinh & là một trong những biểu tượng mùa xuân Nhật Bản với sắc hồng nhẹ nhàng, sắc trắng tinh khôi của những cây hoa anh đào tại Bắc Kinh. Ngày nay, công viên là địa điểm tổ chức “Lễ hội hoa anh đào” mỗi mùa xuân, thu hút du khách từ khắp nơi trên thế giới. Nổi bật nhất là vườn hoa anh đào với hơn 2.000 cây hoa, nhiều giống khác nhau, tạo nên khung cảnh rất lãng mạn vào mùa xuân).
Thưởng thức cá sản phẩm Cao su.
Tối: Quý khách nghỉ đêm tại khách sạn ở Bắc Kinh.

Ngày 3: BẮC KINH
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn khởi hành đi tham quan:
Quảng Trường Thiên An Môn – trung tâm chính trị của Bắc Kinh với Đại Lễ Đường, Lăng Mao Chủ Tịch, Tượng đài anh hùng liệt sỹ.
Cố Cung (Tử Cấm Thành) – biểu tượng Chính Trị cuả đất nước Trung Hoa, với 9999 gian điện nguy nga, tráng lệ lớn nhất thế giới, nơi trị vì của 2 triều đại Minh Thanh, Đức Thắng Môn.
Lưu ý: Hiện nay Cố Cung 1 ngày chỉ đón tiếp 30.000 lượt khách tham quan, tình hình vé thắng cảnh đang vào dịp cao điểm đặc biệt khó khăn để mua được vé cho đoàn. Nên trong trường hợp không mua được vé tham quan Cố Cung, đoàn sẽ chuyển sang tham quan 1 trong 2 chương trình sau:
+) Tham quan Thiên Đàn
+) Tham quan Cung Vương Phủ – Phủ Hòa Đại Nhân
Trưa: Quý khách dừng chân dùng bữa tại nhà hàng địa phương.
Chiều: Đoàn đi tham quan
Di Hoà Viên – Cung điện mùa hè của các vua chúa đời Minh, Thanh với Cung Từ Hy, Tháp Dâng Hương, Hồ Côn Minh, Vạn Thọ Đường. Quý khách tham quan kiểm tra sức khỏe miễn phí tại Nhà Thuốc gia truyền Đồng Nhân Đường.
Tự do đi mua sắm tại Vương Phủ Tỉnh – con phố sầm uất nhất Bắc Kinh
Tối: Đoàn dùng vữa tối tại nhà hàng và nghỉ đêm tại khách sạn ở Bắc Kinh.

Ngày 4: BẮC KINH – TÔ CHÂU
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn ra ga lên tàu cao tốc rời Bắc Kinh đi Tô Châu ( Khoảng 5 tiếng ) – thành phố Tô Châu xinh đẹo nằm ở phía nam tỉnh Giang Tô trên đồng bằng sông Trường Giang. Người Trung Quốc có câu “Trên có thiên đàng, dưới có Tô Hàng”. Tô Châu là 1 trong 24 thành phố đầu tiên được liệt kê vào danh sách thành phố di tích văn hóa của Trung Quốc.
Trưa: Quý khách ăn trưa tại nhà hàng, sau đó đoàn bắt đầu đi tham quan Tô Châu:
Phố Cổ Thất Lý Sơn Đường – Nét lãng mạn của trấn nước Giang Nam. Là một khu phố có lịch sử hàng nghìn năm của tỉnh Giang Tô, chỉ cách Tô Châu chưa tới 30 phút di chuyển. Đây là một trong những điểm du lịch nổi tiếng với những toà nhà được xây dựng hai bên sông, được trang hoàng đèn lng đỏ rực, mang đến cảm giác nhẹ nhàng, lãng mạn đúng chất Giang Nam.
Tìm hiểu văn hóa tơ lụa.
Tối: Quý khách dùng bữa tại nhà hàng và nghỉ đêm ở khách sạn địa phương.

Ngày 5: TÔ CHÂU – HÀNG CHÂU
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn lên đường di chuyển đến Hàng Châu.
Trưa: Đến Hàng Châu, quý khách đi dùng bữa tại nhà hàng, sau đó đoàn tham quan:
Quý khách ngồi thuyền thưởng ngoạn Tây Hồ – được xem là đẹp và nên thơ nhất trong hơn 36 hồ có cùng tên ở Trung Quốc, nhìn ngắm Quả sơn, Đoạn kiều, Trường kiều, Tô Đê Bạch Đê, Tam Đàn Ấn Nguyệt và Hoa Cảng Quan Ngư (bên ngoài) gắn liền với những truyền thuyết về Lương Sơn Bá – Chúc Anh Đài, nhà thơ Lý Bạch, Thanh xà – Bạch xà.
Check in Đập Tô Đê – đây là con đường ven hồ nổi tiếng chạy xuyên mặt nước, hai bên là hàng cây rợp bóng.
Check in Cô Sơn là một hòn đảo nhỏ nằm ngay giữa Tây Hồ — cảnh rất thơ, hơi hoài cổ và rất dễ chụp hình đẹp, cực nhiều góc xanh đẹp để đi dạo, chụp ảnh.
Đoàn ghé thăm thưởng thức nghệ thuật pha trà Trung Quốc, thưởng thức quốc trà Trung Quốc, trà Long tỉnh, đứng đầu trong thập đại danh trà Trung Hoa.
Tối: Quý khách dùng bữa tại nhà hàng và nghỉ đêm tại khách sạn ở Hàng Châu.
Sau bữa tối Quý khách có thể thưởng thức chương trình biểu diễn đặc sắc trong Tống Thành Thiên Tình Cổ – là ѕhoᴡ biểu diễn độc đáo thể hiện lại các giai thoại ᴠề những câu chuуện nổi tiếng tại mảnh đất Hàng Châu. Đâу là một nét ᴠăn hóa đặc trưng tiêu biểu nhất mà bất cứ du khách nào khi du lịch Trung Quốc đến đâу cũng mong được thưởng thức (chi phí tự túc – 380 tệ).

Ngày 6: HÀNG CHÂU – THƯỢNG HẢI
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn đi tham quan:
Miếu Nhạc Phi – là nơi an nghỉ và thờ phụng vị tướng tài ba của thời Nam Tống là Nhạc Phi. Đây là một địa điểm tâm linh quan trọng của người Trung Quốc đồng thời cũng rất thu hút những du khách muốn tìm hiểu về các vị danh tướng trong lịch sử nước này.
Tìm hiểu công nghệ sản xuất và mua sắm đồ gia dụng làm bếp.
Trưa: Quý khách dùng bữa tại nhà hàng. Sau bữa trưa, xe và HDV đưa đoàn về Thượng Hải – thành phố lớn của Trung Quốc với những kiến trúc Phương Tây hiện đại.
Đến Thượng Hải, xe và HDV đưa đoàn đi tham quan
Đại cầu Nam phố, khu mới phố đông. Bến Thượng Hải, từ đây có thể chụp ảnh toàn cảnh các công trình kiến trúc nổi tiếng như tháp truyền hình Đông Phương Minh Châu, tháp Kim Mậu, Trung tâm Tài chính Thế giới Thượng Hải…cùng nhiều kiến trúc độc đáo khác.
Tham quan Miếu Thành Hoàng, tự do mua sắm trên phố Nam Kinh.
Check in Lục Gia Chuỷ – địa điểm “hot” với trào lưu check-in đầy nghệ thuật.
Tối: Quý khách dùng bữa tại nhà hàng.
Quý khách có thể tham gia Chương trình du thuyền trên sông Hoàng Phố ngắm cảnh đẹp hai bờ Tây – Đông thành phố Thượng Hải dưới những ánh đèn đủ màu sắc của các toà nhà cao tầng dọc 2 bên sông hoặc đi tàu điện ngầm khám phá thành phố Thượng Hải về đêm (chi phí tự túc – 180 tệ).
Nghỉ đêm tại khách sạn.

Ngày 7: THƯỢNG HẢI – HÀ NỘI
Sáng: Qúy khách dùng bữa sáng tại khách sạn, sau đó đoàn khởi hành đi tham quan:
Chùa Phật Ngọc – Là nơi đặt hai pho tượng phật bạch ngọc cực hiếm, ngôi chùa kiêm tu viện hiện đại này là một ốc đảo tâm linh ngay giữa lòng Thượng Hải. Luôn nghi ngút khói nhang, Chùa Phật Ngọc là ngôi chùa linh thiêng nhất ở Thượng Hải, thăm Trung tâm Bảo Thạch.
Trưa: Quý khách dùng bữa tại nhà hàng. Sau đó, Xe đưa Quý khách ra sân bay, đáp chuyến bay VN533 (15h50 – 18h25) rời Thượng Hải về Hà Nội.
18h25: Quý khách về đến sân bay Nội Bài, xe đón Quý khách về điểm hẹn trong thành phố. Kết thúc chương trình./.
HDV chia tay và hẹn gặp lại quý khách trong những chuyến đi lần sau!
(Thứ tự các điểm tham quan trong chương trình có thể thay đổi theo thực tế nhưng vẫn đảm bảo các điểm tham quan theo chương trình.)',
    'Giá tour trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 10 tuổi: 90% (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 10 tuổi: 100% (Có chế độ giường riêng).
Trẻ em đủ 10 tuổi trở lên: 100% giá tour người lớn.

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý:
Quý khách phải có hộ chiếu còn hạn tối thiểu 6 tháng (181 ngày) tính tới thời điểm kết thúc
Lưu ý về phẫu thuật thẩm mỹ (PTTM): Khách hàng đã từng PTTM (cắt mi, nâng mũi,gọt hàm, săm mày, ….) có thể bị an ninh tại các nước từ chối xuất cảnh/nhập cảnh. CTDL không chiu các chi phí phát sinh cxung như hòan tiền các dịch vụ khi TH này xảy ra
Lưu ý trẻ em:
+ Trẻ em dưới 18 tuổi đi cùng bố mẹ: Mang theo giấy khai sinh bản gốc hoặc bản sao công chứng
+ Trẻ em dưới 18 tuổi không đi cùng bố mẹ: Bổ sung giấy ủy quyền đồng ý cho con đi du lịch cùng người được ủy quyền (Ghi rõ thông tin người được ủy quyền)
Thứ tự các điểm thăm quan có thể bị thay đổi để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đủ điểm thăm quan.
Từ chối bảo hiểm cho khách từ 70 tuổi trở lên theo quy định của các công ty bảo hiểm.
Quý khách là Việt Kiều hay người nước ngoài sử dụng visa rời phải mang theo visa rời khi tham gia.
Quý khách mang 02 Quốc tịch hoặc Travel document (chưa nhập Quốc tịch) vui lòng thông báo với nhân viên bán và nộp bản gốc các giấy tờ có liên quan khi tham gia.
Quý khách mang thẻ xanh và không còn hộ chiếu Việt Nam còn hiệu lực thì không đăng ký được.
Chi phí có thể thay đổi nếu tỷ giá ngoại tệ tăng giảm đột biến (Giá vé máy bay, thuế liên quan, tỷ giá bán ra của ngân hàng Vietcombank tại thời điểm khởi hành)
Giá áp dụng cho khách hàng từ 12 tuổi đến 69 tuổi, từ 70 tuổi trở lên sẽ đóng thêm chênh lệch cho mức phí bảo hiểm cao cấp yêu cầu phải có giấy chứng nhận đầy đủ sức khỏe để đi du lịch nước ngoài của cơ quan y tế có thẩm quyền cấp và phải có người thân khỏe mạnh dưới 60 tuổi đi cùng. Gia đình và quý khách phải cam kết đảm bảo tình trạng sức khỏe với Công ty chúng tôi trước khi tham gia. Nếu có bất cứ sự cố nào xảy ra trên, Công ty sẽ không chịu trách nhiệm dưới mọi tình huống.
Chương trình được hỗ trợ bởi các điểm mua sắm, nên không được phép bỏ điểm.
Để đảm bảo giá, khách hàng phải cam kết đi đúng hành trình. Nếu Quý khách tách đoàn ngày nào sẽ tính phí tách đoàn là 100$* số ngày tách*số người tách.
Giờ bay và hãng hàng không có thay đổi cho phù hợp với chương trình và tình trạng vé máy bay. CTDL sẽ thông báo và gửi lịch bay chính xác cho đoàn ngay sau khi có cập nhật thông tin từ hàng không.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được báo trước
CTDL sẽ không hoàn lại chi phí cho bất cứ dịch vụ gì tại nước ngoài khách không sử dụng nếu Quý khách bị cơ quan xuất nhập cảnh từ chối cấp visa và không chịu trách nhiệm về lý do nhân thân của khách khi khách bị cục xuất nhập cảnh Việt Nam hoặc Nước Sở Tại từ chối cho xuất nhập cảnh. Do tính chất đoàn là khách gom lẻ nên CTDL có trách nhiệm gom khách đủ đoàn 16 người trở lên sẽ khởi hành theo đúng lịch trình, có trưởng đoàn đi cùng từ Việt Nam. Nếu đoàn từ 10 – 14 người, CTDL sẽ cử HDV ra làm thủ tục cho đoàn tại sân bay. HDV điểm sẽ đón đoàn tại sân bay địa phương và theo quý khách suốt hành trình. Nếu đoàn dưới 10 người, CTDL có trách nhiệm thông báo cho quý khách trước ngày khởi hành 05 ngày và thỏa thuận với quý khách về ngày khởi hành mới hoặc hoàn lại cho quý khách số tiền đã đặt cọc.
Quý khách đăng ký tour vui lòng đi và về đúng theo lịch trình của đoàn. Trường hợp quý khách tách đoàn sẽ bị áp dụng phạt cho mọi trường hợp, và không được hoàn lại bất kỳ chi phí nào. Trong hành trình, Quý khách không được tự động nhận thêm người nhà hoặc người quen lên xe mà không có sự thỏa thuận dịch vụ với Công ty Du lịch. Công ty du lịch có quyền từ chối cung cấp dịch vụ cho các trường hợp trên.
Quý khách mang thai xin vui lòng báo cho nhân viên bán tour ngay tại thời điểm đăng ký để được tư vấn thêm thông tin.
Thời gian nhận phòng từ 12h00 – 14h00, trả phòng trước 12h00; Quý khách muốn nhận hoặc trả phòng sớm hay muộn hơn thời gian trên sẽ phải trả thêm phí theo quy định của khách sạn.
CTDL có quyền gom khách từ nhiều công ty khác nhau để đủ đoàn và khởi hành theo đúng thỏa thuận.
**Trong những trường hợp khách quan như: khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như: máy bay, tàu hỏa…thì Công ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, a toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.
Quý khách hàng đã đặt tour và chuẩn bị đặt tour du lịch quốc tế lưu ý thông tin cực kì quan trọng!
Thông báo về việc hoàn thành nghĩa vụ nộp thuế của khách hàng trước khi xuất cảnh:
Các khách hàng là chủ Doanh nghiệp, Chủ hộ kinh doanh, cá nhân phải nộp thuế TNCN, cần hoàn thành nghĩa vụ nộp các loại thuế (bao gồm cả thuế Thu nhập cá nhân) trước khi xuất cảnh, vì hiện tại Hải quan đã check được trên hệ thống. Quý khách vui lòng tải phần mềm Etax Mobile về tự kiểm tra.”
Mong các khách đều kiểm tra kĩ về thuế TNCN.
Công ty du lịch sẽ không chịu trách nhiệm và không xử lý tại sân bay được khi Quý khách không được xuất cảnh với lí do chưa hoàn thành nghĩa vụ nộp thuế.

Thủ tục xin visa đoàn trung quốc
Scan mặt hộ chiếu trang 2+3 rõ nét, không bóng, không loá, không mất góc
File ảnh 4×6 (nền trắng, hở mắt, hở tai, không cười, không đeo kính, không để tóc mái, không mặc áo trắng)
Đối với trẻ em dưới 18 tuổi (Chưa qua sinh nhật), khi làm visa phải có bản scan giấy khai sinh kèm theo (dù bố mẹ có đi cùng hay ko đi cùng đều phải cung cấp), khi nhập cảnh bắt buộc phải mang giấy khai sinh bản dấu đỏ kèm theo.
—> Nếu bố hoặc mẹ không đi cùng con, thì cần làm giấy Ủy quyền là con sẽ đi cùng ai trong đoàn (Cung cấp họ tên + số HC).
—> Khi nhập cảnh trẻ em cần mang theo giấy khai sinh bản sao có dấu đỏ và giấy Ủy quyền nếu bố hoặc mẹ không đi cùng con)
Lưu ý:
Trẻ em dưới 18 tuổi không đi cùng Bố hoặc Mẹ phải có giấy ủy quyền có chữ ký đầy đủ của Bố Mẹ
Thủ tục đoàn hoàn thiện trước 15 ngày làm việc (để làm visa và xuất vé máy bay)',
    'https://fiditour.com/wp-content/uploads/2025/11/gdocs_1_20250930_171738_f156bf2a.png_large.webp
https://fiditour.com/wp-content/uploads/2025/11/avt-That-Ly-Son-Duong-jpg.webp
https://fiditour.com/wp-content/uploads/2025/11/1647919499.jpg
https://fiditour.com/wp-content/uploads/2025/11/472784940-1863209351169438-2807332784791160698-n.jpg
https://fiditour.com/wp-content/uploads/2025/11/Chua-Phat-Ngoc-Thuong-Hai-Chon-Linh-Thieng-Giua-Long-Thanh-Pho.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-tq-2026-ha-noi-bac-kinh-to-chau-hang-chau-thuong-hai-7n6d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14586', 'Cáp Nhĩ Tân - Làng Tuyết Hương - Trùng Khánh - Công Viên Gấu Trúc 7N7Đ',
    'TP.HCM', 'Trung Quốc', '7N7Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 76 DAY) + INTERVAL 7 HOUR,
    36990000, 27742000, 25, 19, 'https://fiditour.com/wp-content/uploads/2025/11/Best-Harbin-festival.jpeg',
    'Đến sân bay Trùng Khánh, đoàn nối chuyến bay CA4011 CKG-HRB 07:25 – 10:55 đi Cáp Nhĩ Tân (Quý khách sẽ ăn sáng trên máy bay). Đến sân bay Cáp Nhĩ Tân – xe và HDV đón đoàn di chuyển đi Xe và HDV đưa quý khách đến cửa hàng chuyên bán trang…',
    'Ngày 1: NGHI XƯƠNG – TRƯƠNG GIA GIỚI ( ĂN TRƯA, TỐI )
Đến sân bay Trùng Khánh, đoàn nối chuyến bay CA4011 CKG-HRB 07:25 – 10:55 đi Cáp Nhĩ Tân (Quý khách sẽ ăn sáng trên máy bay).
Đến sân bay Cáp Nhĩ Tân – xe và HDV đón đoàn di chuyển đi Xe và HDV đưa quý khách đến cửa hàng chuyên bán trang phục giữ ấm (nếu cần), vì thời tiết tại Cáp Nhĩ Tân rất lạnh (-20*C), quần áo mang từ Việt Nam có thể không đủ giữ ấm.
Đoàn dùng cơm trưa. Khởi hành tham quan thành phố Cáp Nhĩ Tân:
Quảng trường nhà thờ Saint Sophia (hay còn gọi là Bảo tàng kiến trúc nghệ thuật Cáp Nhĩ Tân)– được thiết kế xây dựng từ năm 1907, nhà thờ Saint Sophia được xem là một trong những địa điểm tham quan, du lịch nổi tiếng bậc nhất ở Cáp Nhĩ Tân.
Công viên Stalin nổi tiếng trên toàn thế giới bởi vì nó nằm ở vị trí có Tháp tưởng niệm lũ lụt Cáp Nhĩ Tân ở giữa, được làm từ mô hình kiến trúc Greco-roman của Nga và mười sáu tác phẩm điêu khắc nghệ thuật.
Tháp tưởng niệm chống lũ lụt – nằm bên bờ sông Tùng Hoa Giang, là điểm đến cuối cùng trên con phố rộng lớn – phố Trung Ương. Năm 1957, để kỉ niệm phong trào chống lũ lụt thành công, nhân dân và chính quyền thành phố đã quyết định xây dựng tượng đài này. Nơi đây được coi là biểu tượng anh hùng, là niềm vinh dự của người dân thành phố.
Đoàn dùng bữa tối và nghỉ đêm tại Cáp Nhĩ Tân.

Ngày 2: CÁP NHĨ TÂN – LÀNG HƯƠNG TUYẾT
Đoàn dùng bữa sáng tại khách sạn, làm thủ tục trả phòng. Đoàn di chuyển đi tham quan Hành Đạo Hà Tử là một thị trấn mang đậm phong cách Nga nổi tiếng ở Cáp Nhĩ Tân. Nơi đây còn lưu giữ nhiều công trình kiến trúc Nga từ cuối thế kỷ 19, với những con phố yên bình và lãng mạn, như bước vào một thị trấn châu Âu thu nhỏ. Đây là điểm lý tưởng để chụp ảnh và khám phá sự giao thoa văn hoá Trung – Nga.
Đoàn dùng cơm trưa, sau đó di chuyển đến Làng Hương Tuyết – khu vực này được mệnh danh là “Tuyết Hương Đệ Nhất Trung Quốc”. Trên đường đi Quý khách sẽ được ngắm nhìn thưởng thức cảnh thiên nhiên mùa Đông với những hàng câu thông, cây bạch dương được bao phủ trong tuyết trắng xóa. Quý khách tham quan check-in với biển hiệu đá ngay cổng vào Làng Hương Tuyết hay còn gọi là Tuyết Thôn, Làng cổ tích với những ngôi nhà nhỏ nằm san sát nhau dưới những lớp tuyết dày đặc.
Quý khách nhận phòng tại Làng Tuyết. Tham quan Bưu điện Làng Tuyết, sau đó quý khách có thể dạo phố làng tuyết, con đường dài tầm 1200m với nhiều cửa hàng bán đồ đặc sản địa phương, tự túc ăn tối. Quý khách có thể tham gia chương trình Lửa trại, hoặc xem chương trình biểu diễn địa phương (tuỳ theo ngày).
Ngoài ra, quý khách có thể tham quan Gia Viên Mộng Ảo nằm tại khu vực trung tâm của Tuyết Hương, là nơi lý tưởng để ngắm “nấm tuyết” và trải nghiệm khung cảnh tuyết trắng miền Đông Bắc Trung Quốc. Vào ban đêm, ánh đèn lung linh khiến nơi đây như một thế giới cổ tích. Du khách còn có thể thưởng thức các tiết mục dân gian đặc sắc và tham gia nhiều trò chơi trên băng tuyết thú vị. (chi phí tự túc)

Ngày 3: LÀNG HƯƠNG TUYẾT – YABULI – CÁP NHĨ TÂN
Quý khách có thể dậy sớm để ngắm bình minh ở Làng Hương Tuyết, tự do ngắm cảnh, sáng tạo ảnh với khung cảnh tuyệt đẹp của Làng Tuyết trong nắng sớm.
Ăn sáng tại khách sạn, làm thủ tục trả phòng. Đoàn rời Làng Tuyết di chuyển về thành phố Cáp Nhĩ Tân.
Tham quan Thập Lý Hoạ Lang – nơi được mệnh danh là có cảnh tuyết đẹp như tranh vẽ, như một bảo tàng tranh về tuyết. Thập lý họa lang là con đường đi bộ xuyên rừng đẹp nhất tại Tuyết Hương, dài khoảng 5 km, hai bên là rừng bạch dương và thông phủ tuyết trắng. Trên đường, du khách có thể ngắm sương hoa, nấm tuyết và các kỳ quan băng tuyết tuyệt đẹp – là tuyến đường lý tưởng để đi bộ và chụp ảnh vào mùa đông. (chi phí tự túc)
Quý khách có thể chọn lựa các chương trình – hoạt động trên tuyết (chi phí tự túc): Xe motor trượt tuyết, Hắt nước thành băng…
Sau bữa trưa, đoàn di chuyển đến Yabuli, quý khách trải nghiệm xe ngựa kéo trên tuyết (đã bao gồm chi phí, tuy nhiên tùy tình hình thực tế có thể thay thế bằng xe chó kéo), tham quan Làng Weihu, các khu giải trí trên tuyết.
Đến Cáp Nhĩ Tân, đoàn ăn tối và trở về khách sạn nhận phòng nghỉ ngơi.

Ngày 4: CÁP NHĨ TÂN – THẾ GIỚI BĂNG TUYẾT
Đoàn dùng bữa sáng tại khách sạn, sau đó di chuyển đi tham quan Khu du lịch Volga nằm bên dòng sông Ashi, thuộc quận Hương Phường, thành phố Cáp Nhĩ Tân. Đây là công viên mang đậm phong cách châu Âu, tái hiện không gian văn hóa Nga đặc sắc giữa thiên nhiên tươi đẹp. Bên trong khuôn viên có nhiều công trình kiến trúc nổi bật như lâu đài Pavlov, cung điện Peter… tất cả đều được phục dựng theo nguyên mẫu Nga cổ điển. Đây là điểm đến lý tưởng để khám phá văn hóa Nga ngay giữa lòng Trung Quốc.
Quý khách dùng cơm trưa tại nhà hàng địa phương.
Tùy vào thời tiết Quý khách sẽ được tham quan “Lễ hội băng đăng quốc tế Cáp Nhĩ Tân” – Thế giới băng tuyết ngoài trời hoặc tham quan Công viên băng tuyết trong nhà – được thành lập năm 1999. Đây là một dự án nghệ thuật băng và tuyết quy mô lớn do Chính quyền thành phố Cáp Nhĩ Tân tổ chức là khu triển lãm băng trong nhà có diện tích lớn nhất, số lượng tác phẩm nhiều nhất trên thế giới. (bao gồm: thang cuốn, cáp treo, khu vui chơi trượt tuyết – không bao gồm: dụng cụ trượt tuyết).
Xe đưa đoàn đi ăn tối. Nghỉ đêm tại Cáp Nhĩ Tân.

Ngày 5: CÁP NHĨ TÂN – TRÙNG KHÁNH
Ăn sáng tại khách sạn, làm thủ tục trả phòng. Xe đưa đoàn ra sân bay làm thủ tục đáp chuyến bay CA4012 HRB-CKG 12:25 – 16:50 đi Trùng Khánh (Quý khách sẽ ăn trưa trên máy bay).
Đến Trùng Khánh, xe và HDV đón quý khách di chuyển về khách sạn. Khách sạn ngay khu trung tâm thành phố Trùng Khánh, tản bộ tham quan Đài Tưởng Niệm Giải Phóng: Đài tưởng niệm ban đầu được xây dựng vào tháng 12 năm 1940 và hầu như được làm hoàn toàn bằng gỗ. Qua quá trình tu sửa, hiện tại đây là một đài tưởng niệm uy nghiêm với chiều cao 27,5m so với mặt đất. Đài tưởng niệm còn được biết đến như khu trung tâm thương mại của quận Yuzhong ở Trùng Khánh. Mọi người tới đây có thể tham quan mua sắm và trải nghiệm cuộc sống về đêm của Trùng Khánh.
Quý khách tham quan Phố Cổ Hồng Nhai Động : Khu phố cổ 11 tầng lầu với mái ngói rêu phong, hoa văn chạm trổ, phía sau là những tòa nhà chọc trời, nằm ở khu trung tâm thương mại thành phố Trùng Khánh, bên bờ sông Dương Tử, là điểm bờ sông giao nhau của hai con sông Trường Giang và sông Gia Linh, du khách tự do tham quan chụp hình các kiến trúc nhà treo, ngắm cảnh đẹp lung linh của Hồng Nhai Động.
Đoàn dùng cơm tối, quý khách thưởng thức lẩu Trùng Khánh để cảm nhận vị lẩu độc đáo và nổi tiếng tại đây.
Quý khách về khách sạn nghỉ ngơi, tự do khám phá Trùng Khánh về đêm.

Ngày 6: TRÙNG KHÁNH
Quý khách dùng bữa sáng tại khách sạn. Đoàn tham quan Công viên Gấu Trúc Trùng Khánh, là một trong những khu bảo tồn gấu trúc lớn nhất Trung Quốc, quý khách có thể chiêm ngưỡng loài động vật dễ thương và được mệnh danh là quốc bảo Trung Quốc.
Đoàn dùng bữa trưa tại nhà hàng. Sau đó tham quan trạm tàu cao tốc lớn nhất Thế Giới – trạm tàu Đông Trùng Khánh vừa được đưa vào khai thác vào cuối tháng 06/2025 với tổng diện tích xây dựng lên tới 1,22 triệu m2, tương đương với khoảng 170 sân bóng tiêu chuẩn. Với 15 sân ga và 29 đường ray, cùng với cấu trúc nhà ga cao 4 tầng, có khả năng phục vụ tối đa 16.000 hành khách mỗi giờ vào giờ cao điểm. Quý khách sẽ trải nghiệm chuyến tàu đường sắt từ ga Đông Trùng Khánh đến với ga tàu Nhà Hát Lớn đường Nanping.
Quý khách tiếp tục tham quan Hẻm Đới Gia được xây dựng từ năm 1371 với đại đa số người nhà họ Đới sinh sống đã hình thành nên tên của con phố này. Ngoài ra, du khách check-in tại bức tường “Meo Meo” với hình thù những chú mèo ngộ nghĩnh.
Sau đó đoàn đi tham quan một trong những trung tâm thương mại cao cấp bậc nhất Trùng Khánh tại Quán Âm Kiều, không thể bỏ qua trung tâm “Star Light 68”.
Quý khách dùng cơm tối, sau đó về khách sạn nghỉ ngơi. Tự do khám phá Trùng Khánh về đêm.

Ngày 7: TRÙNG KHÁNH – TP.HCM
Đoàn dùng bữa sáng tại khách sạn, làm thủ tục trả phòng. Đoàn di chuyển tham quan Đại lễ đường Nhân dân là công trình mang tính biểu tượng của thành phố Trùng Khánh, được xây dựng theo phong cách của Thiên Đàn Bắc Kinh. Kiến trúc hùng vĩ, cổ kính kết hợp hài hòa giữa truyền thống và hiện đại.
Đoàn tiếp tục đi tham quan Cổ Trấn Nghìn Năm Từ Khí Khẩu (Ciqikou Old Town): Nguyên danh là Long Ẩn Trấn, trị trấn cổ xưa, được xây dựng từ thời nhà Tống vào năm 998. Ciqikou Old Town nằm ở ngoại ô Trùng Khánh với những con dốc bậc đá cổ kính, hai bên đường là các quán trà lầu đèn lồng đỏ cùng những cửa tiệm, nhà hàng đậm chất phong kiến Trung Hoa.
Đoàn Tham quan Đường Sắt Trên Cao Chạy Xuyên Qua Các Tòa Nhà Cao Tầng: Quý khách trải nghiệm và tận mắt ngắm nhìn, Check-in chụp lại khoảnh khắc các đoàn tàu điện đi xuyên qua tòa nhà chung cư cao tầng trong một cảm giác hồi hộp.
Buổi trưa, đoàn di chuyển đến nhà hàng để thưởng thức buffet thịt nướng và hải sản.
Sau đó đoàn di chuyển ra sân bay làm thủ tục đáp chuyến bay CA407 CKG-SGN 18:40-21:20 về TPHCM.
Đến TPHCM, HDV chia tay đoàn. Hẹn gặp lại quý khách.
** Chú ý : Thứ tự chương trình có thể thay đổi theo sự sắp xếp của Hướng Dẫn Viên để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan đã nêu trong chương trình.',
    'Hành lý đến cáp nhĩ tân:
Nhiệt độ tại CÁP NHĨ TÂN khoảng –10 đến -38 độ C tuỳ thời điểm, tuỳ năm. Do thời tiết rất lạnh, Quý khách cần bảo đảm đủ sức khỏe để tham gia tour. Nếu Quý khách có vấn đề về hô hấp nên đọc kỹ chương trình trước khi đăng ký tham gia tour.
Vì vấn đề thời tiết, đôi khi chương trình sẽ được sắp xếp cho phù hợp, tuy nhiên vẫn giữ đầy đủ điểm tham quan.
Để tránh bị sốc nhiệt và nhiễm lạnh, Quý khách mang đầy đủ quần áo giữ ấm cho cơ thể ở nhiệt độ – 20 đến -40 độ C, để cơ thể dần quen với nhiệt độ nóng lạnh của bên trong nhà hàng/xe/khách sạn.
Vì lý do an toàn cho Quý khách công ty không nhận phụ nữ có thai và Quý khách trên 80 tuổi. Đối với Quý khách trên 65 tuổi phải có người thân đi kèm.

Giá tour trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý:
Trước khi đăng ký tour du lịch xin Quý khách vui lòng đọc kỹ chương trình tour, điều khoản, giá tour bao gồm cũng như không bao gồm trong chương trình.
Trường hợp quý khách đã có visa sẽ được trừ lại 500.000 VNĐ
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân (hình ảnh, thông tin trong bản gốc bị mờ, không rỏ rang, hộ chiếu hết hạn hoặc không đúng qui định….), công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Công dân phải hoàn thành nghĩa vụ nộp thuế với nhà nước và không vi phạm pháp luật mới được xuất cảnh. Trong trường hợp cá nhân còn nợ thuế, không được phép xuất cảnh thì Công ty không chịu trách nhiệm bồi hoàn thiệt hại.
Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp trước 7 ngày khởi hành, đoàn không đủ khách, công ty có trách nhiệm và sẽ hoàn trả tiền tour.
Quý khách đã phẩu thuật thẩm mỹ vui lòng làm lại hộ chiếu mới theo hình ảnh ở thời điểm hiện tại. Nếu không nhập cảnh được do ảnh hộ chiếu khác hình ảnh thực tế, công ty du lịch không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn. (Đối với Khách hàng tách đoàn, Chi phí tách đoàn Phía cty Trung Quốc sẽ thu phí tách đoàn).
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Cty sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Trung Quốc.
Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.

Thủ tục xin visa đoàn trung quốc
Hộ chiếu: Scan hoặc chụp hình, lưu ý không được mất góc, để dẹt 180 độ, không dính ngón tay.
Hình 4×6: hình mới nhất trong vòng 6 tháng đến hiện tại, nền trắng, chụp rõ ngũ quan, không cười, không đeo trang sức, không dùng phần mềm chỉnh sửa photoshop.',
    'https://fiditour.com/wp-content/uploads/2025/11/saint-sophia-cathedral-05.jpg
https://fiditour.com/wp-content/uploads/2025/11/china-snow-town-20240206i1.jpg
https://fiditour.com/wp-content/uploads/2025/11/Harbin-4-scaled.jpg
https://fiditour.com/wp-content/uploads/2025/11/4a558bf3f414c0b774cc96f2442fb3ed.jpg
https://fiditour.com/wp-content/uploads/2025/11/chongqing.webp
https://fiditour.com/wp-content/uploads/2025/11/487124945_984163727226253_8848096950847939888_n.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/hcm-cap-nhi-tan-lang-tuyet-huong-trung-khanh-cong-vien-gau-truc-7n7d-no-shopping/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-14567', 'Nghi Xương - Phượng Hoàng Cổ Trấn - Trương Gia Giới 6N5Đ',
    'TP.HCM', 'Trung Quốc', '6N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 79 DAY) + INTERVAL 7 HOUR,
    15990000, 11992000, 30, 25, 'https://fiditour.com/wp-content/uploads/2025/11/xf46hidv2yziwrn0yq1q.jpg',
    'Trưởng đoàn đón Quý khách tại sân bay Tân Sơn Nhất và làm thủ tục khởi hành đi Nghi Xương trên chuyến bay QW6190 SGN – YIH Đến sân bay Tam Hiệp Nghi Xương, xe và hướng dẫn địa phương đưa đoàn đến khách sạn. Nghỉ đêm tại Nghi Xương.',
    'Ngày 1: TP.HCM – NGHI XƯƠNG ( ĂN TRÊN MÁY BAY )
Trưởng đoàn đón Quý khách tại sân bay Tân Sơn Nhất và làm thủ tục khởi hành đi Nghi Xương trên chuyến bay QW6190 SGN – YIH
Đến sân bay Tam Hiệp Nghi Xương, xe và hướng dẫn địa phương đưa đoàn đến khách sạn.
Nghỉ đêm tại Nghi Xương.

Ngày 2: NGHI XƯƠNG – TRƯƠNG GIA GIỚI ( ĂN SÁNG, TRƯA, TỐI )
Quý khách ăn sáng, làm thủ tục trả phòng, đoàn ngồi thuyền du lịch Hai Đập Một Hiệp, vào Âu Tàu Cát Châu Bá, trải nghiệm thuỷ triều dâng cao và thưởng thức cảnh đẹp của Tam Hiệp.
Quý khách ăn trưa, sau đó di chuyển đi tham quan “Tam Du Động” hay còn gọi là Hang SanYou. Khu thắng cảnh Hang Sanyou nằm bên ngoài Hẻm núi Xiling, cách thành phố du lịch Nghi Xương khoảng 10 km chạy xe. Địa hình núi đá vôi của Hang Sanyou chủ yếu được kiến táo qua kết cấu chính của Hang Sanyou và trở thành cảnh quan chính nơi đây.
Sau đó di chuyển đi tham quan Cố Hương của Khuất Nguyên – điểm thu hút cốt lõi ở đây là đền Khuất Nguyên, được cho là nơi chôn cất thi thể của nhà thơ yêu nước Khuất Nguyên.
Sau đó đoàn khởi hành đi Trương Gia Giới.
Đoàn ăn tối tại nhà hàng địa phương, sau đó quý khách có thể tự túc xem show Múa Dân tộc, MÊ LỰC TƯƠNG TÂY hoặc THIÊN CỔ TÌNH (Chi Phí Tự Túc).
Nghỉ đêm tại khách sạn.

Ngày 3: TRƯƠNG GIA GIỚI – PHƯỢNG HOÀNG CỔ TRẤN ( ĂN SÁNG, TRƯA, TỐI )
Quý khách ăn sáng, làm thủ tục trả phòng. Quý khách tham quan mua sắm tại: “Trung Tâm Y Dược” tìm hiểu văn hóa lịch sử y học Trung Hoa.
Tiếp đó di chuyển đi tham quan “Thiên Môn Sơn” nằm trong vườn quốc gia Núi Thiên Môn. Ngọn núi này rất nổi tiếng với con đường trên trời và hệ thống cáp treo tại Thiên Môn được tuyên bố trong các ấn phẩm du lịch là “cáp treo dài nhất tại một ngọn núi cao nhất trên thế giới” với 98 cabin cáp treo và tổng chiều dài lên tới hơn 7.400 mét, độ cao của ga trên của tuyến cáp treo là 1.279 mét. (Bao gồm xe trung chuyển và 1 lượt cáp treo đi lên).
Sau bữa trưa, đoàn khởi hành đi Phượng Hoàng Cổ Trấn – thị trấn cổ được xây dựng bên dòng Đà Giang, có nền văn hóa lịch sử hơn 1.000 năm tuổi nhưng vẫn còn nguyên vẹn nét văn hóa, kiến trúc đặc trưng. Là một trong những danh lam thắng cảnh di tích văn hóa nổi tiếng hấp dẫn bậc nhất.
Xe buýt đưa đón quý khách vào trung tâm “Thành Cổ Phượng Hoàng” là một thành cổ nằm ở phía tây tỉnh Hồ Nam, được nhà văn Tân Tây Lan Alley Rewi khen ngợi là nơi đẹp nhất Trung Quốc, với những thắng cảnh nổi tiếng (Hồng Kiều, Cầu Đá Nhảy, Thành lầu Đông Môn, tháp Vạn Danh).
Quý khách đi ăn tối, sau đó thưởng thức cảnh đêm tại Phượng Hoàng Cổ Trấn.
Nghỉ đêm tại Phượng Hoàng.

Ngày 4: PHƯỢNG HOÀNG CỔ TRẤN – TRƯƠNG GIA GIỚI
Đoàn dùng bữa sáng tại khách sạn, làm thủ tục trả phòng. Quý khách ngồi xe đi Trương Gia Giới.
Xe tiếp tục đưa Quý khách tham quan và mua sắm tại “Cửa Hàng Châu Báu”.
Sau bữa trưa, tham quan mua sắm tại “Cửa Hàng Cao su”, đặc sản “Trà đen” – thưởng thức trà đạo Trung Hoa. Quý khách có thể tham quan Hồ Bảo Phong – nơi lắng đọng vẻ đẹp đất trời, đây cũng là nơi mà bộ phim Tây Du Kí đã thực hiện nhiều cảnh quay đặc sắc, bao bọc xung quanh hồ là những ngọn núi đá vôi sừng sững, cảnh quan thiên nhiên hùng vĩ. (Chi phí tự túc)
Đoàn ăn tối tại nhà hàng địa phương, sau đó quý khách có thể tự túc xem show Múa Dân tộc, MÊ LỰC TƯƠNG TÂY hoặc THIÊN CỔ TÌNH (Chi Phí Tự Túc).
Nghỉ đêm tại khách sạn.

Ngày 5: TRƯƠNG GIA GIỚI – NGHI XƯƠNG
Quý khách Sau bữa sáng, tham quan mua sắm tại xưởng tơ lụa.
Sau bữa trưa, quý khách tham quan “Đại Hiệp Cốc” hay còn gọi “Cầu Pha Lê” Cây cầu đáy kính nổi tiếng này rộng 6m, dài 430m, bắc qua 2 vách đá ở độ cao 300m và nhìn xuống công viên Trương Gia Giới, được xem là cây cầu cao và dài nhất thế giới. Trải nghiệm mô phỏng VR Tour 360 độ trên không bằng Khinh Khí Cầu. Đoàn khởi hành đi Nghi Xương.
Quý khách trở về khách sạn ăn tối và nghỉ ngơi.

Ngày 6: NGHI XƯƠNG – TP.HCM
Sau bữa sáng, quý khách làm thủ tục trả phòng.
Sau đó ra sân bay Tam Hiệp Nghi Xương làm thủ tục xuất cảnh đáp chuyến bay QW6189 YIH – SGN về Tp.HCM.
Đến sân bay Tân Sơn Nhất, đoàn làm thủ tục nhập cảnh lấy hành lý. Trưởng đoàn tạm biệt quý khách – Kết thúc chuyến du lịch vui vẻ!
** Chú ý : Thứ tự chương trình có thể thay đổi theo sự sắp xếp của Hướng Dẫn Viên để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan đã nêu trong chương trình.',
    'Giá tour trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Điều kiện hoàn/hủy:
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên): Nếu một người trong nhóm không đạt visa thì được hoàn 100% tour, riêng các thành viên còn lại khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý:
Trước khi đăng ký tour du lịch xin Quý khách vui lòng đọc kỹ chương trình tour, điều khoản, giá tour bao gồm cũng như không bao gồm trong chương trình.
Trường hợp quý khách đã có visa sẽ được trừ lại 500.000 VNĐ
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân (hình ảnh, thông tin trong bản gốc bị mờ, không rỏ rang, hộ chiếu hết hạn hoặc không đúng qui định….), công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Công dân phải hoàn thành nghĩa vụ nộp thuế với nhà nước và không vi phạm pháp luật mới được xuất cảnh. Trong trường hợp cá nhân còn nợ thuế, không được phép xuất cảnh thì Công ty không chịu trách nhiệm bồi hoàn thiệt hại.
Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp trước 7 ngày khởi hành, đoàn không đủ khách, công ty có trách nhiệm và sẽ hoàn trả tiền tour.
Quý khách đã phẩu thuật thẩm mỹ vui lòng làm lại hộ chiếu mới theo hình ảnh ở thời điểm hiện tại. Nếu không nhập cảnh được do ảnh hộ chiếu khác hình ảnh thực tế, công ty du lịch không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn. (Đối với Khách hàng tách đoàn, Chi phí tách đoàn Phía cty Trung Quốc sẽ thu phí tách đoàn).
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Cty sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Trung Quốc.
Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.

Thủ tục xin visa đoàn trung quốc
Hộ chiếu: Scan hoặc chụp hình, lưu ý không được mất góc, để dẹt 180 độ, không dính ngón tay.
Hình 4×6: hình mới nhất trong vòng 6 tháng đến hiện tại, nền trắng, chụp rõ ngũ quan, không cười, không đeo trang sức, không dùng phần mềm chỉnh sửa photoshop.',
    'https://fiditour.com/wp-content/uploads/2025/11/tribe-of-the-three-gorges-jpg.webp
https://fiditour.com/wp-content/uploads/2025/11/adkjdf-1756433819443.jpg
https://fiditour.com/wp-content/uploads/2025/11/shutterstock_187429190compress.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/hcm-nghi-xuong-phuong-hoang-co-tran-truong-gia-gioi-6n5d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-12803', 'Singapore - Malaysia 5N4Đ',
    'Hà Nội', 'Singapore', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 12 DAY) + INTERVAL 7 HOUR,
    11691000, 8768000, 35, 30, 'https://fiditour.com/wp-content/uploads/2025/04/HN-SINGAPORE-MALAYSIA-5n4d.jpg',
    '04h00: Xe và HDV đón Quý khách tại điểm hẹn, khởi hành ra sân bay quốc tế Nội Bài làm thủ tục đáp chuyến bay VN661 lúc 07h30/08h00 đi Singapore. Quý khách cần chuẩn bị đủ giấy tờ theo hướng dẫn của CTDL. Quý khách dùng bữa trên máy bay.…',
    'Ngày 1: HÀ NỘI – SINGAPORE
04h00: Xe và HDV đón Quý khách tại điểm hẹn, khởi hành ra sân bay quốc tế Nội Bài làm thủ tục đáp chuyến bay VN661 lúc 07h30/08h00 đi Singapore. Quý khách cần chuẩn bị đủ giấy tờ theo hướng dẫn của CTDL. Quý khách dùng bữa trên máy bay.
12h25: Chuyến bay hạ cánh tại sân bay quốc tế Changi Singapore. Đoàn check in Waterfall Jewel – thác nước nhân tạo đặc biệt nằm ngay tại sân bay Changi.
Tiếp tục hành trình HDV đưa đoàn khám phá đất nước Singapore:
Merlion Park – Biểu tượng của đất nước Singapore, tìm hiểu lịch sử hình thành biểu tượng sư tử biển nổi tiếng, mang đến thịnh vượng cho nơi này và ngắm nhìn các công trình kiến trúc tiêu biểu của thành phố: Tòa nhà Quốc hội, Tòa Án Tối Cao, Tòa Thị Chính, Nhà hát “Trái Sầu Riêng – Esplanade”, Vịnh Marina Bay…
Đoàn đi ăn tối tại nhà hàng, thưởng thức đặc sản CUA SỐT ỚT SINGAPORE.
Sau bữa tối, xe đưa đoàn về khách sạn nhận phòng nghỉ ngơi. Nghỉ đêm tại khách sạn Singapore. Quý khách tự do khám phá thành phố về đêm hoặc đăng ký tham gia chương trình Night Tour Singapore By Night (Chi phí tự túc, Giá tham khảo SGD$65/Adult, SGD$55/Child):
Ngồi thuyền du ngoạn trên sông, vừa chiêm ngưỡng ánh đèn mầu rực rỡ của tập hợp các quán Bar, trung tâm mua sắm hai bên bờ sông, vừa lắng nghe câu chuyện kỳ bí về lịch sử đảo Quốc Sư Tử.
Một lần đến khu phức hợp Suntec City để hiểu rõ hơn về sự tuyệt vời của nghệ thuật phong thủy Singapore.

Ngày 2: SINGAPORE – MALLACA
Sáng: Sau bữa sáng tại khách sạn, Xe và hướng dẫn đón đoàn đưa đi tham quan:
Đảo Sentosa – Đảo nghỉ dưỡng hàng đầu, thăm quan khu giải trí phức hợp Resort World – phức hợp du lịch ấn tượng kết hợp hài hoà giữa công viên thiên nhiên, di sản văn hoá, khu ẩm thực, trung tâm mua sắm và khu vui chơi giải trí. Quý khách check in Universal và tự do khám phá Sentosa
Ăn trưa buffet BBQ, sau đó tiếp tục tham quan:
Mua sắm tại Trung tâm sản phẩm y khoa (dầu gió cổ truyền, collagen….) và cửa hàng đá quý
Vườn thực vật Garden by the Bay: Khu vườn cây nhân tạo rộng hơn 100 ha, có tới hơn 250.000 loài thực vật Qúy hiếm, với các “Siêu cây” khổng lồ có khả năng tổng hợp năng lượng mặt trời vào ban ngày, tự tỏa sáng vào ban đêm và lọc sạch không khí. Toàn bộ dự án có tổng diện tích 101 ha, được chia làm 3 khu riêng biệt là: Bay South, Bay East và Bay Central (chỉ tham quan khu Bay South, không bao gồm vé tham quan bên trong các khu vườn trong nhà kính). Quý khách có thể trải nghiệm cảm giác hồi hộp và thích thú khi bước chân trên OCBC Skyway – Đường đi bộ trên không dài 128m nối giữa hai siêu cây, rất thích hợp để đi bộ vào bất cứ thời điểm nào, nơi có thể ngắm nhìn toàn bộ khu vườn và khung cảnh thành phố vịnh khu Marina Bay từ trên cao (chi phí tự túc)..
Chùa Răng Phật (Buddha Tooth) – Nằm trong khu Chinatown giàu tính lịch sử, không gian bên trong được thiết kế tỉ mỉ và những triển lãm toàn diện về nghệ thuật và lịch sử Phật giáo tại Bảo tàng & Chùa Răng Phật kể những câu chuyện về văn hóa biến đổi qua hàng ngàn năm.
15h00, Đoàn khởi hành sang Malaysia qua cửa khẩu. Ăn tối và nghỉ đêm tại Malacca.
Quý khách tự do khám phá chợ đêm Malacca – thiên đường mua sắm với những sản phẩm vật lưu niệm, và khu vực ẩm thực với những món ăn đường phố đầy hấp dẫn (Tự túc chi phí và phương tiện di chuyển)

Ngày 3: MALLACA – KUALA LUMPUR
Đoàn dùng điểm tâm sáng tại khách sạn, trả phòng và tham quan city tour tại phố cổ Malacca với những di tích lịch sử cổ kính và đặc sắc như:
Nhà thờ Thánh Saint Paul, Đền Cheng Hood.
Pháo đài cổ Bồ Đào Nha, Pháo đài A’famosa
Quảng trường Hà Lan, Khu phố cổ Jonkers
Kết thúc city tour Malacca, đoàn khởi hành về Kuala Lumpur. Ăn trưa tại nhà hàng.
Sau bữa trưa, đoàn tham quan và chụp hình:
Chùa Thiên Hậu – là một trong những ngôi chùa Phật giáo lớn nhất và lâu đời nhất ở Đông Nam Á. Nằm ở phía Tây Nam của thành phố Kuala Lumpur, nằm trên một ngọn đồi, chùa có tầm nhìn toàn cảnh tuyệt đẹp. Đây là một trong những điểm thu hút khách du lịch nổi tiếng nhất trong thành phố.
Tháp Đôi Petronas (Petronas Twin Towers) – biểu tượng của thủ đô Kuala Lumpur.
Cung Điện Hoàng Gia hay còn gọi là Istana Negara, được xây dựng trên ngọn đồi Janlan Duta phía tây bắc bắc Kuala Lumpur. Với hướng nhìn ra sông, địa thế phong thủy độc đáo “tựa sơn- hứng thủy” này đã góp phần tạo nên vẻ đẹp rất riêng cho Cung điện.
Tượng Đài Chiến Sĩ Vô Danh – Tưởng niệm và tôn vinh những anh hung đã từ bỏ cuộc sống trong sự nghiệp vì hòa bình và tự do của đất nước.
Thánh đường Hồi Giáo quốc gia – Công trình kiến trúc tôn giáo to lớn với sức chứa đến 15.000 người.
Quý khách ăn tối tại nhà hàng địa phương. Nghỉ đêm tại Kuala Lumpur.

Ngày 4: CAO NGUYÊN GENTING
Sáng: Sau khi ăn sáng tại khách sạn, Xe và hướng dẫn đón đoàn đưa đi tham quan động Bahtu và Cao nguyên Genting:
Động Batu chinh phục 272 bậc thang đủ sắc màu, khám phá hang động bí ẩn, nhìn toàn cảnh bức tượng Phật cao trăm mét và tham quan các đền thờ với nhiều bức tượng độc đáo của Phật giáo Ấn Độ.
Cao nguyên Genting, chinh phục độ cao hơn 2000m bằng hệ thống cáp treo Awana Skyway dài 3,4km – được ví như xe bus trên không. Quý khách ngắm toàn cảnh cao nguyên từ trên cao. Quý khách tận hưởng thời tiết mát lạnh của cao nguyên và tự do khám phá thế giới sống động tại cao nguyên (Chi phí tự túc) như:
Mua sắm tại Genting Highlands Premium Outlets với hàng loạt thương hiệu đình đám: Calvin Klein, Hugo Boss, Polo Ralph Lauren, Michael Kors,……
Thử vận may tại Genting Casino nổi tiếng Đông Nam Á.
Trải nghiệm công viên giải trí Skytropolis Indoor Theme Park với các trò chơi cảm giác mạnh, trò chơi ứng dụng thực tế ảo, khu bảo tàng tương tác kỳ quái,…
Công viên ngoài trời Genting Sky World Theme Park – Công viên ngoài trời đsogn vai trò quan trọng trong việc thu hút hàng chục triệu lượt khách du lịch đến Genting. Nơi đây có nhưng trò chơi cho trẻ nhỏ đến những hoạt động không dành cho người yếu tim: tàu lượn siêu tốc trên cao, phi thuyền nhào lộn, trượt nước…
Ăn trưa tại nhà hàng. Chiều, đoàn quay trở lại Kuala Lumpur và mua sắm tại:
Nhà máy Beryl’s Chocolate Kingdom nổi tiếng nhất Malaysia; cửa hàng đặc sản địa phương – thưởng thức trà sâm Tongkat Ali và cà phê trắng, Cửa hàng đồng hồ miễn thuế, Latex, Duty Free….
Tối: Ăn tối nhà hàng. Nghỉ đêm tại khách sạn 3-4*

Ngày 5: KUALA LUMPUR – HÀ NỘI
06h00: Quý khách trả phòng.
Đoàn khởi hành ra sân bay làm thủ tục đáp chuyến MH752 lúc 09h30 về Hà Nội. Quý khách dùng bữa ăn nhẹ trên máy bay.
12h30: Đoàn hạ cánh tại sân bay Nội Bài, xe đưa quý khách về điểm hẹn ban đầu. Chia tay đoàn, kết thúc chuyến đi tốt đẹp, hẹn gặp lại quý khách trong những hành trình sau',
    'Chính sách giá trẻ em
Trẻ em từ 2 đến dưới 11 tuổi: 90 % giá (ngủ chung gường với cha mẹ)
Trẻ em dưới 02 tuổi: 20 % giá (ngủ chung giường với cha mẹ)
Trẻ em từ 11 tuổi trở lên: Giá như người lớn

Ghi chú
Quý khách phải có hộ chiếu còn hạn tối thiểu trên 6 tháng (181 ngày) tính tới thời điểm kết thúc
Lưu ý về phẫu thuật thẩm mỹ (PTTM): Khách hàng đã từng PTTM (cắt mi, nâng mũi,gọt hàm, săm mày, ….) có thể bị an ninh tại các nước từ chối xuất cảnh/nhập cảnh. CTDL không chiu các chi phí phát sinh cxung như hòan tiền các dịch vụ khi TH này xảy ra
Lưu ý trẻ em:
Trẻ em dưới 14 tuổi đi cùng bố mẹ: Mang theo giấy khai sinh bản gốc hoặc bản sao công chứng
Trẻ em dưới 14 tuổi không đi cùng bố mẹ: Bổ sung giấy ủy quyền đồng ý cho con đi du lịch cùng người được ủy quyền (Ghi rõ thông tin người được ủy quyền)
Trẻ em bắt buộc phải có hộ chiếu riêng, không được sử dụng hộ chiếu đính kèm cùng hộ chiếu của bố/mẹ
Thứ tự các điểm thăm quan có thể bị thay đổi để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đủ điểm thăm quan.
Quý khách là Việt Kiều hay người nước ngoài sử dụng visa rời phải mang theo visa rời khi tham gia .
Quý khách mang 02 Quốc tịch vui lòng thông báo với nhân viên bán và nộp bản gốc các giấy tờ có liên quan khi tham gia .
Quý khách mang thẻ xanh và không còn hộ chiếu Việt Nam còn hiệu lực thì không đăng ký được.
Chi phí có thể thay đổi nếu tỷ giá ngoại tệ tăng giảm đột biến (Giá vé máy bay, thuế liên quan, tỷ giá bán ra của ngân hàng Vietcombank tại thời điểm khởi hành)
Giá áp dụng cho khách hàng từ 12 tuổi đến 69 tuổi, từ 70 tuổi trở lên sẽ đóng thêm chênh lệch cho mức phí bảo hiểm cao cấp
Khách từ 70 – 80 tuổi: Phụ thu 250.000 VNĐ/khách
Khách từ 80 – dưới 84 tuổi: Phụ thu 600.000 VNĐ/khách
Khách từ 84 tuổi trở lên, vui lòng kiểm tra phí cụ thể theo từng mức tuổi
Chương trình được hỗ trợ bởi các điểm mua sắm, nếu Quý khách không vào thăm quan các điểm trong chương trình, phụ thu 30 usd/điểm
Để đảm bảo giá , Khách hàng phải cam kết đi đúng hành trình. Nếu Quý khách tách đoàn ngày nào sẽ tính phí tách đoàn là 100$* số ngày tách*số người tách.
Giờ bay và hãng hàng không có thay đổi cho phù hợp với chương trình và tình trạng vé máy bay. CTDL sẽ thông báo và gửi lịch bay chính xác cho đoàn trước ngày khởi hành ít nhất 4 ngày.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được báo trước
CTDL sẽ không hoàn lại chi phí cho bất cứ dịch vụ gì tại nước ngoài khách không sử dụng và không chịu trách nhiệm về lý do nhân thân của khách khi khách bị cục xuất nhập cảnh Việt Nam hoặc Nước Sở Tại từ chối cho xuất nhập cảnh.
CTDL sẽ không hoàn lại chi phí cho bất cứ dịch vụ gì tại nước ngoài khách không sử dụng và không chịu trách nhiệm về lý do nhân thân của khách khi khách bị cục xuất nhập cảnh Việt Nam hoặc Nước Sở Tại từ chối cho xuất nhập cảnh. Do tính chất đoàn là khách gom lẻ nên CTDL có trách nhiệm gom khách đủ đoàn 16 người trở lên sẽ khởi hành theo đúng lịch trình, có trưởng đoàn đi cùng từ Việt Nam. Nếu đoàn từ 10 – 14 người, CTDL sẽ cử HDV ra làm thủ tục cho đoàn tại sân bay.
HDV điểm sẽ đón đoàn tại sân bay địa phương và theo quý khách suốt hành trình. Nếu đoàn dưới 10 người, CTDL có trách nhiệm thông báo cho quý khách trước ngày khởi hành 05 ngày và thỏa thuận với quý khách về ngày khởi hành mới hoặc hoàn lại cho quý khách số tiền đã đặt cọc.
CTDL có quyền gom khách từ nhiều công ty khác nhau để đủ đoàn và khởi hành theo đúng thỏa thuận.',
    'https://fiditour.com/wp-content/uploads/2025/04/HN-SINGAPORE-MALAYSIA-2.png
https://fiditour.com/wp-content/uploads/2025/04/HN-SINGAPORE-MALAYSIA-3.jpg
https://fiditour.com/wp-content/uploads/2025/04/HN-SINGAPORE-MALAYSIA-4.jpg
https://fiditour.com/wp-content/uploads/2025/04/Chua-Thien-Hau.webp
https://fiditour.com/wp-content/uploads/2025/04/Cao-nguyen-Genting.webp',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/hn-singapore-malaysia-5n4d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-12019', 'Jordan - Ai Cập: Amman - Madaba - Sa Mạc Wadirum - Biển Chết Jerash - Cairo - Alexandria 9N8Đ',
    'Hà Nội', 'Ai Cập', '9N8Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 15 DAY) + INTERVAL 7 HOUR,
    93900000, 70425000, 40, 36, 'https://fiditour.com/wp-content/uploads/2025/03/3123123213.jpg',
    'Xe và HDV đón đoàn tại điểm hẹn, đưa đoàn ra sân bay Nội Bài/ Tân Sơn Nhất làm thủ tục đáp chuyến bay đi Jordan – đất nước của những huyền thoại, trên máy bay của hãng hàng không 5* Qatar Airways Chuyến bay từ Hà Nội QR983 HAN-DOH 09h30 –…',
    'Ngày 1: HÀ NỘI / SÀI GÒN – DOHA – AMMAN JORDAN
Xe và HDV đón đoàn tại điểm hẹn, đưa đoàn ra sân bay Nội Bài/ Tân Sơn Nhất làm thủ tục đáp chuyến bay đi Jordan – đất nước của những huyền thoại, trên máy bay của hãng hàng không 5* Qatar Airways
Chuyến bay từ Hà Nội
QR983 HAN-DOH 09h30 – 13h05
QR 400 DOHAMM 16h05– 18h55
Chuyến bay từ Sài Gòn
QR975 SGN-DOH 08h30 – 12h40
QR 400 DOHAMM 16h05– 18h55
Quý khách hạ cánh tại sân bay Queen Alia, thủ đô Amman Jordan. Xe đón đoàn về nhà hàng ăn tối. Nhận phòng khách sạn. Nghỉ đêm tại thủ đô Amman Jordan – Khách sạn Lacasa 4 sao hoặc tương đương

Ngày 2: AMMAN – MADABA –- PETRA ( 230km )
Ăn sáng, trả phòng khách sạn. Xe đón đoàn tham quan :
Các địa danh nổi tiếng trong thủ đô Amman của Jordan: The Citadel, Rạp hát La Mã, bảo tàng khảo cổ, bảo tàng dân gian Jordan,…
Tham quan thành phố MADABA : Nhà thờ chính thống giáo Hy Lạp của thánh George hay còn được gọi là Nhà thờ bản đồ – là một địa chỉ không thể bỏ qua khi đến viếng thăm thành phố Madaba. Nằm giữa vùng đất được mệnh danh là “Thành phố của nghệ thuật Mosaics”, nhà thờ là điểm hấp dẫn với tấm bản đồ cổ xưa nhất của vùng Đất thánh được khảm ngay trên sàn nhà với 2 triệu viên đá màu sắc, ở trung tâm bức bản đồ là Jerusalem, xung quanh là hàng loạt địa danh khác thuộc vùng đất thánh cũng xuất hiện như Jordan, Palestine, đồng bằng sông Nile.
Ăn trưa tại nhà hàng địa phương.
Chiều: Xe đón đoàn tiếp tục hành trình khoảng 230km ( 4 tiếng ) di chuyển bằng ô tô tới thành phố Petra. Nhận phòng khách sạn. Ăn tối. Nghỉ đêm tại Petra – Khách sạn Petra Moon 4 sao hoặc tương đương.
Tham quan thành phố MADABA

Ngày 3: PETRA – SA MẠC WADIRUM – JEEP TOUR
Ăn sáng, trả phòng khách sạn. Xe và hướng dẫn viên đón quý khách đến hành trình khám phá Thành phố hoa hồng Petra, vốn là thủ đô Nabatean cũ có lịch sử hơn 2000 năm được vô tình phát hiện và khai quật vào năm 1812, với các địa điểm tham quan:
Narrow Canyon (SIQ), một hẻm núi và cũng chính là lối đi chính dẫn vào thành phố Petra kéo dài khoảng 1,2km và rộng hơn 3m được hình thành một cách tự nhiên.
Treasury (Al-Khazneh) – cung điện kho tàng, được xây dựng ban đầu như một lăng mộ với lối kiến trúc độc đáo và được chạm khắc lên các vách núi cao hơn 30m một cách tinh xảo. Nơi đây đã từng là bối cảnh cho nhiều bộ phim nổi tiếng của Hollywood.
Lăng mộ Hoàng gia (Royal Tomb) bao gồm 4 công trình chính được chạm khắc vào mặt đá dưới chân núi: Urn Tomb, Silk, Corinthian Tomb, Palace Tomb.
Nhà hát La Mã cổ đại (Roman Theater) được xây dựng trong thời Antoninus Pius cai trị, có sức chứa khoảng 6000 người, được xem như là một di tích ấn tượng và hấp dẫn khách du lịch nhất của Jordan cho đến thời điểm hiện nay.
Ăn trưa tại nhà hàng
Chiều: Xe đón đoàn di chuyển về Sa mạc Wadi Rum. Đây là tập hợp các thung lũng và cồn cát bên cạnh những dãy tường đá đa dạng, kỳ ảo. Đến đây, du khách sẽ phải ngỡ ngàng với khung cảnh đẹp ấn tượng, hệt như sao hỏa thu nhỏ của trái đất. Wadi Rum có lịch sử hoành tráng lên đến hàng triệu năm. Dưới tác động của nhiệt độ, thời tiết hay điều kiện tự nhiên, những ngọn núi đá ở đây được bảo mòn tạo thành những hình thù độc nhất vô nhị. Quý khách chiêm ngưỡng vẻ đẹp kỳ ảo của hoàng hôn trên sa mạc Wadi Rum.
Trải nghiệm khoảng 2h đồng hồ với tour du lịch bằng xe Jeep xuyên qua sa mạc theo dấu chân của Đại Tá Lawrence trong bộ phim nổi tiếng của Holywood “Lawrence of Arabia”. Quý khách sẽ cảm nhận sự tĩnh lặng của không gian gần như vô tận và hoang sơ với những đỉnh núi cát cao như Jabal Rum, Jebel Rum Adami.
Trải nghiệm ngủ đêm trên Sa mạc tại MAGIC CAMP hoặc tương đương
Sa mạc Wadi Rum

Ngày 4: SA MẠC WADI RUM – NÚI NEBO – BIỂN CHẾT
Ăn sáng, trả phòng khách sạn. Xe đón đoàn khởi hành về lại khu vực thủ đô Aman tham quan. Sau khoảng 4h di chuyển bằng ô tô. Xe trở lại thủ đô Amman. Quý khách dùng bữa trưa tại nhà hàng.
Chiều : Quý khách tham quan:
Núi Nebo linh thiêng, cao hơn 800m so với mực nước biển. Nebo là một di tích tôn giáo quan trọng trông xuống đất thánh và phía nam Jordan. Nơi nhà tiên tri Moses được Đức Chúa chỉ về miền đất hứa theo truyền thuyết trong Kinh Thánh và cũng là nơi chôn cất Moses, vị ngôn sứ đầu tiên của giáo hội Thiên Chúa, người đã có công dẫn dắt dân Israel thoát khỏi ách thống trị của người Ai Cập, nơi đây cũng được nhiều vị Đức giáo Hoàng đặt chân đến. Từ đây bạn có thể nhìn thấy xa xa là thung lũng sông Jordan, Biển Chết,
Di chuyển về khu vực Biển Chết – Với thành phần chứa rất nhiều loại khoáng chất và lượng tia UV trong ánh nắng ở Biển Chết rất thấp, cộng với áp suất không khí cao tạo nhiều ích lợi cho sức khỏe con người. Tại đây Qúy khách có cơ hội thả mình nổi trên mặt biển để thư giãn và để muối khoáng chăm sóc làn da của mình.
Nhận phòng khách sạn Dead Sea Spa & Resort 4 sao hoặc tương đương. Qúy khách tự do tắm biển, ăn tối trong khu resort.
Núi Nebo linh thiêng

Ngày 5: AMMAN – JERASH ( JORDAN) – CAIRO ( AI CẬP) ( Ăn sáng. Trưa/tối)
Sáng: Ăn sáng, trả phòng khách sạn. Xe đón đoàn tham quan:
Thành phố cổ Jerash: “Thành phố Pompeii của vùng Trung Đông” những kiến trúc được xây dựng cách nay 6500 năm. Quảng trường công cộng Oval Forum – nơi diễn ra những cuộc hội họp mang tính chất cộng đồng hay những lễ hội tâm linh về tôn giáo, hai nhà hát theo kiểu La Mã gồm nhà hát lớn về phía Nam và nhà hát nhỏ hơn về phía Bắc, tường thành bao quanh thành phố. Bị chôn vùi dưới cả mét cát trong nhiều thế kỷ, Jerash là một minh chứng điển hình cho sự định hìnhđô thị hóa dưới thời La Mã trong toàn bộ vùng Trung Đông: hoành tráng và trang trọng đến choáng ngợp với những con phố lát gạch có hoa văn thanh tú, những cây cột sừng sững với nhiều chi tiết tinh tế đến bất ngờ, những ngôi đền rộng thênh thang ngự trị trên các đỉnh đồi, những nhà hát diễm lệ, những quảng trường rộng lớn, những đài phun nước được quy hoạch một cách khoa học đáng khâm phục.
Ăn trưa tại nhà hàng
Chiều : Xe đưa đoàn ra sân bay Amman làm thủ tục chuyến bay đi Cairo, Ai Cập
Tới sân bay Cairo, xe đón đoàn về nhà hàng, ăn tối. Nhận phòng khách sạn, Nghỉ đêm tại Cairo – Khách sạn Triumph Luxury 5 sao hoặc tương đương.
Thành phố cổ Jerash

Ngày 6: KHÁM PHÁ KIM TỰ THÁP – DU THUYỀN SÔNG NILE
Ăn sáng tại khách sạn. Quý khách tham quan các kim tự tháp:
¨ Quần thể Kim tự tháp Giza với Kim tự tháp đồ sộ Khê ốp – một trong 7 kỳ quan của thế giới cổ đại, là kim tự tháp lớn nhất trong 3 kim tự tháp chính được xây dựng bằng sức người. Du khách chiêm ngưỡng Kim tự tháp Khepren (Chephren) – Kim tự tháp được bảo tồn tốt nhất tại Ai Cập. Lắng nghe những câu chuyện về một lịch sử hào hùng của các Pharaoh, một nền văn minh rực rõ trong lịch sử của con người.
¨ Khu lăng mộ Dashnur – nổi tiếng với kim tự tháp Đỏ là kim tự tháp lớn thứ 3 tại Ai Cập.
¨ Tượng nhân sư Sphinx – tượng đầu người mình sư tử với mình sư tử dài 45m, chân dài 15m được tạc từ một tảng đá nguyên khối, thể hiện sức mạnh và quyền lực thánh thần của các vị Pharaoh.
Sau đó, đoàn di chuyển đi ăn trưa
Chiều: Quý khách tham quan:
Viện bảo tàng Ai Cập Cổ Đại, một địa danh không thể bỏ qua khi đên du lịch tại Ai Cập. Đến đây du khách có cảm giác như được vượt thời gian để trở về thời đại rực rỡ của các Pharaoh. Bảo tàng sẽ cung cấp đầy đủ những hiện vật cũng như thời đại lịch sử của các Pharaoh. Bảo tàng Ai Cập tọa lạc tại quảng trường Tahrir của Cairo. Được thành lập năm 1902 và tồn tại cho đến ngày nay. Tòa nhà nổi bật tại thủ đô với màu đỏ rực rỡ này là nơi lưu trữ rất nhiều phần quan trọng của lịch sử Ai Cập cổ đại, là nơi chứa bộ sưu tập đồ cổ Pharaohic lớn nhất thế giới và kho báu của vị Pharaoh nổi tiếng Tutankhamun.
v Du ngoạn sông Nile trên du thuyền sang trọng. Quý khách tiếp tục hành trình du thuyền trên sông Nile, ngắm nhìn hoàng hôn và xem biểu diễn chương trình nghệ thuật văn hóa dân gian trên dòng song. Thưởng thức bữa tối thịnh soạn kiểu hoàng gia.
Nghỉ đêm tại Cairo – Khách sạn Triumph Luxury 5 sao hoặc tương đương.
Viện bảo tàng Ai Cập Cổ Đại

Ngày 7: CAIRO – ALEXANDRIA – CAIRO
Sau bữa sáng tại khách sạn, xe đưa đoàn tham quan thành phố Alexandria – thành phố lớn thứ 2 tại Ai Cập, được ví như hòn ngọc rực rỡ của vùng Địa Trung Hải. Thăm các địa danh:
¨ Pháo đài Qait Bay – là pháo đài phòng thủ thế kỷ 15 nằm trên bờ biển Địa Trung Hải, ở Alexandria, Ai Cập.
¨ Hầm mộ cổ Kom el Shoqafa – Được coi là một trong bảy kỳ quan của thời kỳ Trung Cổ, đây là một khu vực khảo cổ nổi tiếng của Ai Cập với kiến trúc dành riêng cho các nghi lễ an táng ghi dấu sự pha trộn độc đáo của nghệ thuật tạo hình đặc trưng thời Ai Cập cổ, Hy Lạp và La Mã cổ đại.
¨ Thánh đường Abu El Abbas El Mursi – đây cũng chính là công trình kiến trúc lớn nhất và quan trọng nhất của người Hồi giáo ở thành phố Alexandria. Nhà thờ này có diện tích lên tới 3.000m2 và được trang trí vô cùng cầu kỳ. Sàn được lát bằng đá cẩm thạch trắng, trần được nâng đỡ bởi 16 cột đá granite.
¨ Thư viện Alexandria – Hay còn gọi là Đại thư viện, được xây dựng vào năm 2002 tại nơi chỉ cách vị trí của thư viện cũ khoảng 200m. Công trình mới này mang ý nghĩa của một sự hồi sinh mạnh mẽ cũng như khát vọng phục hưng lại thời kỳ hoàng kim của thư viện Alexandria – một trong bảy kỳ quan của thế giới cổ đại.
Trở lại Cairo, ăn tối. Nghỉ đêm tại Cairo – Khách sạn Triumph Luxury 5 sao hoặc tương đương
Thư viện Alexandria

Ngày 8: CAIRO – HÀ NỘI/ SÀI GÒN
Ăn sáng, trả phòng khách sạn, xe đưa đoàn tham quan
¨ Khu phố cổ Cairo – Là khu vực có mật độ tập trung các công trình Hồi giáo lớn nhất thế giới với đầy đủ các dòng kiến trúc được xây dựng từ thế kỷ X tới XVII. Toàn bộ khu vực này đã được UNESCO công nhận là Di sản văn hóa thế giới vào năm 1979.
¨ Thánh đường AI Azhar là một trong những công trình Hồi giáo đầu tiên được xây dựng vào cùng khoảng thời gian khi thủ đô Cairo được sáng lập. AI Azhar sau khi được hoàn thành vào năm 972 đã trở thành trung tâm tín ngưỡng và đồng thời cũng là trường đại học lớn nhất thế giới Hồi giáo thời bấy giờ.
Ăn trưa tại nhà hàng
Chiều: Xe sẽ đưa đoàn ghé thăm chợ El Khalili: trung tâm buôn bán hàng hóa nổi tiếng tại Cairo như các loại tượng có kích thước nhỏ, gia vị, đồ lưu niệm, đồ trang sức bạc, áo thun, trang phục cho đàn ông Hồi giáo, trang phục múa bụng… Thời gian còn lại trong ngày quý khách tự do mua sắm trước khi xe đưa đoàn ra sân bay làm thủ tục chuyến bay về Hà Nội/ Sài Gòn ( Quý khách ăn, ngủ nghỉ trên máy bay của hãng hàng không 5 sao : QATAR AIRWAYS
Chuyến bay về Hà Nội
QR 1302 CAI – DOH 19h30 – 23h35
QR 976 DOH – HAN 02h55 – 14h05
Chuyến bay về Sài Gòn
QR 1302 CAI – DOH 19h30 – 23h35
QR 970 DOH – SGN 02h35 – 14h25
Thành phố cổ Cairo

Ngày 9: HÀ NỘI / SÀI GÒN
14h05: Máy bay hạn cánh xuống sân bay Nội Bài/ Tân Sơn Nhất . Quý khách làm các thủ tục nhập cảnh, sau đó xe đón Quý khách về điểm xuất phát ban đầu. Chia tay quý khách, kết thúc chương trình',
    'Giá dành cho trẻ em
Hộ chiếu (còn hạn ít nhất 6 tháng tính tới ngày khởi hành).
Hành lý quá cước quy định, xe vận chuyển ngoài chương trình
Chi phí cá nhân như đồ uống trong bữa ăn, điện thoai, giặt là khách sạn
Tiền TIP cho HDV và lái xe địa phương: 100 USD/khách/trọn tour
Visa tái nhập cảnh vào Việt Nam đối với hành khách mang hộ chiếu quốc tịch nước ngoài không được miễn visa khi nhập cảnh vào Việt Nam.
Chi phí ngủ phòng đơn.(15.000.000đ)
Thuế VAT

Lưu ý:
Hộ chiếu (còn hạn 6 tháng tính từ ngày đi)
Trẻ em 02 – 12 tuổi ngủ chung giường với bố mẹ
Chương trình chính thức được xác nhận trước ngày khởi hành 1-2 ngày.
Lịch trình có thể thay đổi tuỳ thuộc vào tình hình thời tiết, giao thông nhưng vẫn đảm bảo đầy đủ các điểm tham quan.
Giá có thể thay đổi nếu hàng không thông báo thay đổi mức phụ thu nhiên liệu và lệ phí sân bay ở các nơi…
LỆ PHÍ KHÔNG HOÀN LẠI (Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy và chủ nhật). Việc hủy bỏ tour với công ty phải được thông báo trực tiếp qua Fax, email và phải được Fiditour xác nhận. Việc hủy bỏ qua điện thoại không được chấp thuận – Trong khi thực hiện chương trình, nếu thành viên nào của Quý khách hủy bỏ một phần hay toàn bộ các dịch vụ đã đặt tại nước ngoài, Fiditour sẽ không chịu trách nhiệm hoàn trả chi phí cho các dịch vụ không sử dụng
+ Nếu Quý khách huỷ ngay sau khi đặt cọc đi tour, Quý khách sẽ phải trả những khoản tiền thực tế Fiditour đã trả cho nhà cung cấp dịch vụ như: tiền đặt cọc vé, tiền đặt cọc phòng, và các dịch vụ khác trong tour tương đương với 20% tổng tiền tour.
+ Nếu Quý khách báo huỷ trong vòng 10-14 ngày tính từ ngày khởi hành, Quý khách sẽ được hoàn lại 60% tổng giá trị tour.
+ Nếu Quý khách báo huỷ trong vòng 4-9 ngày làm việc, Quý khách sẽ được hoàn lại 30% tổng giá trị tour.
+ Nếu Quý khách báo huỷ trong vòng 03 ngày trước giờ khởi hành, Quý khách sẽ không được hoàn lại toàn bộ tiền tour.
Quý khách đưa các giấy tờ liên quan cho việc xin visa trước ngày khởi hành ít nhất 30 ngày để làm thủ tục xin visa nhập cảnh. Trong quá trình xin xét duyệt visa của các chính phủ : JORDAN, AI CẬP hoàn toàn có thể yêu cầu Quý khách bổ sung thêm các giấy tờ cần thiết ( nếu có). Phí không hoàn lại: 6.200.000 VND. Quý khách đã hiểu rõ việc cấp visa hay không là quyền hạn Chính phủ các nước , Chính phủ nước sở tại có quyền từ chối visa không nêu rõ lý do. Fiditour không có vai trò trong việc xét duyệt visa cho khách.
Fiditour ấn định lịch khởi hành dự kiến, trong trường hợp không đủ số lượng người/ đoàn khách để khởi hành, Fiditour sẽ có trách nhiệm báo cho khách biết ngày khởi hành mới. Nếu ngày khởi hành mới không phù hợp với Quý khách và hồ sơ chưa tiến hành các thủ tục cần thiết. Fiditour sẽ hoàn lại 100% tiền đã thu.
Fiditour không chịu trách nhiệm những chi phí phát sinh do vấn đề nhân thân của khách khi xuất cảnh và nhập cảnh tại Việt Nam và nước ngoài.
Trong trường hợp bất khả kháng visa không được chấp thuận cấp từ Đại Sứ Quán, Fiditour sẽ có trách nhiệm hoàn trả lại tiền cho Quý khách sau khi đã giảm trừ đi các khoản chi phí đã trang trải thực tế.
+ Nếu không đạt visa trong vòng 15- 30 ngày khởi hành , phí visa và thư mời tương đương 6.200.00 VNĐ không được hoàn lại
+ Nếu không đạt visa trong vòng 7-14 ngày ngày khởi hành , phí visa và thư mời và phí đặt cọc vé tương đương 11.200.00 VNĐ không được hoàn lại
+ Nếu không đạt visa trong vòng 1- 7 ngày ngày khởi hành , phí visa , thư mời và phí đặt cọc vé & phòng khách sạn đêm đầu tiên tương đương 15.500.00 VNĐ không được hoàn lại
Fiditour không chịu trách nhiệm về những sự cố khách quan như: thiên tai, hạn hán, trì hoãn chuyến bay do thời tiết, kỹ thuật, đình công, hỏa hoạn, chiến tranh, dịch bệnh, Visa ra trễ….Trong những trường hợp này, với đoàn chưa khởi hành thì Fiditour có quyền hủy hoặc thay đổi ngày khởi hành để thuận tiện và bảo đảm sự an toàn cho Quý khách; Với đoàn đã khởi hành, Fiditour sẽ trợ giúp tối đa trong điều kiện cho phép khi đoàn gặp sự cố bất khả kháng. –
Khi đăng ký tour du lịch, Quý khách vui lòng đọc kỹ chương trình, giá tour, các khoản bao gồm cũng như không bao gồm trong chương trình, các điều kiện hủy tour trên biên nhận đóng tiền. Trong trường hợp Quý khách không trực tiếp đến đăng ký tour mà do người khác đến đăng ký thì Quý khách vui lòng tìm hiểu kỹ chương trình từ người đăng ký cho mình.
Do các chuyến bay phụ thuộc vào hãng hàng không nên trong một số trường hợp, giờ bay có thể được thay đổi mà không thông báo trước.
Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận sức khỏe để đi du lịch nước ngoài do bác sĩ cấp và giấy cam kết sức khỏe với Công ty.Bất cứ sự cố nào xảy ra trên tour, Fiditour sẽ không chịu trách nhiệm.
Nếu khách là Việt kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.',
    'https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP1.jpg
https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP2.jpg
https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP3.jpg
https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP4.jpg
https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP5.jpg
https://fiditour.com/wp-content/uploads/2025/03/TOURJORDANAICAP6.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-du-lich-jordan-ai-cap-amman-madaba-sa-mac-wadirum-bien-chet-jerash-cairo-alexandria-9n8d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11977', 'Đông Âu: Hungary - Slovakia - Áo - CH Séc - Đức - Ba Lan 12N11Đ',
    'TP.HCM', 'Châu Âu', '12N11Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 18 DAY) + INTERVAL 7 HOUR,
    112990000, 84742000, 30, 23, 'https://fiditour.com/wp-content/uploads/2025/03/312321313.jpg',
    'Quý khách có mặt tại cổng D1 Ga đi quốc tế sân bay TSN làm thủ tục bay đi Budapest. Nghỉ đêm trên máy bay Turkish Airlines. TK163 SGNIST 2210- 0500 TK1035 ISTBUD 0715- 0815',
    'Ngày 1: TP. HỒ CHÍ MINH ✈ BUDAPEST
Quý khách có mặt tại cổng D1 Ga đi quốc tế sân bay TSN làm thủ tục bay đi Budapest. Nghỉ đêm trên máy bay Turkish Airlines.
TK163 SGNIST 2210- 0500
TK1035 ISTBUD 0715- 0815

Ngày 2: BUDAPEST
Sáng 08h15: Đến Budapest, thủ đô Hungary, Quý khách làm thủ tục nhập cảnh.
09h30: Xe đón đoàn sân bay, đưa vào thành phố
10h00: Tham quan Budapest, được mệnh danh “Paris của Đông Âu”:
Tòa nhà Quốc Hội (Parliament Building) – nổi tiếng đồ sộ hùng vĩ là một trong những tòa nhà lập pháp lâu đời nhất châu Âu,
Đài tưởng niệm những đôi giày
Stephen Cathedral, nhà thờ chánh tòa Công Giáo đặt theo tên của vị vua lập quốc Hungary, nơi cất giữ thánh vật linh thiêng của nhân dân Hungary.
Trưa 12h30: Dùng cơm trưa Hung Cuisine. Sau đó tham quan:
Cầu Xích Chain Bridge: cây cầu mang tính biểu tượng thành lập thành phố Budapest.
14h00: Buda Hill funicular: đi cáp kéo lên đồi Buda, chụp ảnh Dinh Tổng Thống, cung điện Buda Castle, từng là nơi ở của Hoàng gia Hungary trước đây.
Nhà thờ Matthias có lịch sử hơn 1000 năm, được xây dựng theo phong cách Romanesque năm 1015, bao quanh bởi Fishermens Bastion – Pháo lũy của người đánh cá.
Tối 18h00: Đoàn dùng cơm tối.
19h00: Về khách sạn, nhận phòng. Nghỉ đêm tại khách sạn.
Tòa nhà Quốc Hội (Parliament Building)

Ngày 3: BUDAPEST
Sáng 07h00: Ăn sáng khách sạn.
08h30: Khởi hành tham quan Budapest gồm:
Đại lộ thiên đường Andrassy tráng lệ.
Quảng trường Anh Hùng (Heroes Square) – nơi diễn ra những sự kiện quan trọng mang tính lịch sử đất nước Huangary.
Trải nghiệm tắm khoáng nóng trị liệu (chi phí tự túc) tại Khu tắm nóng trị liệu lớn nhất châu Âu.
Trưa 12h00: Ăn trưa nhà hàng. Sau đó tham quan
Đồi Gellert Hill, cao 235m, nơi có Đài tượng Nữ Thần Tự Do của nhân dân Hungary (chụp ảnh từ cầu Tự Do)
Great Market Hall, Chợ truyền thống trong nhà lâu đời nhất Hungary
Phố đi bộ mua sắm sầm uất Vaci Utca
16h30: Du thuyền sông Danube –ngắm vẻ đẹp tráng lệ của Budapest, thành phố mới Pest và thành cổ Buda.
Tối 1800: Ăn tối nhà hàng
19h00: Về khách sạn, nghỉ ngơi.
Đồi Gellert Hill

Ngày 4: BUDAPEST – BLATISLAVA – VIENNA
Sáng: Ăn sáng tại khách sạn. Trả phòng.
08h00: khởi hành đi Bratislava – thủ đô của Slovakia.
Tham quan chụp ảnh Lâu đài Bratislava – nơi ở của các vị vua Hungary khi xưa, nằm trên ngọn đồi cao có tầm nhìn bao quát cả thành phố có kiến trúc hình chữ nhật khổng lồ 4 tòa tháp canh ở bốn góc và một khu vườn với giếng nước sâu 80m.
Nghe giới thiệu Most SNP – được gọi là Cầu UFO từ 1993-2012, cầu đường bộ bắc qua sông Danube, cầu dây văng một cột trụ dài nhất thế giới.
Bách bộ khu phố cổ Bratislava: Cổng Michael’s Gate– cổng thành duy nhất còn xót lại của bức tường thành khổng lồ bao quanh thủ đô từ tk14; Cumil the Sewer Worker: bức tượng anh thợ cống với nụ cười hiền hòa hiếu khách; Primate’s Palace – Dinh Tổng Giám Mục József Batthyány xây dựng 1778-1781.
Trưa 12h30: Đoàn dùng cơm trưa.
14h00: Tiếp tục hành trình đến Vienna – thủ đô Cộng hòa Áo Quốc, nằm bên dòng Danube êm đềm. Đây chính là cái nôi của nền âm nhạc cổ điển châu Âu, nơi rất nhiều nhạc sĩ nổi tiếng như Haydn, Mozart, Beethoven, Schubert…viết nên những bản nhạc bất hữu.
15h00: Bách bộ khu phố cổ Vienna cố kính duyến dáng: Nhà hát lớn Vienna State Opera, Nhà thờ lớn St. Stephen’s, mua sắm tại Khu phố thương mại Kartner nổi tiếng sang trọng. Quảng trường Michaelerplatz chi phối bởi Cung điện Hofburg – được xây dựng vào thế kỷ thứ XIII, nơi ở của hoàng tộc Hofburg – một dòng tộc đã trị vì Áo Quốc và phần lớn lãnh thổ châu Âu trong nhiều thế kỷ.
Tối 18h30: Đoàn dùng cơm chiều.
20h00: Về khách sạn, nhận phòng nghỉ ngơi
Lâu đài Bratislava

Ngày 5: VIENNA – HALLSTATT
Sáng 07h00: Ăn sáng tại khách sạn. Trả phòng. Tham quan:
08h30: Cung điện Schonbrunn kiến trúc Baroque nơi nghỉ ngơi mùa hè của hoàng gia Áo với 1.441 phòng và một vườn hoa vô cùng lớn với những kiến trúc tuyệt đẹp (gồm tai nghe và HDV tại điểm).
10h30: Khởi hành đi làng cổ Hallstatt cổ kính tuyệt đẹp bên bờ hồ, được bao quanh bởi dãy núi Alps mờ sương, Di sản thế giới UNESCO.
Trưa 11h30: Dừng thành phố Melk (~1h xe) ăn trưa nhà hang
16:00 Đến Hallstatt, tham quan:
Quảng trường chợ Marktplatz, Nhà thờ Phúc Âm Evangelical Church, cảnh sắc nhà cổ tựa vách núi bên hồ Hallstätter See …
18h00: Khởi hành đi Salzburg – thành phố nằm sát biên giới với Đức, được biết đến là quê hương của thần đồng âm nhạc Mozart.
Tối 19h15: Đoàn dùng cơm tối.
20h00: Qúy khách về khách sạn, nhận phòng nghỉ ngơi.
Cung điện Schonbrunn

Ngày 6: SALZBURG – CESKY KRUMLOV – CESKE BUDEJOVICE
Sáng 07h00: Ăn sáng tại khách sạn, trả phòng.
08h00: Khởi hành tham quan :
Quảng trường Residence – trung tâm khu phố cổ Salzburg, được bao quanh bởi tòa Tổng giám mục, khu phố cổ, các cửa hàng và các quán ăn.
Nhà thờ Salzburg, có từ tk8. Phía trước nhà thờ là bức tượng của Virgin Mary ở trên cùng, phía dưới có 4 bức hình tượng trưng cho thiên thân, trí tuệ, điều ác và nhà thờ.
Mozart house: ngôi nhà Mozart, nơi Ngài chào đời ngày 27 tháng 1 năm 1756, nơi Ngài lớn lên và sống hơn nửa cuộc đời.
Trưa 11h30: Đoàn dùng cơm trưa.
12h40: Khởi hành (220Km ~3h xe) đi Cesky Krumlov – là thành cổ kiến trúc pha trộn Baroque, Gothic, Phục hưng, art nouveau… rất hài hòa, được giữ gìn và bảo tồn nguyên vẹn đến ngày nay. Nằm trên ngọn đồi đá soi bóng dòng Vltava thơ mộng.
15h40: Đến nơi, bách bộ khu phố cổ, tham quan chụp ảnh bên ngoài Lâu đài Český Krumlov hoành tráng nằm trên ngọn đồi cạnh sông Vltava, được xây dựng từ giữa thế kỷ 13. Đây là tòa lâu đài lớn thứ 2, sau Lâu đài Praha, của cộng hòa Czech.
Quý khách thích hội họa có thể tự khám phá bộ sưu tập tranh của danh họa tài cao mệnh yểu Egon Schiele với những cảnh cô đơn, nhục dục và phong cảnh thấm đượm không khí u sầu tại bảo tàng Egon Schiele Art Centrum
18h00: Khởi hành đi Ceske Budejovice (25Km ~30’ xe)
Tối18h45: Đoàn dùng cơm chiều.
20h00: Nghỉ ngơi tại khách sạn.

Ngày 7: CESKE BUDEJOVICE  PRAGUE
Sáng 07h00: Ăn sáng tại khách sạn, trả phòng.
08h00: khởi hành (155Km ~ 2h xe) đi Praha – thủ đô Cộng hòa Czech, là thành phố cổ kính còn nguyên vẹn nhất châu Âu, thành phố trăm tháp vàng, thành phố xinh đẹp quyến rũ nhất châu Âu nổi tiếng với 18 cây cầu bắc ngang sông Vltava mềm mại uốn lượn qua thành phố.
10h30: Tham quan chụp ảnh Lâu đài Prague, với hơn 1000 năm lịch sử, nơi ở của các vị vua Bohemia, các Hoàng đế La Mã Thần Thánh, nơi được coi như một cuốn sách lịch sử kiến trúc và nghệ thuật, là viên ngọc quý là biểu tượng lâu đời của CH Séc. Thăm đại Giáo đường Thánh St. Vitus Cathedral, nơi còn lưu giữ Vương miện và di hài của các đời vua Bohemia. Cũng tại đây, tòa lâu đài cổ được dùng làm Dinh Tổng Thống hiện nay.
Trưa 12h30: Dùng cơm trưa.
Chiều tản bộ khu phổ cổ, tham quan
Cầu Charles IV (cầu Tình) đẹp và lãng mạn được xây bằng đá kiến trúc Baroque từ thế kỷ 14, bắc qua sông Vltava thơ mộng.
Quảng trường Con Gà, Tòa Thị Chính xây từ tk 14, là công trình đẹp nhất của quảng trường với tháp Đồng hồ Thiên Văn Astronomical clock hơn 500 năm tuổi, lâu đời nhất châu Âu.
Quảng trường Wenceslas, nơi ghi nhiều dấu ấn lịch sử CH Séc
Mua sắm đồ trang sức kim cương nhân tạo Swarovski.
Tối 18h00: Dùng cơm tối.
19h00: Về khách sạn, nhận phòng. Nghỉ đêm tại khách sạn.

Ngày 8: PRAGUE – DRESDEN – BERLIN
Sáng 07h00: Ăn sáng tại khách sạn, trả phòng.
08h00: Khởi hành đi Dresden (150Km ~2hxe),
10h00: Tham quan Dresden, thủ phủ của bang Sachsen, là thành phố cổ kính và lâu đời hơn 800 năm lịch sử, nơi lưu giữ sự hình thành, phát triển của nước Đức.
Chụp hình cung vua Zwinger phong cách đầu trường La Mã, vẻ đẹp hài hòa giữa điêu khắc và hội họa rất độc đáo
Nhà hát Semperoper, tòa nhà opera đẹp tráng lệ nhất nước Đức, viên ngọc thực sự của kiến ​​trúc sân khấu, phong cách phục hưng Ý.
Lâu đài Residenzschloss và Bức tranh sứ Furstenzug, với chiều dài 102m, là bức tranh bằng sứ khổng lồ độc nhất vô nhị, đỉnh cao nghệ thuật, điểm nhấn đặc biệt của Dresden dành cho du khách quan Frauenkirche, nhà thờ tin lành lớn nhất nước Đức, linh hồn của thành phố Dresden, có mái vòm lộng lẫy như một nhà hát opera.
Trưa 12h30: Ăn trưa nhà hàng
13h30: Khởi hành đi Berlin (193Km ~2.5hxe),
16h00: tham quan di tích bức tường Berlin Berlin Wall
17h00: Mua sắm tại Mall of Berlin sầm uất.
Tối 18h30: Đoàn dùng cơm tối
19h30: Về khách sạn nghỉ ngơi

Ngày 9: BERLIN
Sáng 07h00: Ăn sáng tại khách sạn,
08h00: Tham quan Berlin, có lịch sử hơn 500 năm là thủ đô văn hóa của nước Đức bất kể Thể Chế nhà nước từ Công Tước đầu tiên của Brandenburg thời Trung cổ đến các vị vua, hoàng đế Phổ, rồi CH Weimar, thời đại Hitler và phát xít, thời CS Đông Đức cho tới Nền dân chủ ngày nay.
Tản bộ khu phố cổ trái tim Berlin, tham quan chụp ảnh:
Tòa nhà Hạ viện Reichstag CH Liên Bang Đức, nổi bậc mái vòm kính khổng lồ, nơi ghi dấu trung tâm quyền lực chính phủ và dấu ấn Bức Tường
Brandenburg Gate: Biểu tượng của Berlin, biểu tượng của sự thống nhất nước Đức. Được trang trí bởi cổ xe 4 tuấn mã trên nóc thành lớn nhất còn xót lại trong số 14 cổng thành trong bức tường thành khổng lồ bao bọc thành cổ Berlin khi xưa. Từng là điểm phân chia mang tính biểu tượng giữa Đông và Tây Đức thời Chiến tranh lạnh.
Unter den Linden boulevard: Đại lộ trung tâm được xem như Champs – Elysees của Berlin
Gendarmenmarkt, một trong những quảng trường đẹp nhất Âu Châu, nơi tổ chức Chợ Giáng Sinh hàng năm. Nơi hài hòa bởi 3 kiến trúc lịch sử nổi tiếng từ tk18,19: Nhà hòa nhạc Konzerthaus, nhà thờ Pháp The Französischer Dom và nhà thờ Đức Deutscher Dom.
Berlin Cathedral nhà thờ lớn Berlin
Alexanderplatz quảng trường điểm hẹn phổ biến của người dân Berlin bởi sự tấp nập vui nhộn nơi đây với nhiều tòa nhà, nhà hàng, cửa hiệu shopping, khu giải trí bao quanh. Điểm nhấn là chiếc đồng hồ thế giới World Time Clock thể hiện múi giờ của các thành phố lớn trên thế giới
Berlin TV Tower, tháp truyền hình (Fernsehturm) cao 368m, nổi bật trên nền trời và là công trình kiến trúc cao nhất toàn nước Đức.
Trưa 13h00: Ăn trưa nhà hàng.
14h00: Khởi hành (470Km ~6h xe) đi Lodz, thành phố lớn thứ ba của Balan, từng là một trung tâm công nghiệp quan trọng đặc biệt nổi tiếng trung tâm dệt may qui mô lớn của châu Âu.
Tối 20h00: Nhận phòng khách sạn. Ăn tối tại hotel. Nghỉ đêm tại Lodz

Ngày 10: LODZ – WARSAW
Sáng 07h00: Ăn sáng tại khách sạn,
08h30: Khởi hành tham quan thành phố Lodz với kiến trúc gạch đỏ chi phối không gian thành phố.
Alexander Nevsky Cathedral Nhà thờ Chính Thống Giáo niên đại 1884, phong cách Tân Byzantine gợi nhớ một thế kỷ Łódź nằm dưới ách thống trị của Đế quốc Nga. Kiến trúc họa đồ hình bát giác nhiều màu sắc có mái vòm màu xanh, họa tiết hoa văn tuyệt đẹp.
Ulica Piotrkowska, con đường chính của Łódź rất nhiều nhà hàng, cửa hàng, hộp đêm, nhân vật nổi tiếng và người người tấp nập trên phố này.
10h00: Mua sắm tại Manufaktura (10:00-22:00), khu phức hợp shopping rộng lớn, khai trương 2006, chiếm 27ha, và có hơn 300 doanh nghiệp, từ các nhà bán lẻ quốc tế đến các quán cà phê, nhà hang, tiệm bánh, siêu thị,…Quý khách sẽ thỏa thích mua sắm trước khi về nước!
Trưa 13h00: Ăn trưa nhà hàng
14h30: Hành trình (135Km ~ 1.5h xe) đến Warsaw – thành phố xinh đẹp và phát triển nhất Ba Lan, đi lên từ đống tro tàn hậu quả chiến tranh WWII, Warsaw giờ đây đã hồi phục trở lại và trở thành trung tâm kinh tế, chính trị, lịch sử văn hoá của Ba Lan.
16h00: Tham quan Warsaw: Nghe giới thiệu Cung văn hóa và khoa học,
Công viên Lazienki lớn nhất đẹp nhất nổi tiếng nhất được vua Stanislaw August Poniatowski cho xây dựng và kiến thiết trong thế kỷ 18. Tượng đài Frederic Chopin, ngay ở lối vào, nhà soạn nhạc nghệ sĩ dương cầm vĩ đại của xứ sở Ba Lan, được xây dựng 1910 nhân kỷ niệm 100 năm sinh nhật của Ngài
Tối 18h00: Đoàn dùng cơm tối
19h00: Về khách sạn nghỉ ngơiQuý khách đáp chuyến bay về Istanbul

Ngày 11: WARSAW ✈ HO CHI MINH/HANOI
Sáng 07h30: ăn sáng tại khách sạn, trả phòng.
08h30: Khởi hành tham quan:
Holy Cross Church nhà thờ Thánh Thập Giá có từ tk 15, nơi cất giữ di cốt trái tim của nhạc sĩ Chopin và bia mộ ghi tạc các danh nhân Ba Lan.
Krakowskie Przedmiescie con đường Hoàng gia nổi tiếng mà Vua chúa xưa kia, Tổng thống, nhân vật quan trọng trên thế giới đã đi qua, được mệnh danh là Đại lộ Champs Elysees của Warsaw.
Castle Square: Quảng trường Phố cổ bao quanh bởi nhiều kiến trúc cổ kính tk 17, 18 chi phối bởi Cung điện Hoàng Gia và Cột tượng Đức vua Sigmund Vasa III đã dời đô từ Krakow đến Warsaw 1596.
Old town Market Place trung tâm khu phố cổ nổi bậc bởi kiến trúc nhà nhiều màu sắc bao bọc, không khí luôn nhộn nhịp với nhiều cửa hàng trưng bày bán đồ kỷ niệm, thực phẩm, trái cây rau quả, và cả nghệ sĩ đường phố biểu diễn. Tượng đài Nàng tiên cá Mermaid cầm gươm và khiên là hình ảnh biểu tượng của thủ đô Warsaw.
Trưa 12h00: Đoàn dùng cơm trưa.
13h30: tham quan chụp ảnh:
Barbikan Khu Hoàng thành được phục dựng 1952 trên nền cổng thành và bức tường thành bao bọc thành phố Warsaw xưa kia.
Marie Curie House chụp ảnh căn nhà của nữ bác học lừng danh Marie Curie.
Tượng Đài Warsaw Uprising 1944 tưởng nhớ Kháng Chiến Quân Ba Lan kiêu hùng giải phóng thủ đô trong WWII.
15h30: Xe đưa đoàn ra sân bay (~30’ xe). 16:00 Làm thủ tục bay về nước,
TK1766 WAWIST 19:05-22:40

Ngày 12: HO CHI MINH
Về đến Istanbul, tiếp tục bay về nước,
TK162 ISTSGN 0150 1605
16h05: Đến sân bay TSN, làm thủ tục nhập cảnh. Kết thúc tour. Hẹn gặp lại Quý khách trong những chuyến đi tới!!!
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Giá tour không bao gồm
Vé máy bay quốc tế khứ hồi theo chương trình (có giá trị đúng ngày đi/ngày về theo tour)
Phí visa Schengen; Bảo hiểm du lịch quốc tế [mức BH 1,000,000,000Đ, Chứng nhận Bảo hiểm được cung cấp ngay từ Cty Bảo hiểm, trước ngày khởi hành]
Khách sạn 4* tiêu chuẩn Quốc tế (2khách/phòng).
Các bữa ăn như chương trình (ăn sáng buffet KS); ăn trưa/ăn tối tại nhà hàng Âu, Á.
***Ăn nhà hàng Tây gồm món khai vị (soup, salad,…)+1 món chính (cá, thịt heo/gà/bò,… nướng)+món tráng miệng (kem, coctail, bánh kẹp,…); Ăn nhà hàng châu Á gồm 5 món + 1 canh + cơm trắng + Tráng miệng + trà]
Vé vào cửa tham quan gồm: Buda Hill funicular, Du thuyền sông Danube, Tắm khoáng trị liệu
Xe du lịch tốt vận chuyển đưa đón tham quan như chương trình.
Hướng dẫn viên chuyên tour Đông Âu theo đoàn từ Vietnam nhiệt tình suốt tuyến
Quà tặng lưu niệm : nón cty
Hộ chiếu (giá trị trên 6 tháng tính theo ngày về).
Chi phí cá nhân (hành lý quá cước, điện thoại, giặt ủi, tham quan ăn uống ngoài chương trình).
Chi phí test nhanh/PRC trước khi xuất cảnh hoặc nhập cảnh về lại VN (nếu có)
Chi phí bồi dưỡng tài xế địa phương, HDV địa phương: 77EUR/người/tour

Đối với người nước ngoài, việt kiêu, người già & trẻ em:
Quý khách mang quốc tịch nước ngoài phải có visa rời phải mang theo lúc đi tour.
Visa tái nhập vào Việt Nam cho người nước ngoài hoặc khách Việt Kiều 1.500.000 vnđ/ (Visa nhận tại cửa khẩu và có giá trị vào Việt Nam 1 lần – trong 3 tháng đối với Việt kiều).
Mang theo tờ khai hải quan nhập cảnh visa và 02 ảnh 4x6cm
Quý khách mang 2 Quốc tịch (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Quý khách chỉ mang thẻ xanh (thẻ tạm trú tại nước ngoài) và không còn hộ chiếu VN còn hiệu lực thì không du lịch sang nước thứ ba được.
Trường hợp trẻ em đi với người nhà (không phải Bố Mẹ) phải nộp kèm giấy ủy quyến được chính quyền địa phương xác nhận (do Bố Mẹ ủy quyền dắt đi tour).
Đối với khách hàng hơn 70 tuổi, quý khách và gia đình cam kết đảm bảo tình trạng sức khoẻ để có thể tham gia tour với công ty khi đăng ký. Bất cứ sự cố nào xảy ra trên tour, công ty sẽ không chịu trách nhiệm

Hủy vé
Trong trường hợp không thể tham dự được tour, quý khách vui lòng thông báo cho Công ty và chịu phí huỷ như sau :
– Huỷ ngay sau khi đăng ký: 20% tổng giá thành tour.
– Huỷ trước 15 ngày (không tính thứ 7, chủ nhật): 50% tổng giá thành tour
– Hủy trước trong vòng 15 ngày trước ngày khởi hành (không tính thứ 7, chủ nhật):100% tổng giá thành tour.

Quy trình đăng ký và thực hiện
Khách hàng điền phiếu đăng ký và cung cấp hồ sơ xin visa trước ngày khởi hành ít nhất 45 ngày.
Đóng tiền đặt cọc tour 30 triệu/khách.
Hoàn tất thanh toán tiền tour trước 10 ngày so với ngày khởi hành (trường hợp quí khách bị lãnh sự quán báo rớt Visa sau khi đã đóng hết tiền tour, chúng tôi sẽ hoàn trả lại đầy đủ tiền tour theo đúng qui định ).
Hoàn tất tiền ký quĩ (nếu có) ngay sau khi có kết quả Visa.
Công ty sẽ hướng dẫn thủ tục visa, cách điền các mẫu đơn visa, đăng ký ngày nộp hồ sơ, khách hàng phải có mặt để nộp hồ sơ và mang theo hồ sơ bảng gốc để đối chiếu.

Quy trình đăng ký và thực hiện
Quý khách vui lòng xem kỹ chương trình, giá tour, phần bao gồm và không bao gồm được liệt kê chi tiết trong chương trình.
Quý khách vui lòng đem theo Passport (bản chính), và đóng cọc 30 triệu khi đăng ký tour số tiền còn lại sẽ đóng sau khi được cấp visa hoặc trước 10 ngày khởi hành.
Trường hợp không đạt visa thì phí không hoàn lại là 4.500.000 VND
Tùy theo điều kiện thực tế mà chương trình tham quan có thể thay đổi hành trình lên xuống cho phù hợp, tuy nhiên các tuyến điểm du lịch vẫn đảm bảo đầy đủ.
Các chuyến bay có thể thay đổi vào giờ chót tùy thuộc vào các hãng hàng không, thời tiết…
Trường hợp Quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, công ty được miễn trừ trách nhiệm và sẽ không hoàn trả tiền tour.
Tùy theo tình hình cấp Visa của Lãnh Sự Quán và vé máy bay, ngày khởi hành có thể dời lại từ 1 đến 10 ngày so với ngày khởi hành ban đầu.
Trẻ em ngủ chung giường với bố mẹ. Mỗi gia đình chỉ được kèm 1 trẻ em, trẻ em thứ 2 đóng tiền như người lớn
Hồ sơ xin visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Công ty được miễn trừ trách nhiệm trong trường hợp xảy ra thiên tai, động đất, hạn hán, biểu tình, đình công, dịch bệnh, trục trặc kỹ thuật máy bay,…dẫn đến dời, hủy, hoãn chuyến bay. Nếu những trường hợp trên xảy ra, công ty sẽ xem xét để hoàn trả chi phí cho khách trong điều kiện có thể (sau khi đã trừ lại các

Hồ sơ xin visa du lịch châu âu:
Để chuẩn bị tốt nhất cho việc xin visa nhập cảnh vào Châu Âu theo, công ty đề nghị Quý Khách chuẩn bị đầy đủ các hồ sơ sau:

Tất cả các giấy tờ photo trên giấy a4 và đều phải công chứng
Cá nhân
– Hộ chiếu cả mới và cũ (gốc) còn hạn 6 tháng, có ký tên trong hộ chiếu
– 2 ảnh 3,5×4,5cm nền trắng, mặt chiếm 80% khung hình, chụp từ cổ trở lên, ko cười, ko che tai và chân mày, chụp mới nhất ko quá 3 tháng, Không đeo phụ kiện hoa tai.
– Hộ khẩu nguyên cuốn công chứng trên mặt giấy A4
– Chứng nhận kết hôn công chứng trên mặt giấy A4 (nếu có)
– Nếu đã ly hôn, giấy xác nhận đã ly hôn có công chứng từ địa phương.
– Giấy khai sinh công chứng trên mặt giấy A4 (của con nếu đi vs con, của mình nếu đi với bố mẹ)
Công việc
Khách hàng là chủ doanh nghiệp
Khách hàng làm việc hợp đồng
Giấy phép kinh doanh.
Biên lai đóng thuế 3 tháng gần nhất.
Sao kê tài khoản công ty 3 tháng gần nhất
Hợp đồng lao động.
Xác nhận mức lương 3 tháng gần nhất
Đơn xin nghỉ phép đi du lịch
Nếu Công ty tài trợ cho đi du lịch thì phải có giấy xác nhận.
Tài chính
Sổ tiết kiệm và xác nhận số dư tài khoản ngân hàng 200 triệu trở lên
Giấy tờ sở hữu nhà đất, Hợp đồng cho thuê nhà (nếu có cho thuê nhà).
Giấy chứng nhận sở hữu các tài sản khác nếu có như: xe hơi, cổ phiếu, cổ phần, trái phiếu…
Công ty du lịch
Thư mời của đối tác công ty tại Châu Âu có đầy đủ thông tin khách hàng
Xác nhận lịch trình đi, khách sạn, vận chuyển, ăn uống, tham quan (tiếng anh)
Hợp đồng du lịch và Chương trình tour chi tiết.(tiếng việt).
Bảo hiểm du lịch Quốc Tế.
Điền các mẫu đơn cần thiết theo yêu cầu của ĐSQ, LSQ .
Lấy ngày hẹn phỏng vấn, đóng phí phỏng vấn.
Tư vấn cho khách trước khi đi trình diện nộp hồ sơ tại LSQ
Chúc quý khách một chuyến đi thú vị và bổ ích!',
    'https://fiditour.com/wp-content/uploads/2025/03/tourca3123423424.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourca3123423432424.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourca31234234242.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourca312332343242432.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourca31234242342432.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourca312342342424324.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-dong-au-hungary-slovakia-ao-ch-sec-duc-ba-lan12n11d-khoi-hanh-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11953', 'Châu Âu 4 Nước: Pháp - Thụy Sĩ - Ý - Vatican 11N8Đ',
    'TP.HCM', 'Châu Âu', '11N8Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 21 DAY) + INTERVAL 7 HOUR,
    77990000, 58492000, 35, 34, 'https://fiditour.com/wp-content/uploads/2025/03/3123123123.jpg',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất – Ga đi quốc tế. Trưởng đoàn đón và hỗ trợ quý khách làm thủ tục đón chuyến bay đi Paris (transit Istanbul). Giờ bay dự kiến: TK163 SGN-IST2155 0435//TK1821 IST- CDG 0655 0935. Quý khách dùng…',
    'Ngày 1: TP.HỒ CHÍ MINH ✈ PARIS
Tối: Quý khách tập trung tại sân bay Tân Sơn Nhất – Ga đi quốc tế. Trưởng đoàn đón và hỗ trợ quý khách làm thủ tục đón chuyến bay đi Paris (transit Istanbul).
Giờ bay dự kiến: TK163 SGN-IST2155 0435//TK1821 IST- CDG 0655 0935.
Quý khách dùng bữa và nghỉ ngơi trên máy bay.

Ngày 2: PARIS – CITY TOUR
09:35: Đoàn đến sân bay CDG Paris, làm thủ tục nhập cảnh.
Xe đón và đưa quý khách đi dùng bữa trưa tại nhà hàng địa phương.
Dùng bữa trưa tại nhà hàng địa phương. Tiếp tục tham quan:
Trải nghiệm Du thuyền sông Seine: sông Seine có chiều dài 776km, chảy qua rất nhiều khu vực khác nhau trên lãnh thổ nước Pháp. Tuy vậy, đoạn sông chảy qua thành phố Paris vẫn là nơi nổi tiếng và thu hút được nhiều Du Khách nhất. Bởi trên đoạn sông này có đến hơn 30 cây cầu cổ kính bắc qua, cũng như sở hữu nhiều quần thể kiến trúc đồ sộ hai bên bờ. Quần thể công trình kiến trúc hai bên bờ sông đã được UNESCO công nhận là di sản thế giới vào năm 1991, trở thành một trong những nét đẹp văn hoá không thể bỏ qua khi đặt chân đến Paris. một trong những lựa chọn tuyệt vời để ngắm nhìn các địa danh đặc trưng của Paris dọc hai bên bờ sông Seine. (đã bao gồm vé du thuyền).
Tháp Eiffel: Công trình vĩ đại của hai thế kỷ trước, đến nay vẫn còn là biểu tượng của Paris, là niềm tự hào của người Pháp. (chụp ảnh bên ngoài).
Bảo tàng Louvre (chụp hình bên ngoài).
Tự do tham quan mua sắm tại Lafayette.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Paris hoặc khu vực lân cận.
Tháp Eiffel

Ngày 3: PARIS – METZ
Sáng: Quý khách ăn sáng và trả phòng khách sạn. Đoàn tiếp tục tham quan city:
Champs Elysees: Đại lộ Thiên Đàng, đại lộ đẹp nhất Thế giới và là nơi tập trung nhiều cửa hàng sang trọng nhất của “Kinh Đô Ánh Sáng Paris”.
Arc De Triomphe – Khải Hoàn Môn: một trong những công trình biểu tượng của nước Pháp, nhiều sự kiện lịch sử quan trọng ảnh hưởng đến nước Pháp được tổ chức ở đây, nơi trưng bày nhiều công trình điêu khắc nổi tiếng về những trận đánh lịch sử, đặc biệt là công trình điêu khắc tên “The Marseillaise” của điêu khắc gia nổi tiếng Francois Rude.
Les Invalides: công trình nổi tiếng của thành phố Paris. Được vua Louis XIV cho xây dựng vào cuối thế kỷ 17, Du khách có thể ôn lại kiến thức lịch sử quân đội Pháp và viếng thăm lăng mộ của Napoleon Bonaparte, vị hoàng đế độc tài nổi tiếng của nước Pháp.
Quảng trường Concorde: nằm tại đầu phía đông của đại lộ Champs-Élysées, ngay bên bờ sông Seine, một cạnh tiếp giáp với vườn Tuileries và thuộc Quận 8. Concorde là một trong những quảng trường nổi tiếng và rộng nhất của Paris, đứng thứ hai tại Pháp, sau quảng trường Quinconces ở Bordeaux, và đứng thứ 11 Thế giới.
Cầu Alexander III
Trưa: Ăn trưa tại nhà hàng địa phương. Sau đó đoàn di chuyển đi Metz (331km).
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Metz hoặc khu vực lân cận.
Champs Elysees

Ngày 4: METZ – STRASBOURG – COLMAR/MULHOUSE
Sáng: Đoàn ăn sáng tại khách sạn, làm thủ tục trả phòng. Khởi hành đi tham quan:
Nhà thờ Metz Cathedral,
Quảng trường Place d’Armes
Tiếp tục, Đoàn di chuyển đi Strasbourg. Tham quan:
Cung điện Rohan: là một kiệt tác của kiến trúc Baroque ở Strasbourg được xây dựng bên cạnh Nhà thờ Strasbourg. Nó ra đời vào những năm 1730, từ các thiết kế của Robert de Cotte.
Nhà thờ Đức Bà Strasbourg
Trưa: Đoàn dùng bữa trưa tại nhà hàng địa phương. Và tiếp tục di chuyển về thị trấn Colmar – được du khách gọi ưu ái với cái tên “tiểu Venice” trong lòng nước Pháp. Tham quan:
Phố cổ Colmar: khu phố khá nhỏ nhưng vẫn đủ sức hấp dẫn du khách khi 1 lần đặt chân đến đây
Ngôi làng cổ tích “Little Venice”: tọa lạc ngay bên dòng sông Lauch, đây được coi là một trong những thành phố đẹp nhất của Châu Âu với những con phố đầy màu sắc như trong truyện cổ tích với quảng trường, đài phun nước hay những bảo tàng cổ xưa.
Tối:Đoàn dùng bữa tối tại nhà hàng địa phương. Sau đó, tiếp tục di chuyển về Mulhouse. Nghỉ đêm tại Mulhouse hoặc khu vực lân cận.
Cung điện Rohan

Ngày 5: MULHOUSE – SCHAFFHAUSEN – ZURICH
Sáng: Sau bữa sáng tại khách sạn, đoàn làm thủ tục trả phòng và khởi hành đi Schaffhausen (144km), tham quan:
Thác Rhine: Rhine Falls là một trong những thác nước lớn nhất và nổi tiếng nhất ở châu Âu, nằm trên sông Rhine ở biên giới giữa Thụy Sĩ và Đức. Thác nước này được tạo thành bởi dòng nước mạnh mẽ đổ từ độ cao xuống, tạo thành một cảnh quan hùng vĩ và cuốn hút. Tiếng ồn của nước chảy và những cơn sóng mênh mông tạo nên một trải nghiệm âm thanh và hình ảnh không thể quên (không bao gồm dạo thuyền)
Đoàn di chuyển về Zurich (51km).
Trưa: Đoàn dùng bữa trưa tại nhà hàng địa phương. Tiếp tục tham quan:
Làng cổ Zurich: Nếu là một người thích chụp ảnh,bạn nhất định phải ghé thăm khu phố cổ Zurich.Đến đây, bạn sẽ được thỏa sức”sống ảo” bên những ngôi nhà trang trí bằng những bích họa lớn hay những toà nhà theo phong cách Trung cổ vô cùng huyền ảo, xinh đẹp nhưng không kém phần hấp dẫn.
Nhà thờ Grossmunster: nằm ở Phố cổ Zurich, và là một trong những địa danh nổi tiếng nhất của Zurich. Điểm nhấn của nhà thờ nằm ở các cửa sổ kính của Sigmar Polke, hầm mộ kiểu La Mã, các thủ đô kiểu La Mã trong nhà thờ và tu viện, các cửa sổ kính màu của Augusto Giacometti (1932), các cánh cửa bằng đồng của Otto Münch (1935 và 1950), và phong trào Cải cách bảo tàng trong tu viện.
Hồ Zurich: là một hồ nước lớn nhất Thụy Sĩ, được hình thành từ những con sông băng quanh dãy núi Alps, nằm trải dài qua nhiều thị trấn nhỏ.Đây là một trong những địa điểm du lịch nổi tiếng ở Zurich.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Về khách sạn, nhận phòng và nghỉ đêm tại Zurich hoặc khu vực lân cận.
Nhà thờ Grossmunster

Ngày 6: ZURICH – ENGELBERG – GRINDEWALD – LUCERNE
Sáng: Sau bữa sáng tại khách sạn, đoàn trả phòng, di chuyển tham quan:
Engelberg (195km): Thành phố “Núi thiên thần”, nơi có núi tuyết Titlis nổi tiếng. Thành phố Engelberg chỉ có khoảng vài trăm căn nhà nhưng mỗi căn nhà đều có lối kiến trúc độc đáo và mang một vẻ đẹp khác nhau. Người ta nói mùa thu mà đi qua đây giống như đi qua cõi thiên đường bởi sự kết hợp hài hòa, tinh tế giữa thiên nhiên và con người, giữa những thảm cỏ xanh dưới chân dãy Alps hùng vĩ với những ngôi nhà gỗ sồi nằm bình yên bên sông. Tham quan:
Núi tuyết Titlis: Núi Titlis có độ cao trên 3200m, sở hữu đầy đủ các yếu tố để trở thành một thiên đường du lịch. Đến Titlis, du khách không chỉ được ngắm cảnh quan tuyệt đẹp, được hòa mình cùng thiên nhiên mà còn có thể tham gia các môn thể thao giải trí của cả mùa Đông lẫn mùa Hè (không bao gồm vé cáp treo).
Trưa: Đoàn dùng bữa trưa tại nhà hàng địa phương. Tiếp tục tham quan:
Thị trấn Grindelwald: xinh đẹp tọa lạc lưng chừng núi, nơi này vừa là khu nghỉ mát lớn trong khu vực có đỉnh Jungfrau vừa sở hữu một không gian bao la tuyệt đẹp. Ngôi làng cổ tích giữa đời thực này còn là địa danh lý tưởng để khách tham quan có thể tận hưởng vẻ đẹp tự nhiên và nét hấp dẫn đậm chất đồng quê của đất nước Thụy Sĩ.
Thị trấn Interlaken: Interlaken còn là thành phố mang đậm nét văn hóa người dân Thụy Sĩ, những khách bộ hành đam mê khám phá văn hóa, xã hội thì đây là nơi rất thích hợp để tìm hiểu thông tin chính xác nhất. Không những vậy, các lễ hội văn hóa truyền thống, các xưởng chế biến phô mát, socola hay những tuyến đường mòn xuyên rừng, vượt núi hoang sơ, kỳ bí sẽ là điều kiện tuyệt vời để những người xê dịch được tiếp xúc gần hơn với phong tục tập quán chính thống của người dân.
Hồ Lucerne: một trong bốn hồ nước lớn và đẹp nhất của Thụy Sĩ. Qúy khách có thể thả hồn bên bờ hồ thơ mộng, có thể ngắm nhìn đàn thiên nga đang thỏa sức nô đùa trên mặt hồ.
Cầu gỗ Chapel Bridge: Cầu Chapel là cây cầu gỗ ở Luzern, Thụy Sĩ, dài 240 mét (670 feet), bắc qua bờ sông Reuss, gần lối ra hồ Lucerne, đây là cây cầu gỗ lâu đời nhất còn sót lại ở châu Âu. Đây là địa điểm nổi bật và thu hút nhiều khách du lịch ở Thụy Sĩ.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Về khách sạn nhận phòng, nghỉ đêm tại Lucerne hoặc khu vực lân cận.
Cầu gỗ Chapel Bridge

Ngày 7: LUCERNE – MILAN – VENICE MESTRE/PADOVA
Sáng: Sau bữa sáng tại khách sạn, Đoàn trả phòng và khởi hành đến Milan (243km).
Trưa: Đoàn ăn trưa tại nhà hàng địa phương, sau đó tham quan:
Nhà thờ Doumo di Milano: Duomo di Milano gây ấn tượng mạnh với kiến trúc ngoại thất độc đáo. Với những đường nét phức tạp và tinh tế, Duomo thể hiện sự tráng lệ và huyền bí. Tuy nhiên, không chỉ đẹp ở bên ngoài, bên trong Duomo cũng ẩn chứa những tác phẩm nghệ thuật quý giá và kiến trúc nội thất tuyệt đẹp.
Quảng trường Della Scala.
Nhà hát opera nổi tiếng La Scala: nằm ở góc tây bắc của quảng trường. Ở ngay giữa quảng trường là bức tượng của Da Vinci được điêu khắc bởi nhà điêu khắc nổi tiếng Pietro Mani. Nhà hát Opera La Scala (Teatro alla Scala) ở Milan, Ý, không chỉ là một trong những nhà hát nổi tiếng nhất thế giới mà còn là một biểu tượng quan trọng của nghệ thuật và văn hóa châu Âu. Với lịch sử lâu đời và vẻ đẹp kiến trúc độc đáo, La Scala thu hút những người yêu nghệ thuật và âm nhạc từ khắp nơi
Tự do tham quan mua sắm tại Gallaria Vittorio Emmanuele II.
Đoàn di chuyển về Venice Mestre.
Tối: Đoàn dùng bữa tối tại khách sạn. Nghỉ đêm tại Venice Mestre hoặc khu vực lân cận.
Nhà hát opera nổi tiếng La Scala

Ngày 8: VENICE MESTRE – VENICE ISLAND – PISA
Sáng: Sau bữa sáng tại khách sạn, đoàn làm thủ tục trả phòng và tham quan Venice Mestre.
Venice Island: một trải nghiệm đáng nhớ với chuyến ngồi tàu tận hưởng vẻ đẹp quyến rũ, thơ mộng của thành phố từ xa và các công trình kiến trúc ở hai bên bờ.
Nhà thờ thánh San Marco: một kiến trúc Byzantine tuyệt đẹp.
Du khách sẽ có cơ hội dạo bước trên cây cầu Than Thở huyền thoại. Cây cầu kết nối các nhà tù cũ đến phòng thẩm vấn Cung điện Dolce này xuất hiện rất nhiều trên bưu thiếp và các tranh ảnh về Venice.
Và sẽ có cơ hội xem những nghệ nhân người Venice biểu diễn chế tác thủy tinh Murano bằng phương pháp truyền thông và mua sắm những mặt hành thuỷ tinh độc đáo, tinh tế của Murano.
Trưa: Đoàn ăn trưa tại nhà hàng địa phương, tiếp tục di chuyển về Pisa.
Tháp nghiêng Pisa: Tháp được gia cố bằng 800 tấn chì đối trọng để giảm độ nghiêng. Đoàn chụp ảnh lưu niệm xung quanh tháp.
Piazza del Duomo: Quảng trường Mầu nhiệm – là một khu vực có tường bao rộng 8,87 hecta nằm ở Pisa, Toscana, Ý. Đây là một trung tâm quan trọng của nghệ thuật thời Trung Cổ ở châu Âu và là một trong những khu phức hợp kiến ​​trúc bảo quản tốt nhất trên thế giới. Nó được Giáo hội Công giáo coi là một nơi linh thiêng.
Tòa nhà Giáo hội Thánh Giovanni – Pisa Baptistery: được thành lập năm 1152. Đây là tòa nhà rửa tội lớn nhất tại Ý với chiều cao 54,86m và đường kính 34,13m, nằm trong quần thể Quảng trường của những Kỳ tích tại Pisa.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Pisa hoặc khu vực lân cận.
Venice Island

Ngày 9: PISA – ROME
Sáng: Sau bữa sáng tại khách sạn, Đoàn trả phòng khách sạn và khởi hành đi Rome.
Trưa: Đoàn ăn trưa tại nhà hàng địa phương. Tham quan:
Quảng trường La Mã Roman Forum là một quảng trường chữ nhật được bao quanh bởi các tàn tích kiến trúc cổ đại quan trọng ở trung tâm thành phố Roma.
Đấu trường Colosseum: biểu tượng của Đế chế La Mã và là một trong những mẫu kiến trúc La Mã đẹp nhất còn sót lại. Đấu trường được sử dụng cho các võ sĩ giác đấu và nô lệ có nguồn gốc tù binh chiến tranh thi đấu và trình diễn công chúng. (tham quan bên ngoài).
Đài phun nước de Trevi một kiệt tác nghệ thuật Baroque, nơi du khách ném những đồng xu vào đài phun nước để cầu nguyện quay lại thăm thành phố Vĩnh Hẵng Rome.
Quảng trường Tây Ban Nha.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Rome hoặc khu vực lân cận.
Quảng trường La Mã Roman Forum

Ngày 10: ROME – VATICAN
Sáng: Đoàn dùng bữa sáng tại khách sạn và trả phòng, bắt đầu tham quan Tòa Thánh VATICAN
Quảng Trường Thánh Peter.
Vương Cung Thánh Đường Peter là một trong những ngôi đền linh thiêng nhất và là một trong những nhà thờ lớn nhất thế giới. Bên cạnh đó, đó là nơi Đức Giáo hoàng chủ trì nhiều phụng vụ quanh năm.
Bảo tàng Vatican (vé tham quan tự túc).
Trưa: Quý khách ăn trưa tại nhà hàng địa phương, và tiếp tục tham quan Rome.
Chiều Xe đưa đoàn ra sân bay làm thủ tục xuất cảnh và lên chuyến bay khởi hành về Việt Nam. (transit Istanbul).
Giờ bay dự kiến: TK1864 FCOIST1945 2320 || TK 162 ISTSGN 0250 1705
Bảo tàng Vatican

Ngày 11: TP. HỒ CHÍ MINH ✈ VIỆT NAM
Chiều 17h00: Về đến Việt Nam. Kết thúc chương trình. Hướng dẫn viên tạm biệt và hẹn gặp lại quý khách
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Đối với người nước ngoài, việt kiêu, người già & trẻ em:
Quý khách mang quốc tịch nước ngoài hoặc Việt Kiều phải có visa ETIAS đã khai mang theo lúc đi tour.
Visa tái nhập vào Việt Nam cho người nước ngoài hoặc khách Việt Kiều (Visa nhận tại cửa khẩu và có giá trị vào Việt Nam 1 lần – trong 3 tháng đối với Việt kiều). (liên hệ báo giá tại thời điểm khởi hành)
Mang theo tờ khai hải quan nhập cảnh visa và 02 ảnh 4x6cm
Quý khách mang 2 Quốc tịch (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Quý khách chỉ mang thẻ xanh (thẻ tạm trú tại nước ngoài) và không còn hộ chiếu VN còn hiệu lực thì không du lịch sang nước thứ ba được.
Trường hợp trẻ em đi với người nhà (không phải Bố Mẹ) phải nộp kèm giấy ủy quyến được chính quyền địa phương xác nhận (do Bố Mẹ ủy quyền dắt đi tour).
Đối với khách hàng hơn 70 tuổi, quý khách và gia đình cam kết đảm bảo tình trạng sức khoẻ để có thể tham gia tour với công ty khi đăng ký. Bất cứ sự cố nào xảy ra trên tour, Công Tysẽ không chịu trách nhiệm.

Quy định mua tour và thanh toán
hách hàng điền phiếu đăng ký và cung cấp hồ sơ xin visa trước ngày khởi hành ít nhất 45 ngày.
Đóng tiền đặt cọc tour 30 triệu/khách
Hoàn tất thanh toán tiền tour sau khi có visa hoặc trước 10 ngày so với ngày khởi hành (trường hợp quý khách bị lãnh sự quán báo rớt Visa sau khi đã đóng hết tiền tour, chúng tôi sẽ hoàn trả lại tiền tour theo đúng quy định, sau khi trừ các chi phí như visa 5tr, tiền vé máy bay đã xuất….).
Hoàn tất tiền ký quỹ (nếu có) ngay sau khi có kết quả Visa.
CÔNG TY sẽ hướng dẫn thủ tục visa, cách điền các mẫu đơn visa, đăng ký ngày nộp hồ sơ, khách hàng phải có mặt để nộp hồ sơ và mang theo hồ sơ bảng gốc để đối chiếu.
CHÍNH SÁCH HOÀN/HỦY/KHÔNG ĐẠT VISA – QUY PHẠM QUY ĐỊNH XUẤT/NHẬP CẢNH
Trong trường hợp không thể tham dự được tour, quý khách vui lòng thông báo cho Công ty và
chịu phí huỷ như sau :
Hủy tour sau khi đăng ký: Phạt 100% tiền cọc tour
Hủy tour sau khi nộp lịch hẹn visa: Phạt 100% tiền cọc tour
Hủy tour sau khi có visa: Phạt 100% tổng giá trị tour
Khách bị từ chối xuất cảnh tại Việt Nam hoặc nhập cảnh tại nơi đến: Khách chịu 100% tổng chi phí tour (không được hoàn tiền).
Trường hợp đến ngày khởi hành mà khách vẫn chưa ra kịp kết quả visa, quý khách có thể chọn ngày khởi hành tour kế tiếp hoặc nhận lại tiền tour đã đóng sau khi trừ đi chi phí visa 5 triệu VND/khách.
Trường hợp visa ra cận trước 7 khởi hành tour chưa ra kịp kết quả visa, quý khách có thể báo lại phía công ty xuất vé để đợi kết quả visa. Nếu tới ngày khởi hành vẫn chưa có visa quý khách nhận lại tiền tour đã đóng sau khi trừ đi chi phí visa 5 triệu VNA/khách và chi phí vé máy bay đã báo xuất.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên), nếu một người trong nhóm không đạt visa mà huỷ tour thì khách rớt visa chịu phí visa và vé máy bay nếu đã xuất vé, nhưng các thành viên khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Trong trường hợp hủy tour, quý khách vui lòng mang biên lai đóng tiền và CMND/CCCD đến trực tiếp văn phòng làm thủ tục hủy tour. Công ty sẽ không giải quyết các trường hợp liên hệ hủy tour qua điện thoại).
Chương trình tour theo giá ưu đãi, không áp dụng cho chuyển đổi hoặc dời ngày tour.

Điều kiện hủy tour
Trong trường hợp không thể tham dự được tour, quý khách vui lòng thông báo cho Công ty và chịu phí huỷ như sau :
Huỷ ngay sau khi đăng ký: 20% tổng giá thành tour.
Huỷ trước 15 ngày (không tính thứ 7, chủ nhật): 50% tổng giá thành tour
Hủy trước trong vòng 15 ngày trước ngày khởi hành (không tính thứ 7, chủ nhật):100% tổng giá thành tour.

Lưu ý
Quý khách vui lòng xem kỹ chương trình, giá tour, phần bao gồm và không bao gồm được liệt kê chi tiết trong chương trình.
Quý khách vui lòng đem theo Passport (bản chính), và đóng cọc 30.000.000 khi đăng ký tour số tiền còn lại sẽ đóng sau khi được cấp visa hoặc trước 10 ngày khởi hành.
Trường hợp không đạt visa trước 10 ngày khởi hành, thì phí không hoàn lại là 5.000.000 VND (bao gồm phí nộp lãnh sự, dịch thuật).
Trường hợp visa ra cận trước 7 khởi hành tour chưa ra kịp kết quả visa, quý khách có thể báo lại phía công ty xuất vé để đợi kết quả visa. Nếu tới ngày khởi hành vẫn chưa có visa quý khách nhận lại tiền tour đã đóng sau khi trừ đi chi phí visa 5.000.000 VNA/khách và chi phí vé máy bay đã báo xuất.
Tùy theo điều kiện thực tế mà chương trình tham quan có thể thay đổi hành trình lên xuống cho phù hợp tuy nhiên các tuyến điểm Du Lịch vẫn đảm bảo đầy đủ.
Các chuyến bay có thể thay đổi vào giờ chót tùy thuộc vào các hãng hàng không, thời tiết…
Trường hợp Quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, CÔNG TY được miễn trừ trách nhiệm và sẽ không hoàn trả tiền tour.
Trẻ em 2- 11 tuổi ngủ chung giường với bố mẹ giá tour bằng 90% người lớn. Mỗi gia đình chỉ được kèm 1 trẻ em, trẻ em thứ 2 đóng tiền như người lớn
Hồ sơ xin visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
CÔNG TY được miễn trừ trách nhiệm trong trường hợp xảy ra thiên tai, động đất, hạn hán, biểu tình, đình công, dịch bệnh, trục trặc kỹ thuật máy bay,…dẫn đến dời, hủy, hoãn chuyến bay. Nếu những trường hợp trên xảy ra, CÔNG TY sẽ xem xét để hoàn trả chi phí cho khách trong điều kiện có thể (sau khi đã trừ lại các dịch vụ đã thực hiện như phí làm visa, tiền vé máy bay….và không chịu trách nhiệm bồi thường thêm bất kỳ chi phí nào khác).
Đoàn được áp dụng cho tour khởi hành từ 10 khách trở lên, nếu số lượng khách đăng ký dưới 10 khách. Thì Cty du lịch sẽ thông báo và thương lượng lại với khách hàng để có phương án dời ngày phù hợp.

Hồ sơ xin visa du lịch châu âu:
Để chuẩn bị tốt nhất cho việc xin visa nhập cảnh vào Châu Âu theo, công ty đề nghị Quý Khách chuẩn bị đầy đủ các hồ sơ sau:

Tất cả các giấy tờ photo trên giấy a4 và đều phải công chứng
Cá nhân
– Hộ chiếu cả mới và cũ (gốc) còn hạn 6 tháng, có ký tên trong hộ chiếu
– 2 ảnh 3,5×4,5cm nền trắng, mặt chiếm 80% khung hình, chụp từ cổ trở lên, ko cười, ko che tai và chân mày, chụp mới nhất ko quá 3 tháng, Không đeo phụ kiện hoa tai.
– Hộ khẩu nguyên cuốn công chứng trên mặt giấy A4
– Chứng nhận kết hôn công chứng trên mặt giấy A4 (nếu có)
– Nếu đã ly hôn, giấy xác nhận đã ly hôn có công chứng từ địa phương.
– Giấy khai sinh công chứng trên mặt giấy A4 (của con nếu đi vs con, của mình nếu đi với bố mẹ)
Công việc
Khách hàng là chủ doanh nghiệp
Khách hàng làm việc hợp đồng
Giấy phép kinh doanh.
Biên lai đóng thuế 3 tháng gần nhất.
Sao kê tài khoản công ty 3 tháng gần nhất
Hợp đồng lao động.
Xác nhận mức lương 3 tháng gần nhất
Đơn xin nghỉ phép đi du lịch
Nếu Công ty tài trợ cho đi du lịch thì phải có giấy xác nhận.
Tài chính
Sổ tiết kiệm và xác nhận số dư tài khoản ngân hàng 200 triệu trở lên
Giấy tờ sở hữu nhà đất, Hợp đồng cho thuê nhà (nếu có cho thuê nhà).
Giấy chứng nhận sở hữu các tài sản khác nếu có như: xe hơi, cổ phiếu, cổ phần, trái phiếu…
Công ty du lịch
Thư mời của đối tác công ty tại Châu Âu có đầy đủ thông tin khách hàng
Xác nhận lịch trình đi, khách sạn, vận chuyển, ăn uống, tham quan (tiếng anh)
Hợp đồng du lịch và Chương trình tour chi tiết.(tiếng việt).
Bảo hiểm du lịch Quốc Tế.
Điền các mẫu đơn cần thiết theo yêu cầu của ĐSQ, LSQ .
Lấy ngày hẹn phỏng vấn, đóng phí phỏng vấn.
Tư vấn cho khách trước khi đi trình diện nộp hồ sơ tại LSQ
Chúc quý khách một chuyến đi thú vị và bổ ích!',
    'https://fiditour.com/wp-content/uploads/2025/03/TOU-DUCPHAP3123123.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau.jpg
https://fiditour.com/wp-content/uploads/2025/03/touchauau234443.jpg
https://fiditour.com/wp-content/uploads/2025/03/touchauau2344234324.jpg
https://fiditour.com/wp-content/uploads/2025/03/touchauau234423424234.jpg
https://fiditour.com/wp-content/uploads/2025/03/touchauau2344234234234.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-chau-au-4-nuoc-phap-thuy-si-y-vatican11n8d-khoi-hanh-tu-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11935', 'Châu Âu 5 Nước: Pháp - Luxembourg - Bỉ - Hà Lan - Đức 10N8Đ',
    'TP.HCM', 'Châu Âu', '10N8Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 24 DAY) + INTERVAL 7 HOUR,
    59990000, 44992000, 20, 19, 'https://fiditour.com/wp-content/uploads/2025/03/tourchauau7.jpg',
    '02h10: Quý khách tập trung tại sân bay Tân Sơn Nhất – Ga đi quốc tế. Trưởng đoàn đón và hỗ trợ quý khách làm thủ tục đón chuyến bay đến Bắc Kinh. Quý khách dùng bữa và nghỉ ngơi trên máy bay. Sau khi quá cảnh tại Bắc Kinh, đoàn tiếp tục…',
    'Ngày 1: TP.HCM ✈ PARIS (Nghỉ trên máy bay, Ăn tối)
02h10: Quý khách tập trung tại sân bay Tân Sơn Nhất – Ga đi quốc tế. Trưởng đoàn đón và hỗ trợ quý khách làm thủ tục đón chuyến bay đến Bắc Kinh. Quý khách dùng bữa và nghỉ ngơi trên máy bay. Sau khi quá cảnh tại Bắc Kinh, đoàn tiếp tục làm thủ tục đón chuyến bay đến Paris.
CA904 SGN – PEK 05:10 – 11:10
CA933 PEK – CDG 13:30 – 18:40
Đến sân bay quốc tế Paris (CDG) quý khách di chuyển đi ăn tối và về khách sạn nghỉ ngơi. Nghỉ đêm tại Paris.

Ngày 2: PARIS – CITY TOUR
Sáng: Sau bữa sáng tại khách sạn, đoàn khởi hành đi tham quan chụp hình bên ngoài:
Arc De Triomphe – Khải Hoàn Môn: một trong những công trình biểu tượng của nước Pháp, nơi trưng bày công trình điêu khắc tên “ The Marseillaise” của điêu khắc gia nổi tiếng Francois Rude.
Champs Elysees – Đại lộ Thiên Đàng – Đại lộ đẹp nhất Thế giới và là nơi tập trung nhiều cửa hàng sang trọng nhất của “Kinh Đô Ánh Sáng Paris”.
Bảo tàng The Lourve – một trong những bảo tàng lớn và nổi tiếng bậc nhất thế giới, là điểm đến tuyệt vời tại Paris mà tín đồ nghệ thuật không nên bỏ lỡ.
Trưa: Đoàn dùng bữa trưa tại nhà hàng địa phương. Sau đó quý khách tiếp tục tham quan.
Tháp Eiffel: Công trình vĩ đại của hai thế kỷ trước, đến nay vẫn còn là biểu tượng của Paris, là niềm tự hào của người Pháp (chụp ảnh bên ngoài ).
Trải nghiệm Du thuyền sông Seine – một trong những lựa chọn tuyệt vời để ngắm nhìn các địa danh đặc trưng của Paris dọc hai bên bờ sông Seine. (đã bao gồm vé du thuyền)
Sau đó tự do shopping tại các trung tâm thương mại nổi tiếng như La Faytte, Samaritaine, Ben Lux…
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Paris.
Champs Elysees

Ngày 3: PARIS – REIMS – METZ
Sáng: Quý khách ăn sáng và trả phòng khách sạn. Sau đó đoàn di chuyển đến thành phố Reims, thuộc vùng rượu vang Champagne, trung tâm sản xuất loại vang trứ danh của Pháp từ thế kỷ 17. Cách thủ đô Paris 144km về phía Đông Bắc, Reims là quê hương của rượu vang sủi tăm nổi tiếng nhất thế giới, là điểm đến của những ai yêu hương vị của những giọt rượu vang lóng lánh.
Quý khách tham quan:
Fontaine Sube – Đài phun nước ở trung tâm Reims khánh thành vào ngày 15/7/1906.
Palais de Tau – Cung điện Tau: cung điện của Tổng giám mục tại Reims, Pháp. Đây là nơi ở của các hoàng đế Pháp trước khi họ làm lễ đăng quang theo truyền thống tại Nhà thờ Đức Bà Reims
Notre Dame de Reims – Nhà thờ Đức bà Reims: xây dựng từ thế kỉ 13 với lối kiến trúc Gothic tiêu biểu. Đây là một trong những nhà thờ cổ và lớn nhất của Pháp, cũng là nơi đăng quang của nhiều hoàng đế Pháp qua các thời kì.
Trưa: Đoàn dùng bữa trưa tại nhà hàng địa phương. Sau đó đoàn di chuyển đến thành phố Metz, một thị trấn nhỏ thuộc vùng Lorraine ở đông bắc nước Pháp. Các di tích lịch sử ấn tượng, khung cảnh ven sông đẹp như tranh vẽ và những cây cầu duyên dáng tạo cho Metz nét quyến rũ đặc biệt Metz – thành phố được mệnh danh là “Thành phố Nghệ thuật và Lịch sử”.
German Gate – Cổng Đức là một lâu đài cầu thời trung cổ và cổng thành ở Metz, Pháp. Nó là “di tích của các công sự thời Trung cổ và là một di tích lịch sử của nước Pháp.
Nhà hát kịch Opéra-Théâtre de Metz Métropole Một trong những nhà hát đẹp nhất ở Pháp, Nhà hát de la Comédie cũng là nhà hát opera làm việc lâu đời nhất ở Pháp. Được xây dựng vào năm 1752, tòa nhà có kiến ​​trúc cổ điển đặc trưng của thế kỷ 18.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nghỉ đêm tại Metz.
Notre Dame de Reims – Nhà thờ Đức bà Reims

Ngày 4: METZ – LUXEMBOURG – BRUSSELS
Sáng: Đoàn ăn sáng tại khách sạn sau đó làm thủ tục trả phòng. Đoàn di chuyển đến Luxxembourg một đất nước năng động, lịch lãm, bình yên và nhiều điều thú vị, với niềm tự hào là “Trái tim xanh của Châu Âu”, được UNESCO công nhận danh hiệu “Thủ đô văn hóa Châu Âu” năm 1995 và 2007. Đoàn tham quan bên ngoài:
Cung điện Grand Ducal – cung điện lớn và lộng lẫy nhất Luxembourg. Đây là nơi ở trước đây của Đại Công tước Luxembourg – sở hữu lối kiến trúc tuyệt mỹ, hoàn hảo của thời kỳ Phục Hưng.
Pont Adolphe – Chiếc cầu nổi tiếng đẹp nhất thủ đô Luxembourg, môt biểu tượng du lịch của thành phố và khu phố cổ nơi chôn cất vị tướng tài giỏi của Luxembourg – Gorge Petrusse. Nơi có thể ngắm trọn vẹn bức tranh thung lũng Petrusse tuyệt đẹp.
Quảng trường trung tâm thủ đô Luxembourg – một trong những công trình kiến trúc nổi tiếng nhất của thành phố với vô vàn tiết mục văn nghệ đường phố đầy thú vị.
Trưa : Đoàn ăn trưa tại nhà hàng địa phương. Sau đó đoàn di chuyển đến Brussels – thủ đô của nước Bỉ, trái tim Châu Âu, nơi đặt Tổng hành dinh Cộng đồng Châu Âu (EU) và khối NATO.
Tham quan Quảng trường Lớn (Grande Place) nổi bật giữa Brussels với nền lát đá hoa cương được ca tụng là quảng trường đẹp nhất thế giới, bao bọc xung quanh bởi những tòa nhà nguy nga tráng lệ.
Đi dọc con đường Chocolate nổi tiếng
Chiêm ngưỡng tượng đồng danh tiếng Chú bé Tè (Manneken Pis) ngộ nghĩnh – biểu tượng không chính thức của Brussels.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Nhận phòng khách sạn và nghỉ đêm tại Brussels.
Quảng trường trung tâm thủ đô Luxembourg

Ngày 5: BRUSSELS – AMSTERDAM
Sáng: Đoàn ăn sáng tại khách sạn sau đó làm thủ tục trả phòng. Quý khách tham quan:
Mô hình Atomium (chụp hình bên ngoài): có độ cao 102m với tổng trọng lượng khoảng 2.400 tấn với 9 quả cầu nguyên tử sắt (kích thước lớn hơn thực tế tới 165 tỷ lần) coi là biểu tượng mới của nước Bỉ dù mới ra đời năm 1958 với mục đích sẽ là biểu tượng của thời đại nguyên tử và sử dụng nguyên tử với mục đích vì hòa bình.
Trưa : Đoàn ăn trưa tại nhà hàng địa phương. Sau đó đoàn khởi hành Amsterdam – trung tâm kinh tế, văn hoá, chính trị của Hà Lan. Quý khách tham quan:
Từ 15/03 – 15/05/2025:
Vườn hoa Keukenhof: Quý khách tham gia vào lễ hội hoa tulip ở Hà Lan, đây là lễ hộ hoa lớn nhất trong năm thường kéo dài từ tháng 3 đến tháng 5 hàng năm, tại công viên Keukenhof – vườn hoa lớn nhất thế giới thuộc thị trấn Lisse ở phía Tây Nam của thủ đô Amsterdam. Công viên Keukenhof đã tồn tại hơn một thế kỷ và là nơi trồng hơn 7 triệu hoa tulip với nhiều màu sắc khác nhau. Hằng năm, lễ hội này thu hút hàng triệu lượt du khách khắp nơi trên thế giới để tận mắt chiêm ngưỡng khu vườn với hàng ngàn bông hoa tulip rực rỡ đua nhau khoe sắc màu tuyệt đẹp. Ngoài hoa tulip, bạn có thể chiêm ngưỡng nhiều loại hoa khác như hoa thủy tiên vàng, hoa loa kèn, hoa lan và nhiều hoa xinh đẹp khác. (bao gồm vé tham quan vườn hoa Keukenhof).
Từ 16/05 -30/06/2025:
Làng cổ tích Giethoorn – được ví như Venice phiên bản Hà Lan. Bởi lẽ, nơi đây có kênh đào trải dài 7,5km khắp làng. Giethoorn vốn không có đường cái, bạn sẽ không tìm thấy ô tô hay xe bus, thay vào đó, mọi hình thức giao thông chủ yếu bằng đường thuỷ, thông qua kênh đào. Nhờ vậy, những ngôi nhà nhỏ của ngôi làng tuyệt đẹp nổi lên giữa mặt nước như một bức tranh vẽ (bao gồm thuyền dạo quanh Làng cổ tích Giethoorn).
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Đoàn về nhận phòng và nghỉ ngơi tại Amsterdam
Làng cổ tích Giethoorn

Ngày 6: AMSTERDAM – ZAANSE SCHANS – COLOGNE
Sáng: Đoàn ăn sáng tại khách sạn, trả phòng và tham quan:
Zaanse Schans – khu đồng quê Zaanse Schans với những ngôi nhà xinh xắn được xây dựng từ thế kỷ 17, 18, được dời đến từ các vùng lân cận, đặc biệt là từ vùng Zaandam và tái tạo để trở thành một viện bảo tàng sinh thái rất sinh động với những cối xay gió còn hoạt động. Đến khu đồng quê Zaanse Schans, du khách còn thăm xưởng đóng giầy và sản xuất Phomai – Cheese and Clog Factory
Trưa: Ăn trưa tại nhà hàng địa phương và di chuyển đến Cologne – trung tâm văn hóa lớn của vùng đất dọc sông Rhine và có một khung cảnh nghệ thuật sôi động.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Đoàn về nhận phòng và nghỉ ngơi tại Cologne.
khu đồng quê Zaanse Schans

Ngày 7: COLOGNE – BONN – FRANKFURT
Sáng: Đoàn ăn sáng tại khách sạn, trả phòng sau đó tham quan:
Nhà thờ Dom cổ kính – một trong những nhà thờ đẹp nhất của Đức nói riêng và Châu Âu nói chung. Kiến trúc của nhà thờ cao 157m, tương đương với một tòa nhà 40 tầng, khi nhìn từ dưới lên nhà thờ Cologne cho bạn có cảm giác dường như nó đang chạm đến với bầu trời. Đây cũng là một trong những ví dụ ngoạn mục nhất của kiến trúc Gothic ở châu Âu.Ngoài ra, nhà thờ Cologne còn là một di sản thế giới được UNESCO công nhận.
Cầu Hohenzollern Hohenzollern là cầu đường sắt bắc qua sông Rhine tại thành phố du lịch Cologne nổi tiếng của Đức. Tại đây các cặp tình nhân bắt đầu sử dụng ổ khóa gắn lên và ném chìa khóa xuống dòng sông Rhine. Thuở đầu, chủ sở hữu của cây cầu là Deutsch-Bahn đã phản đối kịch liệt hành động này. Nhưng sau đó, ông đã chấp thuận và từ đó cây cầu Hohenzollern đã trở thành một điểm đến thu hút của thành phố và cả nước Đức. Không chỉ có các cặp tình nhân, còn rất nhiều du khách đến cầu Hohenzollern níu chân để đọc những thông điệp được khắc trên các ổ khóa về tình yêu mà các cặp đôi dành cho nhau bằng những nét bút được khắc tỉ mỉ.
Trưa: Ăn trưa tại nhà hàng địa phương sau đó tiếp tục tham quan:
Nhà Beethoven được xem là nơi tôn vinh kỷ niệm cuộc đời và sự nghiệp của Beethoven. Nó bao gồm cả nơi sinh sống của ông, phòng làm việc, và các phòng trưng bày về cuộc sống và tác phẩm của ông.
Đại học Bonn là một trong những trường đại học hàng đầu ở Đức, nơi này đã đào tạo, sản sinh ra bảy người đoạt Giải Nobel, hai người đoạt Huy chương Fields, 12 người đoạt Giải Gottfried Wilhelm Leibniz, Đức Giáo hoàng Biển Đức XVI, Joseph Goebbels, Karl Marx, Friedrich.
Đoàn di chuyển đến Frankfurt
Tối: Đoàn ăn tối tại nhà hàng địa phương và nhận phòng và Nghỉ đêm tại Frankfurt
Đại học Bonn

Ngày 8: FRANKFURT – VIỆT NAM
Sáng: Đoàn ăn sáng tại khách sạn, trả phòng. Đoàn tham quan:
Romerberg Square – quảng trường trung tâm của Frankfurt, nơi tụ họp của dân địa phương trong các lễ hội đặc biệt là lễ giáng sinh. Khu vực này nổi bật với 11 tòa nhà cũ được xây dựng từ thế kỷ 15 – thế kỷ 18 bao gồm Old Town Hall với Imperial Hall tạo nên một không gian lộng lẫy.
Nhà thờ St. Nicholas đứng sừng sững tại trung tâm của Old Town. Du khách hãy đến đây để thưởng thức hòa nhạc hoặc thánh lễ hay chỉ đơn giản là chiêm ngưỡng kiến trúc của nhà thờ.
Biểu tượng đồng Euro của Liên minh Châu Âu.
Trưa: Ăn trưa tại nhà hàng địa phương. Tự do mua sắm hàng hóa thương hiệu của Đức với giá thành rất hấp dẫn tại: Trung tâm thương mại, hoặc khu phố My Zeil, hoặc trung tâm thương mại Zeilgalerie, …
Sau đó đoàn di chuyển ra sân bay, chuyến bay dự kiến:
CA932 FRA – PEK 20:00 – 11:25+1
Nhà thờ St. Nicholas

Ngày 9: TRANSIT – BẮC KINH (Nghỉ ngơi tại phòng chờ)
Tới sân bay Bắc Kinh, quý khách làm thủ tục quá cảnh, nghỉ ngơi tại phòng chờ của hãng Hàng Không Air China. Sau đó quý khách lên máy bay về Việt Nam trên chuyến bay dự kiến:
CA903 PEK – SGN 20:15 – 00:40+1

Ngày 10: TP. HỒ CHÍ MINH
00h40: Về đến Việt Nam, kết thúc chương trình. Hướng dẫn viên tạm biệt và hẹn gặp lại quý khách.
Chia tay Quý khách. Hẹn gặp lại quý khách!',
    'Đối với người nước ngoài, việt kiêu, người già & trẻ em:
Quý khách mang quốc tịch nước ngoài hoặc Việt Kiều phải có visa ETIAS đã khai mang theo lúc đi tour.
Visa tái nhập vào Việt Nam cho người nước ngoài hoặc khách Việt Kiều (Visa nhận tại cửa khẩu và có giá trị vào Việt Nam 1 lần – trong 3 tháng đối với Việt kiều). (liên hệ báo giá tại thời điểm khởi hành)
Mang theo tờ khai hải quan nhập cảnh visa và 02 ảnh 4x6cm
Quý khách mang 2 Quốc tịch (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Quý khách chỉ mang thẻ xanh (thẻ tạm trú tại nước ngoài) và không còn hộ chiếu VN còn hiệu lực thì không du lịch sang nước thứ ba được.
Trường hợp trẻ em đi với người nhà (không phải Bố Mẹ) phải nộp kèm giấy ủy quyến được chính quyền địa phương xác nhận (do Bố Mẹ ủy quyền dắt đi tour).
Đối với khách hàng hơn 70 tuổi, quý khách và gia đình cam kết đảm bảo tình trạng sức khoẻ để có thể tham gia tour với công ty khi đăng ký. Bất cứ sự cố nào xảy ra trên tour, Công Ty sẽ không chịu trách nhiệm.
CHÍNH SÁCH HOÀN/HỦY/KHÔNG ĐẠT VISA – QUY PHẠM QUY ĐỊNH XUẤT/NHẬP CẢNH
Trong trường hợp không thể tham dự được tour, quý khách vui lòng thông báo cho Công ty và chịu phí huỷ như sau :
* Hủy tour sau khi đăng ký: Phạt 100% tiền cọc tour
Hủy tour sau khi nộp lịch hẹn visa: Phạt 100% tiền cọc tour
* Hủy tour sau khi có visa: Phạt 100% tổng giá trị tour
Khách bị từ chối xuất cảnh tại Việt Nam hoặc nhập cảnh tại nơi đến: Khách chịu 100% tổng chi phí tour (không được hoàn tiền).
Trường hợp đến ngày khởi hành mà khách vẫn chưa ra kịp kết quả visa, quý khách có thể chọn ngày khởi hành tour kế tiếp hoặc nhận lại tiền tour đã đóng sau khi trừ đi chi phí visa 5.500.000 VND/khách.
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên), nếu một người trong nhóm không đạt visa mà huỷ tour thì khách rớt visa đóng phí 5.500.000 VNĐ và chi phí vé (nếu có), nhưng các thành viên khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Trong trường hợp hủy tour, quý khách vui lòng mang biên lai đóng tiền và CMND/CCCD đến trực tiếp văn phòng làm thủ tục hủy tour. Công ty sẽ không giải quyết các trường hợp liên hệ hủy tour qua điện thoại).
Chương trình tour theo giá ưu đãi, không áp dụng cho chuyển đổi hoặc dời ngày tour.

Ghi chú:
Quý khách vui lòng xem kỹ chương trình, giá tour, phần bao gồm và không bao gồm được liệt kê chi tiết trong chương trình.
Quý khách vui lòng đem theo Passport (bản chính), và đóng cọc 30.000.000 khi đăng ký tour số tiền còn lại sẽ đóng 25 ngày trước khởi hành.
Trường hợp không đạt visa từ 30 – 11 ngày trước khởi hành, thì phí không hoàn lại là 5.500.000 VND (bao gồm phí nộp lãnh sự, TLS, dịch thuật..), nếu quý khách sử dụng dịch vụ visa Premium thì phí không hoàn lại là 6.700.000 VNĐ (bao gồm phí nộp lãnh sự, TLS premium, dịch thuật..).
Trường hợp không đạt visa trước 10 ngày, thì phí không hoàn lại là 12.500.000 VND (bao gồm phí nộp lãnh sự, dịch thuật) và chi phí vé máy bay…
Tùy theo điều kiện thực tế mà chương trình tham quan có thể thay đổi hành trình lên xuống cho phù hợp tuy nhiên các tuyến điểm Du Lịch vẫn đảm bảo đầy đủ.
Các chuyến bay có thể thay đổi vào giờ chót tùy thuộc vào các hãng hàng không, thời tiết…
Trường hợp Quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, công ty được miễn trừ trách nhiệm và sẽ không hoàn trả tiền tour.
Tùy theo tình hình cấp Visa của Lãnh Sự Quán và vé máy bay, ngày khởi hành có thể dời lại từ 1 đến 10 ngày so với ngày khởi hành ban đầu, trường hợp quý khách và công ty không thể thỏa thuận dời ngày chuyến đi sang ngày gần nhất, chi phí không hoàn lại 10.000.000 VNĐ/khách
Hồ sơ xin visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại. Công ty được miễn trừ trách nhiệm trong trường hợp xảy ra thiên tai, động đất, hạn hán, biểu tình, đình công, dịch bệnh, trục trặc kỹ thuật máy bay,…dẫn đến dời, hủy, hoãn chuyến bay. Nếu những trường hợp trên xảy ra, công ty sẽ xem xét để hoàn trả chi phí cho khách trong điều kiện có thể (sau khi đã trừ lại các dịch vụ đã thực hiện như phí làm visa, tiền vé máy bay….và không chịu trách nhiệm bồi thường thêm bất kỳ chi phí nào khác).

Quy trình đăng ký và thực hiện
Khách hàng điền phiếu đăng ký và cung cấp hồ sơ xin visa trước ngày khởi hành ít nhất 45 ngày.
Đóng tiền đặt cọc tour 30.000.000 vnđ/khách
Hoàn tất thanh toán tiền tour 25 ngày trước khởi hành. (trường hợp quý khách bị lãnh sự quán báo rớt Visa sau khi đã đóng hết tiền tour, chúng tôi sẽ hoàn trả lại tiền tour theo đúng quy định, sau khi trừ các chi phí như visa 5.500.000 vnđ +tiền vé máy bay nếu có….).
Hoàn tất tiền ký quỹ (nếu có) ngay sau khi có kết quả Visa. Công ty sẽ hướng dẫn thủ tục visa, cách điền các mẫu đơn visa, đăng ký ngày nộp hồ sơ, khách hàng phải có mặt để nộp hồ sơ và mang theo hồ sơ bảng gốc để đối chiếu

Hồ sơ xin visa du lịch châu âu
Để chuẩn bị tốt nhất cho việc xin visa nhập cảnh vào Châu Âu theo, Công ty đề nghị Quý Khách chuẩn bị đầy đủ các hồ sơ sau:

Cá nhân:
Hộ chiếu cả mới và cũ (gốc) còn hạn 6 tháng, có ký tên trong hộ chiếu, hộ chiếu sao y tất cả trang có dấu
2 ảnh 3,5×4,5cm nền trắng, tỉ lệ mặt chiếm 70% – 80% khung hình, chụp từ cổ trở lên, không cười, không che tai và chân mày, chụp mới nhất không quá 3 tháng
Hộ khẩu nguyên cuốn sao y
Căn cước công dân sao y công chứng trên mặt giấy A4
Chứng nhận kết hôn công chứng trên mặt giấy A4 (nếu có), ly hôn (nếu có), hoặc xác nhận tình trạng hôn nhân từ địa phương.
Giấy khai sinh công chứng trên mặt giấy A4 (của con nếu đi vs con, của mình nếu đi với bố mẹ), giấy ủy quyền cho bố (hoặc mẹ) nếu chỉ đi du lịch cùng mẹ (hoặc bố)

Công việc:
Khách hàng là chủ doanh nghiệp
Giấy phép kinh doanh.
Biên lai đóng thuế 3 tháng gần nhất.
Sao kê tài khoản công ty 3 tháng gần nhất
Khách hàng làm việc có HĐ
Hợp đồng lao động.
Bảo hiêm xã hội là bắt buộc
Xác nhận mức lương 3 tháng gần nhất
Đơn xin nghỉ phép đi du lịch
Nếu Công ty tài trợ cho đi du lịch thì phải có giấy xác nhận
Khách hàng là học sinh
Giấy xác nhận của trường, thẻ học sinh
Đơn xin nghỉ phép

Tài chính
Sổ tiết kiệm và xác nhận số dư tài khoản ngân hàng 200 triệu trở lên
Giấy tờ sở hữu nhà đất, Hợp đồng cho thuê nhà (nếu có cho thuê nhà).
Giấy chứng nhận sở hữu các tài sản khác nếu có như: xe hơi, cổ phiếu, cổ phần, trái phiếu…

Công ty du lịch cung cấp
Thư mời của đối tác CÔNG TY DU LỊCH tại Châu Âu có đầy đủ thông tin khách hàng
Xác nhận lịch trình đi, khách sạn, vận chuyển, ăn uống, tham quan (tiếng anh)
Hợp đồng du lịch và Chương trình tour chi tiết. (tiếng việt).
Bảo Hiểm du lịch Quốc Tế.
Điền các mẫu đơn cần thiết theo yêu cầu của ĐSQ, LSQ
Lấy ngày hẹn phỏng vấn, đóng phí phỏng vấn.
Tư vấn cho khách trước khi đi trình diện nộp hồ sơ tại LSQ
Yêu cầu trên dành chung cho tất cả Quý khách. Khi thực hiện hồ sơ, tùy từng trường hợp cụ thể chuyên viên của công ty sẽ tư vấn riêng cho từng khách.
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.',
    'https://fiditour.com/wp-content/uploads/2025/03/tourchauau.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau2.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau3.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau4.jpg
https://fiditour.com/wp-content/uploads/2025/03/tourchauau5.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/tour-chau-au-5-nuoc-phap-luxembourg-bi-ha-lan-duc10n8d-air-china-khoi-hanh-tu-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11872', 'Nhật Bản: Kansai - Kobe - Osaka - Kyoto - Nagoya - Yamanashi 5N5Đ',
    'TP.HCM', 'Nhật Bản', '5N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 27 DAY) + INTERVAL 7 HOUR,
    33890000, 25418000, 30, 29, 'https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban-2.jpg',
    'Đến sân bay Kansai, làm thủ tục nhập cảnh, nhận phần ăn sáng. Di chuyển tham quan : Bảo tàng rượu Hakutsuru Sake Brewery: một địa danh du lịch nổi tiếng Kobe, Nhật Bản. Quý khách tìm hiểu quy trình chế biến rượu sake ở Nhật Bản, sẽ được…',
    'Ngày 1: KANSAI – KOBE – OSAKA
Sáng : Đến sân bay Kansai, làm thủ tục nhập cảnh, nhận phần ăn sáng. Di chuyển tham quan :
Bảo tàng rượu Hakutsuru Sake Brewery: một địa danh du lịch nổi tiếng Kobe, Nhật Bản. Quý khách tìm hiểu quy trình chế biến rượu sake ở Nhật Bản, sẽ được mời thử vài loại rượu sake sau khi hiểu phương pháp nấu loại rượu quan trọng này của người Nhật.
Cầu cảng Kobe: nổi tiếng với tháp cảng Kobe là một thiết kế rất độc đáo, hiếm có trên thế giới.
Ăn trưa tại nhà hàng với đặc sản bò Kobe trứ danh. Buổi chiều, quý khách di chuyển đến Osaka tham quan:
Lâu đài Osaka: là biểu tượng chính của Osaka, được xây dựng từ thế kỷ XVI bởi Toyotomi Hideyoshi – người đầu tiên hoàn thành công cuộc thống nhất Nhật Bản. (chụp ảnh bên ngoài)
Thưởng thức Maiko Show: quý khách sẽ được thưởng thức màn biểu diễn múa hát và chơi nhạc cụ truyền thống của Nhật Bản của các Maiko (Geisha tập sự). Đồng thời, có cơ hội mặc Kimono giản lược và chụp hình lưu niệm cùng Maiko, là một trải nghiệm đầy thú vị để hiểu rõ thêm về một nét văn hóa truyền thống đắc trưng của Nhật Bản.
Tối : Đoàn dùng bữa tối. Nghỉ đêm tại khách sạn 4 sao Osaka.
Cầu cảng Kobe

Ngày 2: OSAKA – KYOTO – NAGOYA
Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Di chuyển tham quan:
Đền Fushimi Inari: mệnh danh là Ngôi đền Nghìn cổng huyền thoại với hơn 1000 cổng Tori lấp lánh, các màu đỏ cam linh thiêng.
Rừng tre Arashiyama: một rừng tre tự nhiên ở Arashiyama, Kyoto, Nhật Bản, nổi tiếng vì cảnh quan đẹp, thu hút khách du lịch. Rừng bao gồm phần lớn là trúc sào và bao gồm một số con đường cho khách du lịch và khách tham qua
Trưa : Dùng bữa trưa tại nhà hàng địa phương. Buổi chiều, đoàn di chuyển đến Nagashima tham quan:
Tham quan, mua sắm tự do tại Trung tâm mua sắm Mitsui Jazz Dream Nagashima: một trong những trung tâm mua sắm lớn nhất Nhật Bản với hơn 240 cửa hàng với đa dạng hàng hóa. Quý khách có thể mua sắm từ thương hiệu sang trọng đến thương hiệu bình dân nổi tiếng tại Nhật Bản, đồng thời trải nghiệm ẩm thực và các hoạt động giải trí khác.
Tối: Đoàn dùng bữa tối và nhận phòng khách sạn. Nghỉ đêm tại Nagoya.
Rừng tre Arashiyama

Ngày 3: NAGOYA – YAMANASHI
Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Sau đó, trải nghiệm di chuyển bằng Shinkasen – 1 trong những niềm tự hào của nền giao thông Nhật Bản, đoàn tham quan.
Lưu ý: Các đoàn khởi hành ngày 30/04, 01/05 đến 15/05, tham quan:
Lễ hội Fuji Shibazakura (hoa chi anh): được tổ tại khu vực Phú Sĩ Ngũ Hồ, cánh đồng hoa chi anh màu hồng, trắng, tím phủ đầy cánh đồng tạo nên khung cảnh nên thơ hiếm thấy.
Lưu ý: riêng đoàn khởi hành từ 17/04/2025, 24/05/2025, 28/05/2025 sẽ tham quan:
Trải nghiệm Văn hoá “Trà đạo” – một nét truyền thống văn hóa đặc sắc của đất nước Nhật Bản.
Trưa : Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Núi Phú Sĩ – Là ngọn núi cao nhất Nhật Bản so với mực nước biển là 3776 mét. Đây cũng là danh lam thắng cảnh, di tích lịch sử, và đã được công nhận là di sản văn hóa thế giới. Quý khách sẽ lên trạm dừng chân thứ 5 ở độ cao 2.300m để ngắm núi Phú Sĩ rõ hơn (Nếu thời tiết cho phép).
Làng văn hoá Oshino Hakkai: được Unesco công nhận là Di sản Văn hóa Thế giới. Nơi đây là điểm đến lý tưởng dành cho những người yêu thích sự yên bình, cảm nhận thiên nhiên tươi đẹp của du lịch Nhật.
Tối : Đoàn dùng bữa tối tại nhà hàng địa phương với đặc sản Cua Tuyết. Sau đó đoàn về khách sạn nhận phòng nghỉ ngơi tại Yamanashi.
Trải nghiệm tắm Onsen – một kiểu ôn tuyền thủy liệu pháp của người Nhật.
Làng văn hoá Oshino Hakkai

Ngày 4: YAMANASHI – TOKYO – NARITA
Sáng: Quý khách dùng điểm tâm sáng. Đoàn làm thủ tục trả phòng. Khởi hành đi Tokyo:
Hoàng Cung – nơi Nhật Hoàng sống và làm việc. (tham quan và chụp ảnh bên ngoài)
Trưa: Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Chùa Asakusa: còn gọi là Sensoji – với lối kiến trúc đặc trưng mang đậm dấu ấn Nhật Bản, có thể nói đây là ngôi chùa cổ nhất và quan trọng bậc nhất Tokyo. Chụp hình với chiếc đèn lồng bằng giấy khổng lồ treo ở chính giữa cổng là biểu tượng của Asakusa. Dạo quanh phố mua sắm Nakamise dẫn vào chùa Asakusa nhộn nhịp với hằng trăm gian hàng đồ truyền thống, quà lưu niệm và món ăn địa phương.
Tháp truyền hình Tokyo Skytree: một trong những biểu tượng của Nhật Bản (chụp ảnh bên ngoài).
Dạo phố, mua sắm tại trung tâm điện tử Akihabara: gắn liền với các nhân vật anime và manga nổi tiếng được trưng bày trong các cửa hàng (nếu có đủ thời gian)
Tối: Xe đưa đoàn dùng bữa tối, nhận phòng. Nghỉ đêm tại khách sạn 4 sao tại Narita.
Dạo phố, mua sắm tại trung tâm điện tử Akihabara

Ngày 5: NARITA ✈ TP.HCM (Ăn sáng – Ăn trưa trên máy bay).
Sáng: Quý khách dùng bữa sáng, làm thủ tục trả phòng, sau đó xe đưa đoàn ra sân bay quốc tế Narita và làm thủ tục đáp chuyến bay Vietjet air VJ823 NRT-SGN 08:55 – 12:55 về lại TP. Hồ Chí Minh.
Đáp xuống Sân bay Tân Sơn nhất, chia tay đoàn và hẹn gặp lại quý khách.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Quy định vé trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% trọn gói giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 10 tuổi: 80% trọn gói giá tour người lớn (Không có chế độ giường riêng).
Trẻ em đủ 10 tuổi trở lên: 100% trọn gói giá tour người lớn.
Trẻ em có yêu cầu ngủ riêng thu 100% giá tour người lớn.

Điều kiện hủy tour
Nếu hủy tour khách thanh toán các khoản lệ phí hủy tour, hủy vé máy bay cụ thể:
Nếu hủy chuyến du lịch ngay sau khi Đại Sứ Quán, Lãnh Sự Quán đã cấp visa: công ty du lịch có quyền hủy visa đã có, đồng thời khách sẽ chịu phí hủy theo điều khoản bên dưới:
Ngay sau khi đặt cọc tour và trước ngày khởi hành là 30 ngày: Phí hủy là 3.000.000 VNĐ
Trước ngày đi 21-30 ngày : Thanh toán 50% trên giá tour .
Trước ngày đi 14-21 ngày : Thanh toán 70% trên giá tour .
Trước ngày đi 14 ngày : Thanh toán 100% trên giá tour .
Trường hợp Quý khách bị từ chối visa : sẽ được hoàn phí 100%.
(Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy và chủ nhật). Riêng tour Lễ Tết không được phép hoàn hủy.
Việc hủy bỏ tour với CTY phải được thông báo trực tiếp qua Fax, email, tin nhắn điện thoại và phải được CTY xác nhận. Việc hủy bỏ qua điện thoại không được chấp thuận.

Lưu ý
Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận sức khỏe để đi du lịch nước ngoài do bác sĩ cấp và giấy cam kết sức khỏe với Công ty. Bất cứ sự cố nào xảy ra trên tour, Công ty du lịch sẽ không chịu trách nhiệm.
Quý khách mang thai xin vui lòng báo cho Công Ty khi đăng ký tour để được tư vấn thêm thông tin. Không nhận khách mang thai từ 5 tháng trở lên vì lí do an toàn cho khách.
Giá tour không bao gồm chi phí visa tái nhập vào Việt Nam đối với Việt kiều & Ngoại kiều.
Khi đăng ký, Quý Khách vui lòng nộp hộ chiếu còn giá trị trên 6 tháng tính từ ngày về.
Trường hợp quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, Công Ty sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Nếu khách là Việt kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Thứ tự và chi tiết trong chương trình có thể thay đổi để phù hợp với tình hình khách quan (thời tiết, giao thông…)
CTY sẽ không chịu trách nhiệm bảo đảm điểm tham quan trong các trường hợp xảy ra thiên tai, sự cố về an ninh, sự cố về hàng không,…
Khi đăng ký tour du lịch, Quý khách vui lòng đọc kỹ chương trình, giá tour, các khoản bao gồm cũng như không bao gồm trong chương trình, các điều kiện hủy tour trên biên nhận đóng tiền. Trong trường hợp Quý khách không trực tiếp đến đăng ký tour mà do người khác đến đăng ký thì Quý khách vui lòng tìm hiểu kỹ chương trình từ người đăng ký cho mình.

Hồ sơ xin visa nhật bản
Để tạo điều kiện cho việc xét duyệt visa được nhanh chóng. Quý khách vui lòng chuẩn bị & hoàn tất hồ sơ theo hướng dẫn sau đây:
Cá nhân
(Bắt buộc)
Hộ chiếu gốc còn giá trị sử dụng trên 6 tháng tính đến ngày kết thúc chuyến đi. (Nếu từng sử dụng hộ chiếu cũ, xin vui lòng photo copy kèm theo passport cũ). + file bản scan hộ chiếu gốc thấy rõ thông tin và 4 góc có CHỮ KÝ của người xin visa.
01 file ảnh + 02 ảnh khổ 3,5 x 4,5 cm nền trắng (Hình chụp không quá 6 tháng).
Căn Cước Công Dân photo.
Hộ khẩu thường trú photo / CT07 photo.
Bản sao công chứng giấy đăng ký kết hôn (nếu vợ chồng đi cùng nhau).
Giấy khai sinh (Nếu đi chung với bố mẹ).
Tài chính
(Bắt buộc)
* Tài liệu chứng minh năng lực chi trả kinh phí chuyến đi :
Sao kê tài khoản ngân hàng có thể hiện lương / thu nhập (6 tháng gần nhất) và có số dư trên 100.000.000 VNĐ (bản gốc)
Hoặc Chứng nhận tiền gửi có kì hạn. (Tối thiểu trên 100.000.000) (Ngày gửi phải trước 3 tháng khi nộp hồ sơ và có ngày đáo hạn phải sau ngày kết thúc chuyến đi.) (bản gốc)
Công việc
(Bắt buộc)
Khách hàng là chủ doanh nghiệp
Khách hàng là nhân viên
Giấy phép đăng ký kinh doanh (Bản photo).
Biên lai nộp thuế 03 tháng gần nhất (Bản photo ).
1. Hợp đồng lao động (Bản photo).
2. Photo bảo hiểm xã hội / Bảo hiểm Y tế (Nếu có).
Khách là người về hưu : Sổ hưu hoặc quyết định hưu trí (Bản photo)
Khách là học sinh / sinh viên : Thẻ học sinh / sinh viên (Bản photo)
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa… (Thay đổi sẽ không được báo trước) thì Cty sẽ giữ quyền lợi thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban2-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-nhat3123-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-nhat.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-nhat-ban-kansai-kobe-osaka-kyoto-nagoya-yamanashi5n5d-khoi-hanh-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11848', 'Nhật Bản: Osaka - Kobe - Kyoto - Yamanashi - Tokyo 5N5Đ',
    'TP.HCM', 'Nhật Bản', '5N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 30 DAY) + INTERVAL 7 HOUR,
    35890000, 26918000, 35, 31, 'https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban.jpg',
    'Đến sân bay Kansai, làm thủ tục nhập cảnh, ăn sáng. Di chuyển tham quan : Lâu đài Osaka: là biểu tượng chính của Osaka, được xây dựng từ thế kỷ XVI bởi Toyotomi Hideyoshi – người đầu tiên hoàn thành công cuộc thống nhất Nhật Bản. (chụp ảnh…',
    'Ngày 1: OSAKA – KOBE
Sáng : Đến sân bay Kansai, làm thủ tục nhập cảnh, ăn sáng. Di chuyển tham quan :
Lâu đài Osaka: là biểu tượng chính của Osaka, được xây dựng từ thế kỷ XVI bởi Toyotomi Hideyoshi – người đầu tiên hoàn thành công cuộc thống nhất Nhật Bản. (chụp ảnh bên ngoài)
Thưởng thức Maiko Show: quý khách sẽ được thưởng thức màn biểu diễn múa hát và chơi nhạc cụ truyền thống của Nhật Bản của các Maiko (Geisha tập sự). Đồng thời, có cơ hội mặc Kimono giản lược và chụp hình lưu niệm cùng Maiko, là một trải nghiệm đầy thú vị để hiểu rõ thêm về một nét văn hóa truyền thống đắc trưng của Nhật Bản.
Ăn trưa tại nhà hàng với đặc sản bò Kobe trứ danh. Buổi chiều, quý khách di chuyển đến Kobe tham quan:
Bảo tàng rượu Hakutsuru Sake Brewery: một địa danh du lịch nổi tiếng Kobe, Nhật Bản. Quý khách tìm hiểu quy trình chế biến rượu sake ở Nhật Bản, sẽ được mời thử vài loại rượu sake sau khi hiểu phương pháp nấu loại rượu quan trọng này của người Nhật.
Cầu cảng Kobe: nổi tiếng với tháp cảng Kobe là một thiết kế rất độc đáo, hiếm có trên thế giới.
Tối : Đoàn dùng bữa tối. Nghỉ đêm tại khách sạn 4 sao Osaka.
Cầu cảng Kobe

Ngày 2: OSAKA – KYOTO – NAGOYA
Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Di chuyển tham quan:
Lưu ý: các đoàn khởi hành từ 05/03/2025 tham quan:
Con đường hoa anh đào nở sớm tại Yodo Suiro: một trong những điểm ngắm hoa anh đào nở sớm (Kawazu Sakura) được yêu thích nhất tại Nhật Bản. Trải nghiệm không khí lễ hội hoa anh đào, tản bộ ngắm cảnh chụp hình dưới tán hoa anh đào rực rỡ với cả con đường ngập trang trong sắc hồng.
Lưu ý: các đoàn khởi hành từ 21/03/2025 – 10/04/2025, tham quan:
Con đường Triết học (Tetsugaku no Michi): điểm ngắm hoa anh đào tuyệt đẹp tại Kyoto với con đường lát đá dài khoảng 2km xinh đẹp men theo một con kênh được bao quanh bởi hàng trăm cây anh đào. Con đường được đặt tên theo Nishida Kitaro – triết học gia nổi tiếng nhất của Nhật Bản.
Trưa : Dùng bữa trưa tại nhà hàng địa phương. Buổi chiều, đoàn di chuyển đến Nagashima tham quan:
Tham quan, mua sắm tự do tại Trung tâm mua sắm Mitsui Jazz Dream Nagashima: một trong những trung tâm mua sắm lớn nhất Nhật Bản với hơn 240 cửa hàng với đa dạng hàng hóa. Quý khách có thể mua sắm từ thương hiệu sang trọng đến thương hiệu bình dân nổi tiếng tại Nhật Bản, đồng thời trải nghiệm ẩm thực và các hoạt động giải trí khác.
Tối: Đoàn dùng bữa tối và nhận phòng khách sạn. Nghỉ đêm tại Nagoya.
Con đường hoa anh đào nở sớm tại Yodo Suiro

Ngày 3: NAGOYA – YAMANASHI
Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Sau đó, trải nghiệm di chuyển bằng Shinkasen – 1 trong những niềm tự hào của nền giao thông Nhật Bản, đoàn tham quan.
Núi Phú Sĩ – Là ngọn núi cao nhất Nhật Bản so với mực nước biển là 3776 mét. Đây cũng là danh lam thắng cảnh, di tích lịch sử, và đã được công nhận là di sản văn hóa thế giới. Quý khách sẽ lên trạm dừng chân thứ 5 ở độ cao 2.300m để ngắm núi Phú Sĩ rõ hơn (Nếu thời tiết cho phép).
Trải nghiệm Văn hoá “Trà đạo” – một nét truyền thống văn hóa đặc sắc của đất nước Nhật Bản.
Trưa : Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Làng văn hoá Oshino Hakkai: được Unesco công nhận là Di sản Văn hóa Thế giới. Nơi đây là điểm đến lý tưởng dành cho những người yêu thích sự yên bình, cảm nhận thiên nhiên tươi đẹp của du lịch Nhật.
Tối : Đoàn dùng bữa tối tại nhà hàng địa phương. Sau đó đoàn về khách sạn nhận phòng nghỉ ngơi tại Yamanashi.
Trải nghiệm tắm Onsen – một kiểu ôn tuyền thủy liệu pháp của người Nhật.
Núi Phú Sĩ

Ngày 4: YAMANASHI – TOKYO – NARITA
Sáng: Quý khách dùng điểm tâm sáng. Đoàn làm thủ tục trả phòng. Khởi hành đi Tokyo:
Lưu ý: các đoàn khởi hành từ 05/03/2025, 10/04/2025 sẽ tham quan:
Hoàng Cung – nơi Nhật Hoàng sống và làm việc. (tham quan và chụp ảnh bên ngoài)
Lưu ý: các đoàn khởi hành từ 21/03/2025 – 02/04/2025 sẽ tham quan:
Công viên Ueno – là địa điểm ngắm hoa anh đào nổi tiếng, ở đây có hơn 1200 gốc hoa anh đào, một trong những nơi diễn ra Lễ hội Hoa Anh Đào lớn và đông đúc nhất ở Nhật Bản
Trưa: Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Chùa Asakusa: còn gọi là Sensoji – với lối kiến trúc đặc trưng mang đậm dấu ấn Nhật Bản, có thể nói đây là ngôi chùa cổ nhất và quan trọng bậc nhất Tokyo. Chụp hình với chiếc đèn lồng bằng giấy khổng lồ treo ở chính giữa cổng là biểu tượng của Asakusa. Dạo quanh phố mua sắm Nakamise dẫn vào chùa Asakusa nhộn nhịp với hằng trăm gian hàng đồ truyền thống, quà lưu niệm và món ăn địa phương.
Tháp truyền hình Tokyo Skytree: một trong những biểu tượng của Nhật Bản (chụp ảnh bên ngoài).
Dạo phố, mua sắm tại trung tâm điện tử Akihabara: gắn liền với các nhân vật anime và manga nổi tiếng được trưng bày trong các cửa hàng (nếu có đủ thời gian)
Tối: Xe đưa đoàn dùng bữa tối, nhận phòng. Nghỉ đêm tại khách sạn 4 sao tại Narita.
Chùa Asakusa

Ngày 5: NARITA ✈ TP.HCM (Ăn sáng – Ăn trưa trên máy bay).
Sáng: Quý khách dùng bữa sáng, làm thủ tục trả phòng, sau đó xe đưa đoàn ra sân bay quốc tế Narita và làm thủ tục đáp chuyến bay Vietnamairlines VN307 NRT-SGN 09:30 – 14:10 về lại TP. Hồ Chí Minh.
Đáp xuống Sân bay Tân Sơn nhất, chia tay đoàn và hẹn gặp lại quý khách.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Quy định vé trẻ em:
Trẻ nhỏ dưới 2 tuổi: 30% trọn gói giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 10 tuổi: 80% trọn gói giá tour người lớn (Không có chế độ giường riêng).
Trẻ em đủ 10 tuổi trở lên: 100% trọn gói giá tour người lớn.
Trẻ em có yêu cầu ngủ riêng thu 100% giá tour người lớn.

Điều kiện hủy tour
Nếu hủy tour khách thanh toán các khoản lệ phí hủy tour, hủy vé máy bay cụ thể:
Nếu hủy chuyến du lịch ngay sau khi Đại Sứ Quán, Lãnh Sự Quán đã cấp visa: công ty du lịch có quyền hủy visa đã có, đồng thời khách sẽ chịu phí hủy theo điều khoản bên dưới:
Ngay sau khi đặt cọc tour và trước ngày khởi hành là 30 ngày: Phí hủy là 3.000.000 VNĐ
Trước ngày đi 21-30 ngày : Thanh toán 50% trên giá tour .
Trước ngày đi 14-21 ngày : Thanh toán 70% trên giá tour .
Trước ngày đi 14 ngày : Thanh toán 100% trên giá tour .
Trường hợp Quý khách bị từ chối visa : sẽ được hoàn phí 100%.
(Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy và chủ nhật). Riêng tour Lễ Tết không được phép hoàn hủy.
Việc hủy bỏ tour với CTY phải được thông báo trực tiếp qua Fax, email, tin nhắn điện thoại và phải được CTY xác nhận. Việc hủy bỏ qua điện thoại không được chấp thuận.

Lưu ý
Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận sức khỏe để đi du lịch nước ngoài do bác sĩ cấp và giấy cam kết sức khỏe với Công ty. Bất cứ sự cố nào xảy ra trên tour, Công ty du lịch sẽ không chịu trách nhiệm.
Quý khách mang thai xin vui lòng báo cho Công Ty khi đăng ký tour để được tư vấn thêm thông tin. Không nhận khách mang thai từ 5 tháng trở lên vì lí do an toàn cho khách.
Giá tour không bao gồm chi phí visa tái nhập vào Việt Nam đối với Việt kiều & Ngoại kiều.
Khi đăng ký, Quý Khách vui lòng nộp hộ chiếu còn giá trị trên 6 tháng tính từ ngày về.
Trường hợp quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, Công Ty sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Nếu khách là Việt kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Thứ tự và chi tiết trong chương trình có thể thay đổi để phù hợp với tình hình khách quan (thời tiết, giao thông…)
CTY sẽ không chịu trách nhiệm bảo đảm điểm tham quan trong các trường hợp xảy ra thiên tai, sự cố về an ninh, sự cố về hàng không,…
Khi đăng ký tour du lịch, Quý khách vui lòng đọc kỹ chương trình, giá tour, các khoản bao gồm cũng như không bao gồm trong chương trình, các điều kiện hủy tour trên biên nhận đóng tiền. Trong trường hợp Quý khách không trực tiếp đến đăng ký tour mà do người khác đến đăng ký thì Quý khách vui lòng tìm hiểu kỹ chương trình từ người đăng ký cho mình.

Hồ sơ xin visa nhật bản
Để tạo điều kiện cho việc xét duyệt visa được nhanh chóng. Quý khách vui lòng chuẩn bị & hoàn tất hồ sơ theo hướng dẫn sau đây:
Cá nhân
(Bắt buộc)
Hộ chiếu gốc còn giá trị sử dụng trên 6 tháng tính đến ngày kết thúc chuyến đi. (Nếu từng sử dụng hộ chiếu cũ, xin vui lòng photo copy kèm theo passport cũ). + file bản scan hộ chiếu gốc thấy rõ thông tin và 4 góc có CHỮ KÝ của người xin visa.
01 file ảnh + 02 ảnh khổ 3,5 x 4,5 cm nền trắng (Hình chụp không quá 6 tháng).
Căn Cước Công Dân photo.
Hộ khẩu thường trú photo / CT07 photo.
Bản sao công chứng giấy đăng ký kết hôn (nếu vợ chồng đi cùng nhau).
Giấy khai sinh (Nếu đi chung với bố mẹ).
Tài chính
(Bắt buộc)
* Tài liệu chứng minh năng lực chi trả kinh phí chuyến đi :
Sao kê tài khoản ngân hàng có thể hiện lương / thu nhập (6 tháng gần nhất) và có số dư trên 100.000.000 VNĐ (bản gốc)
Hoặc Chứng nhận tiền gửi có kì hạn. (Tối thiểu trên 100.000.000) (Ngày gửi phải trước 3 tháng khi nộp hồ sơ và có ngày đáo hạn phải sau ngày kết thúc chuyến đi.) (bản gốc)
Công việc
(Bắt buộc)
Khách hàng là chủ doanh nghiệp
Khách hàng là nhân viên
Giấy phép đăng ký kinh doanh (Bản photo).
Biên lai nộp thuế 03 tháng gần nhất (Bản photo ).
1. Hợp đồng lao động (Bản photo).
2. Photo bảo hiểm xã hội / Bảo hiểm Y tế (Nếu có).
Khách là người về hưu : Sổ hưu hoặc quyết định hưu trí (Bản photo)
Khách là học sinh / sinh viên : Thẻ học sinh / sinh viên (Bản photo)
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa… (Thay đổi sẽ không được báo trước) thì Cty sẽ giữ quyền lợi thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban2.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-nhat-ban3-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan4-2.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-nhat-ban-osaka-kobe-kyoto-yamanashi-tokyo5n5d-khoi-hanh-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11825', 'Đài Loan: Cao Hùng - Đài Trung - Đài Bắc 5N4Đ',
    'TP.HCM', 'Đài Loan', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 33 DAY) + INTERVAL 7 HOUR,
    12990000, 9742000, 20, 12, 'https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan.jpg',
    'Trưởng đoàn đón Quý khách tại sân bay Tân Sơn Nhất để làm thủ tục đáp chuyến bay đi Đài Loan. Đến sân bay Cao Hùng. Hướng dẫn viên đón đoàn. Chào mừng Quý khách đến với Đài Loan. Trưa : ăn trưa tại nhà hàng địa phương. Đoàn khởi hành đến…',
    'Ngày 1: TP.HCM ✈ CAO HÙNG ( Ăn Trưa,Tối )
Trưởng đoàn đón Quý khách tại sân bay Tân Sơn Nhất để làm thủ tục đáp chuyến bay đi Đài Loan. Đến sân bay Cao Hùng. Hướng dẫn viên đón đoàn. Chào mừng Quý khách đến với Đài Loan.
Trưa : ăn trưa tại nhà hàng địa phương.
Đoàn khởi hành đến Chụp ảnh tại tòa nhà trung tâm âm nhạc Cao Hùng (Kaohsiung Music Center – Nơi đây có khu biểu diễn âm nhạc, kết hợp với cảnh đẹp của cảng và vịnh, tạo nên một địa điểm thăm quan và giải trí mới).
“Trạm tàu điện Formosa Boulevard”. Bên trong nhà ga tàu điện ngầm Formosa Boulevard tại Cao Hùng là một công nghệ nghệ thuật bằng 4.500 tấm kính lớn nhất thế giới. Nhờ hiệu ứng kính vạn hoa đầy ấn tượng, khu vực nhà ga thực sự là điểm lý tưởng để tổ chức các lễ cưới.
“Chợ đêm Lục Hợp” tự do trải nghiệm đời sống chợ đêm và thưởng thức các món đặc sản và hải sản tươi thật hấp dẫn.
Tối : sau khi dùng bữa tối tại nhà hàng địa phương
Đoàn về khách sạn Cao Hùng nhận phòng nghỉ ngơi.
Kaohsiung Music Center

Ngày 2: CAO HÙNG – GIA NGHĨA – ĐÀI TRUNG
Sáng : đoàn ăn sáng tại khách sạn trả phòng,khởi hành tham quan khu quần thể “Đài Xuân Thu” được xây dựng từ năm 1951 – là một di tích Đạo giáo thờ Quan Công, Vị thần Chiến tranh. Tiếp đến “Tháp Long Hổ” là một ngôi đền gồm hai ngôi chùa đầy màu sắc và mang đậm nét hiện đại nổi bật trên Đầm Liên Trì. Các bức bích họa trang trí bên trong mô hình những động vật này sẽ giúp du khách tìm hiểu thêm về phong tục và lịch sử Trung Hoa.
“Phật Quang Sơn Tự’’ được xem là “Thủ đô Phật Giáo Đài Nam”, là thánh địa Phật Giáo cực kỳ nổi tiếng với lối kiến trúc vô cùng hùng vĩ.
Trưa : ăn trưa tại nhà hàng địa phương. Đoàn dừng chân và nghe giới thiệu về đặc sản Trà Ô long của vùng rừng núi A LY SHAN.
“Làng Hinoki” nằm phía đông của thành phố Gia Nghĩa, mang vẻ đẹp cổ kính, hoang sơ và đậm nét kiến trúc ảnh hưởng từ xứ sở Phù Tang. Du khách từ những nước khác có thể chưa biết nhiều đến ngôi làng này nhưng nơi đây cũng là một trong những địa điểm đáng tự hào của người dân Đài Loan đấy.
Tối : Đoàn dùng bữa tại địa phương
Đoàn nhận phòng tại khách sạn Đài Trung , tự do khám phá Đài Trung về đêm
Phật Quang Sơn Tự

Ngày 3: ĐÀI TRUNG – NAM ĐẦU – ĐÀI TRUNG
Sáng : đoàn ăn sáng tại khách sạn khởi hành tham quan “Nhật Nguyệt Đàm’’– Thuộc địa phận xã Yuchi huyện Nantou của miền Trung Đài Loan, Nhật Nguyệt Đàm là hồ nước tự nhiên lớn nhất vùng lãnh thổ này, Nơi đây cảnh sông nước hữu tình, Bốn bề hồ được bao bọc bởi núi non điệp trùng, đem lại cảnh đẹp hùng vĩ và mơ màng cho Nhật Nguyệt, từng là điểm nghỉ dưỡng ưng ý nhất của ông Tưởng Giới Thạch.
Trưa : ăn trưa đặc sản địa phương “Gà Nướng Lu” tại nhà hàng địa phương.Đoàn dừng chân và nghe giới thiệu về đặc sản Nấm Linh Chi của vùng rừng núi Nam Đầu,
“Văn Võ Miếu” – Wen Wu Temple – nằm ở phía Bắc hồ Nhật Nguyệt có tượng sư tử đỏ to lớn uy nghi trấn cửa, bên trong Văn Miếu thờ Khổng Tử và hai đồ đệ của ông, là Mạnh Tử và Zihsih, còn Võ Miếu thờ Quan Công và Nhạc Phi – một danh tướng yêu nước thời Tống.
“Làng Cầu Vồng” Nói là làng Cầu Vòng nhưng ở đây chỉ có vài ngôi nhà đủ màu sắc. Trước đây thì đúng là ngôi làng với 1200 ngôi nhà, do chính phủ thu hồi đất và trao cho các công ty xây dựng nên mới mất dần các ngôi nhà, chỉ còn sót lại vài ngôi nhà như hiện tại.
Tối : Đoàn dùng bữa tối đặc sắc BUFET “ Lẩu QIAN YE” , Đoàn tự do tham quan và mua sắm tại “chợ đêm Đài Trung” nét đặc sắc trong văn hóa chợ đêm của đài loan
Đoàn nghỉ đêm tại Đài Trung.
Wen Wu Temple

Ngày 4: ĐÀI TRUNG – ĐÀI BẮC
Sáng : đoàn ăn sáng tại khách sạn trả phòng , Đoàn khởi hành tham quan “Lâu đài Dứa Vàng Vigor Kobo” Lâu đài Dứa Vigor Kobo được thành lập từ năm 1992 và hiện là thương hiệu nổi tiếng chuyên sản xuất các loại bánh nhân dứa ở Đài Loan
“Làng cổ Thập Phần’’ – Shifen nơi mọi người thường đến để thả thiên đăng,ghi điều ước lên đó và thả lên trời
“Công Viên Địa Chất Dã Liễu” được bình chọn là “Điểm tới tự nhiên đẹp nhất Đài Loan 2013”, với tổng chiều dài 1,7 km và khu đất liền rộng nhất lên tới hơn 300m, Yehliu Geopark (Công viên địa chất Dã Liễu) thu hút du khách tới tham quan và giải trí bởi những phiến đá có hình thù độc đáo, kỳ lạ tạo nên bởi sự xâm thực của biển vào đất liền và được đặt tên bởi khách du lịch tới đây.
Trưa: ăn trưa đặc sản địa phương “MÌ BÒ” nhà hàng địa phương,
“Tham quan Tòa Tháp Tapei 101’’ – niềm kiêu hãnh của Châu Á, được xây dựng vào năm 1999 và hoàn thành vào năm 2004. Taipei 101 được vinh dự nhận giải thưởng Tòa nhà chọc trời Emporis vào năm 2004. (không bao gồm chi phí lên Tháp).
Tối : Quý khách Ăn tối tự túc tại “Chợ đêm Xi Men Ding ”, tự do thưởng thức các món đặc sản tại địa phương.,sau đó đoàn được hướng dẫn viên đưa đi khám phá chợ đêm “ Xi Men Ding”
Đoàn ăn tối và về khách sạn Đài Bắc nhận phòng nghỉ ngơi.
Tham quan Tòa Tháp Tapei 101

Ngày 5: ĐÀI BẮC ✈ TP HỒ CHÍ MINH
Sáng : đoàn ăn sáng tại khách sạn trả phòng , Đoàn khởi hành tham quan và tìm hiểu tại “Trung tâm trưng bày thần thú Tì Hưu’’. Tỳ Hưu là linh vật có hình dáng gần giống Kỳ Lân nhưng khác là có đôi cánh và thường được thờ phụng với ngụ ý nghĩa mang tới sự tài lộc bình an cho người sở hữu chúng.
“Nhà Tưởng niệm Tưởng Giới Thạch’’ – Nhà Tưởng Niệm Chung Tránh được xây dựng để tưởng nhớ ông Tưởng Giới Thạch, vị tổng thống đầu tiên của Trung Hoa Dân Quốc. Tòa nhà được xây dựng với mái ngói cong như cung điện Tử Cấm Thành ở Bắc Kinh, tường trắng gạch xanh cao 70m, bất kể du khách nhìn từ góc độ nào đều cảm nhận được sự hùng vĩ của ngôi nhà này.
Đoàn tiếp tục tham quan ngoại cảnh “Phủ Tổng Thống”.
Trưa: ăn trưa tại nhà hàng địa phương, Đoàn ghé tham quan Trung Tâm Miễn Thuế (DUTY FREE).
Đoàn di chuyển ra sân bay ĐÀI BẮC, đáp chuyến bay về TP.HCM',
    'Giá tour trẻ em
Trẻ nhỏ dưới 2 tuổi: 25% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 75% + thuế 4.500.000 VNĐ (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% giá tour người lớn (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, phần còn lại vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+ phí visa nếu có).
Hủy tour trước 14 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc).
Hủy tour trước 07 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+phí visa nếu có) (Tính theo ngày làm việc).
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.
Đối với những khách đã có visa hủy tour, Cty sẽ giữ hộ chiếu 1 tháng (thời hạn hiệu lực của visa) hoặc đóng dấu hủy visa.

Lưu ý
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Trẻ em dưới 18 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Hồ sơ visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại trong thời gian chờ cấp Visa.
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, công ty sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn. Công ty không giải quyết cho bất kỳ lý do thăm thân, kinh doanh,… để tách đoàn.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
Đối với từng trường hợp cụ thể, khách có thể được yêu cầu đặt cọc ký quỷ từ 10.000 USD/người trước chuyến đi (Sẽ được thông báo trước khi đăng ký tour) (sau khi quay về Việt Nam, khách sẽ nhận lại đầy đủ số tiền đặt cọc). Sau khi có kết quả visa, nếu khách không đồng ý điều kiện trên, khách sẽ bị hủy visa đồng thời chịu mức phạt theo quy định “Điều kiện hủy phạt”.
Do Visa du lịch này là loại đặc biệt nên khi đến Sân bay Đài Loan, Trưởng đoàn sẽ thu hộ chiếu của quý khách và giữ suốt quá trình tour để trình cục du lịch Đài Loan khi cần.
Trường hợp quý khách sử dụng visa tiên tiến trong hộ chiếu cũ, vui lòng mang theo hộ chiếu cũ lúc đi tour!
Trường hợp Quý khách bị từ chối không cấp visa:
Chi phí không hoàn lại là 3.600.000 VNĐ/khách, Áp dụng Quý khách book làm dạng visa dán, nộp hồ sơ trước 12 ngày cho đến ngày tour khởi hành.
Chi phí không hoàn lại là 4.200.000 VNĐ/khách, Áp dụng Quý khách book làm dạng visa dán, nộp hồ sơ sau 10 ngày cho đến ngày tour khởi hành.
Trong những trường hợp khách quan như: khủng bố, thiên tai, bão lớn… hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như: máy bay, tàu hỏa, xe… thì Công ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại hoặc chi phí bị phát sinh trong quá trình chuyến đi.
Kính chúc Quý khách một chuyến đi bổ ích và thú vị!',
    'https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan2.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan3.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-dai-loan4.jpg
https://fiditour.com/wp-content/uploads/2025/03/unnamed.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-dai-loan-cao-hung-dai-trung-dai-bac5n4d-khoi-hanh-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11785', 'Bangkok - Pattaya 5N4Đ',
    'TP.HCM', 'Thái Lan', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 36 DAY) + INTERVAL 7 HOUR,
    7190000, 5392000, 20, 16, 'https://fiditour.com/wp-content/uploads/2025/03/tour-thai.jpg',
    'Trưởng đoàn đón khách tại sân bay Tân Sơn Nhất để làm thủ tục checkin đáp chuyến bay đi Thái Lan (Bangkok), Đến vương quốc Thái Lan xe và HDV đón đoàn đưa khách về khách sạn nhận phòng và nghỉ ngơi và Ăn Tối.',
    'Ngày 1: TP.HCM ✈ BANGKOK
Trưởng đoàn đón khách tại sân bay Tân Sơn Nhất để làm thủ tục checkin đáp chuyến bay đi Thái Lan (Bangkok), Đến vương quốc Thái Lan xe và HDV đón đoàn đưa khách về khách sạn nhận phòng và nghỉ ngơi và Ăn Tối.

Ngày 2: BANGKOK – LIGHTING ART MUSEUM & BALLOON GARDEN- PATTAYA – WAT PHRA YAI
Đoàn dùng buffet sáng tại khách sạn, Làm thủ tục trả phòng, sau đó khởi hành Tham quan”𝐋𝐈𝐆𝐇𝐓𝐈𝐍𝐆 𝐀𝐑𝐓 𝐌𝐔𝐒𝐄𝐔𝐌 & 𝐁𝐀𝐋𝐋𝐎𝐎𝐍 𝐆𝐀𝐑𝐃𝐄𝐍” -Bảo tàng nghệ thuật ánh sáng, thay đổi sự cũ kỹ trong chương trình tham quan du lịch Thái Lan, đưa thế giới ánh sáng và công nghệ Digital hiện đại đến với du khách. Tái hiện khung cảnh nổi tiếng thế giới và Thái Lan bằng 1 cách mới: nghệ thuật ánh sáng hiện đại , Vườn khinh khí cầu đưa cả thế giới châu Âu, mọi ánh nhìn nghệ thuật, độc đáo đến với Thái Lan, để du khách có thể thả mình vào không gian hiện đại, lãng mạng, thơ mộng ,Lần đầu tiên và duy nhất có mặt tại Thái Lan!
Quý khách tiếp tục viếng “Wat phra yai” Chùa Phật lớn, nằm trên đỉnh của Đồi Pratumnak, giữa Pattaya và Bãi biển Jomtien, bạn không thể không nhận thấy một bức tượng Phật khổng lồ cao 18 mét hiện ra qua những tán cây, Tượng Phật Lớn này – lớn nhất trong vùng – là điểm nổi bật của Wat Phra Yai, một ngôi chùa được xây dựng vào những năm 1940 khi Pattaya chỉ là một làng chài, Tượng Phật Lớn cực kỳ nổi tiếng nó cũng được người dân địa phương đến cầu nguyện tại đây.
Buổi Tối, Quý khách tận hưởng 1 xuất “Massage Thái cổ truyền” giúp lưu thông khí huyết
Đoàn dùng bữa tối, Nhận phòng và nghỉ đêm tại Pattaya. Buổi tối Quý khách có thể tự do khám phá các Show biểu diễn nổi tiếng bên Thái hoặc Tham gia Câu Mực đêm trên tàu Công Chúa Đông Phương (chi phí tự túc).
“Wat phra yai” Chùa Phật lớn

Ngày 3: PATTAYA – ĐẢO CORAL – TRÂN BẢO PHẬT SƠN – NOONGNOCH – CÀ PHÊ VÀNG+BÁNH PHỦ VÀNG – ALCAZAR SHOW
Đoàn dùng bữa sáng tại khách sạn, sau đó khởi hành đi “Đảo San Hô” Đảo Coral bằng cano, Đến đảo đoàn tự do tắm biển hoặc tham gia các trò chơi tự túc trên biển như: Tự lái Canô, lặn biển, lướt ván, dù bay vv…
Đoàn dùng cơm trưa.
Tiếp tục tham quan “Trân Bảo Phật Sơn” hay còn gọi là Khao Chee Chan, nơi được tạo nên kỷ niệm 50 năm đăng cơ của nhà vua Thái Lan. Là một ngọn núi đẹp nổi tiếng nằm ở tỉnh Chon Buri, cách Pattaya – thiên đường biển đảo Thái Lan chỉ khoảng 15 km, Nổi bật giữa thiên nhiên hùng vĩ và vẻ đẹp hoang sơ của thiên nhiên là bức tượng nổi Thích Ca Mâu Ni Phật đang ngồi tọa thiền được tạc trên vách núi cao, Bức tượng cao đến hơn 100 mét, rộng khoảng 70 mét, được đúc nổi hoàn toàn bằng vàng ròng 24 cara, được tiến hành xây dựng vào năm 1996 nhân dịp Quốc vương Rama IX trị vì vương quốc Thái Lan được 50 năm.
Tham quan “Công viên khủng long Nongnooch” NongNooch Dinosaur Valley Pattaya. Tại đây Quý khách có dịp xem show biểu diễn của các chú Voi vui nhộn. (Trường hợp không trùng giờ show sẽ bù qua cho Quý khách ngồi xe điện dạo Công viên) Tham quan khuôn viên công viên khủng long, Xương rồng v.v…. cảnh đẹp như lạc vào thế giới rừng xanh .
Tham quan “Bảo Tàng Trầm Hương” nơi đây Quý khách có thể tìm hiểu thêm được nhiều kiến thức quý về Trầm. Quá trình hình thành Trầm Hương khá gian nan qua nhiều năm, trải qua nhiều điều kiện khí hậu khắc nghiệt, hội tụ đủ linh khí đất trời, nên người ta quan niệm rằng Trầm có thể giúp thanh tẩy những ô uế, tà khí, đem lại may mắn, bình an cho người đeo… Ngoài ra Trầm Hương còn sở hữu một mùi hương tinh tế, nhẹ nhàng giúp bạn giảm stress, đem lại giấc ngủ ngon… Trong đông y, Trầm Hương được xem là một vị thuốc, có tác dụng bổ thận khí, giảm đau đầu, cũng được cho là có lợi cho hệ hô hấp. Hương thơm từ trầm hương có thể giúp làm sạch đường hô hấp, giảm các triệu chứng của bệnh phổi như ho và khó thở.
Quý khách xem “Alcazar show’’ một trong những chương trình ca múa nhạc nổi tiếng và hoành tráng nhất do các vũ công chuyển đổi giới tính thực hiện với những màn biểu diễn múa dân tộc đến múa hiện đại vô cùng đặc sắc.
“Cà Phê Vàng+Bánh Phủ Vàng’’ lần đầu tiên xuất hiện tại Thái Lan đánh dấu một sự thay đổi trong Thái lan truyền thống với sự mới lạ , độc đáo hơn ,bao gồm 1 cà phê+ bánh ngọt phủ vàng +đồ mặc chụp ảnh
Quý khách dùng Bữa Tối. Nghỉ đêm tại Pattaya.
“Đảo San Hô” Đảo Coral

Ngày 4: PATTAYA – TRUNG TÂM NGHIÊN CỨU GIẤC NGỦ HOÀNG GIA – BAIYOKE – VIẾNG PHẬT 4 MẶT – FREE SHOPPING – BANGKOK
Đoàn dùng điểm tâm sáng tại khách sạn, Làm thủ tục trả phòng ,Quý khách tham quan và tìm hiểu cách phòng và hỗ trợ điều trị các bệnh liên quan đến cột sống, tăng cường thể lực, cải thiện tuổi thọ con người, nâng cao giá trị cuộc sống thiết yếu tại “Trung Tâm Nghiên Cứu Giấc Ngủ Hoàng Gia” – Morden Latex, là phân viện nghiên cứu các sản phẩm hỗ trợ giấc ngủ Modern Latex Hoàng Gia Thái Lan. Tiếp tục tham quan: “Trung tâm nghiên cứu rắn độc” & “Nơi trưng bày các loại đồ Da như da Cá Sấu, Cá Đuối’’…)sau đó khởi hành về Bangkok, Đoàn Ăn Trưa “Buffet tại tòa nhà 86 tầng BaiYoke Sky” Qúy khách chụp ảnh, ngắm nhìn toàn cảnh thủ đô Bangkok.
Quý khách viếng “Phật Bốn mặt” – Tứ Diện Thần ngay trung tâm Bangkok.Sau đó Quý khách tự do mua sắm tại siêu thị Big C hoặc tự do khám phá các khu mua sắm sầm uất khác ngay trung tâm Partunam như: MBK, Central World v.v…Tự túc khám phá các món địa phương tại Trung tâm Bangkok, Nghỉ đêm tại Bangkok.
MBK

Ngày 5: BANGKOK – DẠO THUYỀN SÔNG CHAOPHRAYA – CHÙA PHẬT VÀNG – CHÙA THUYỀN ✈ TP.HCM
Sau khi ăn sáng, Làm thủ tục trả phòng, khởi hành “Dạo thuyền trên dòng sông Chaophraya Huyền thoại”.
Quý khách viếng “Wat Traimit” Chùa Phật Vàng lớn nhất thế giới: cao 3 mét và nặng 5,5 tấn. Tượng được đúc theo phong cách Sukhothai tĩnh lặng và được khám phá một cách tình cờ vào thập niên 1950, Quý khách tiếp tục viếng “Chùa Thuyền” hay được gọi là Wat Yannawa, do vua Rama III xây dựng từ nhiều trăm năm trước, tọa lạc tại đường Charoen krung quận Sathon Bangkok. Ngôi chùa này có sự kết hợp hài hòa giữa kiến trúc hình dáng con thuyền của Trung Hoa với mái cao vút của lối kiến trúc Thái Lan, Xe đưa Quý Khách ra sân bay đáp chuyến bay về TP.HCM.',
    'Giá tour bao gồm
Vé máy bay khứ hồi theo SGN-BKK-SGN (bao gồm hành lý ký gửi và xách tay).
Thuế sân bay 2 nước, Phí an ninh du lịch & Phí phụ thu xăng dầu.
Khách sạn 3* và 4* tiêu chuẩn Thái(2 khách/ phòng, trường hợp đi lẻ nam nữ sẽ ngủ 3 khách/phòng).
Tham khảo: Bangkok: Bangkok Palace, ,The Palazzo , Praso @ Ratchada12 ,Madison bangkok hotel , Picnic Bangkok, SD Avenue, The Season Siam ,Gold Orchid ,Bizotel Bangkok, và tương đương
Pattaya: Crystal palace Pattaya, Memo Pattaya, Citrus Grande Pattaya Hotel, Chariot Pattaya Hotel, Marble Garden View Hotel ,The Grand Day Night , M Hotel, Aiyara Place Hotel, và tương đương.
Xe máy lạnh du lịch phục vụ suốt tuyến.
Nước suối phục vụ suốt tuyến.
Hướng dẫn địa phương nói tiếng việt phục vụ suốt tuyến.
Bữa ăn theo chương trình gồm: Buffet 86 tầng; Món ăn Thái vv…
Vé vào cổng các nơi tham quan theo chương trình.
Buffet nhà hàng xoay 86 tầng Baiyoke Sky.
Bảo hiểm du lịch Việt Nam với mức bồi thường tối đa 220.000.000VND tại Việt Nam.

Giá tour không bao gồm
Hộ chiếu (Phải còn thời hạn sử dụng trên 6 tháng, Tính từ ngày khởi hành đi và về).
Chi phí cá nhân.
Phụ thu phòng đơn(nếu có).
Phí bồi dưỡng cho hướng dẫn viên (650.000VND /Khách).
Visa tái nhập Việt Nam (890.000VND/khách) đối với ngoại kiều. (Giá có thay đổi theo quy định của cục xuất nhập cảnh)

Lưu ý
Tour thuần túy du lịch, suốt chương trình Quý khách vui lòng không rời đoàn.
Nếu khách là Việt Kiều hoặc nước ngoài phải có visa tái nhập nhiều lần hoặc miễn thị thực 5 năm và phải mang theo lúc đi tour.
Trẻ em dưới 18 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Công ty được phép thay đổi lịch trình chuyến đi, sử dụng các hãng hàng không thay thế nhưng vẫn đảm bảo tham quan đầy đủ các tuyến điểm theo chương trình.
Thứ tự điểm tham quan, lộ trình có thể thay đổi tùy theo tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan như lúc đầu.
Công Ty xin không chịu trách nhiệm nếu Quý khách bị từ chối xuất nhập cảnh.

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 20 ngày phí phạt = 50% tổng giá tour chương trình (Tính theo ngày làm việc).
Hủy tour trước 15 ngày phí phạt = 75% tổng giá tour chương trình (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (Tính theo ngày làm việc).
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bằng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Do tính chất là đoàn ghép khách lẻ, công ty sẽ thu nhận đủ số lượng khách tối thiểu 09 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp đoàn không đủ 09 khách, công ty có trách nhiệm thông báo cho Quý khách trước ngày khởi hành 04 ngày và sẽ thỏa thuận lại ngày khởi hành khác, hoặc hoàn trả toàn bộ số tiền mà Qúy khách đã thanh toán.
** Trong những trường hợp khách quan như: khủng bố, thiên tai… hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như: máy bay, tàu hỏa… thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh **.
Kính chúc Quý khách một chuyến đi bổ ích và thú vị!
Kính chúc Quý khách một chuyến đi bổ ích và thú vị!',
    'https://fiditour.com/wp-content/uploads/2025/03/uerwer.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-thai1.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-thai2.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-thai3.jpg
https://fiditour.com/wp-content/uploads/2025/03/tour-thai3ewqe.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-bangkok-pattalya-5n4d-khoi-hanh-tu-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11775', 'Malaysia - Singapore 5N4Đ',
    'TP.HCM', 'Singapore', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 39 DAY) + INTERVAL 7 HOUR,
    12290000, 9218000, 20, 17, 'https://fiditour.com/wp-content/uploads/2025/03/du-lich-singapore-malaysia-3eqwewqu1.jpg',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không, đáp chuyến bay đi sân bay quốc tế Kuala Lumpur. Quý khách ăn chiều trên máy bay. Nhập cảnh. Bắt đầu tham quan: Khu Putrajaya –…',
    'Ngày 1: TP.HCM ✈ KUALA LUMPUR – PUTRAJAYA
Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không, đáp chuyến bay đi sân bay quốc tế Kuala Lumpur. Quý khách ăn chiều trên máy bay. Nhập cảnh. Bắt đầu tham quan:
Khu Putrajaya – Trung Tâm Hành Chánh mới (NEW CITY) của MALAYSIA với những địa danh du lịch nổi tiếng như: Nhà thờ Hồi giáo Putra, Văn phòng Thủ tướng, Trung tâm hội nghị. Putrajaya còn được xem là Thành phố thông minh đẳng cấp thế giới và có môi trường làm việc vô cùng hiện đại: không ô nhiễm, không tệ nạn, không có lạc hậu và dân cư thì được tinh lọc.
Đoàn dùng cơm tối, TRẢI NGHIỆM “CUA SỐT ỚT”. Nhận phòng khách sạn nghỉ ngơi, hoặc tham gia TOUR ĐÊM 4 TRONG 1 “KUALA LUMPUR RỰC RỠ SẮC MÀU” (chi phí tự túc)
Trải nghiệm hệ thống tàu điện trên không LRT và tàu điện ngầm MRT độc đáo của người dân Malayisa.
Đài quan sát tháp truyền hình KLCC Tower – ngắm toàn cảnh thành phố Kuala Lumpur về đêm.
Chụp hình tháp đôi Twin Tower từ cây cầu Saloma rực rỡ ánh đèn.
Trải nghiệm Phố ẩm thực nổi tiếng đông đúc Jalan Alor, Bukit Bintang, Malaysia.
Nghỉ đêm tại Kuala Lumpur.

Ngày 2: KUALA LUMPUR – ĐỘNG BATU – GENTING – KUALA LUMPUR
Đoàn dùng bữa sáng tại khách sạn. Khởi hành tham quan:
Động Batu (Batu Cave) cao 272 bậc thang, đây là thánh địa của người Malaysia gốc Ấn độ. Thưởng thức trà sữa kéo Tea Tarik – đặc sản Malaysia
Cửa hàng miễn thuế (Duty free shop).
Cửa hàng đặc sản địa phương (Local products).
Trung tâm nệm cao su (Latex Shop)
Đoàn dùng bữa trưa với món LẨU UYÊN ƯƠNG / hoặc DIMSUM. Tham quan:
Cửa hàng Socola (Chocolate shop).
Chùa Thiên Hậu (Thien Hau Temple).
Cao nguyên Genting – Tự do tham quan và mua sắm, đây là trung tâm phức hợp lớn nhất của Malaysia cách thủ đô 51 km, ở độ cao 1.800m so với mặt nước biển. (Không bao gồm vé trò chơi). Đoàn di chuyển bằng cáp treo từng đạt kỷ lục dài nhất Đông Nam Á với 3,3 km – lý thú khi những chiếc cabin được lẩn khuất trong mây (tùy điều kiện thời tiết. Hoặc sẽ di chuyển bằng xe).
Trở về thủ đô Kuala Lumpur, dùng cơm tối tại nhà hàng. Nghỉ đêm tại khách sạn Kuala Lumpur.
Cao nguyên Genting

Ngày 3: KUALA LUMPUR – CITY TOUR MALACA – JOHOR BAHRU
Quý khách dùng bữa sáng tại Khách sạn. Trả phòng. Khởi hành đi tham quan thành phố:
Cung điện Hoàng gia (Royal Palace) (chụp hình bên ngoài)
Đài tượng niệm Quốc gia (National Monument).
Quảng trường Độc lập (Independence Square).
Chụp hình lưu niệm tại Tháp Đôi (Twin Towers).
Khởi hành đi Malacca, thành phố cổ, du lịch nổi tiếng của Malaysia, có lịch sử hơn 600 năm.
Trên đường đoàn ngắm nhìn những cánh rừng Cao Su, rừng Cọ, Ca Cao bạt ngàn. Hoặc cảnh sinh hoạt của người dân bản địa khi ngang qua những khu dân cư, khám phá những ngôi nhà sàn gỗ xinh xắn bên đường, nơi dành cho những người theo đạo Hồi nhỡ đường vào hành lễ.
Ăn trưa tại nhà hàng địa phương. Đến Malacca, đoàn bắt đầu tham quan:
Khu phố cổ Jonkers. Nhà thờ Thánh Saint Paul. Pháo đài A’Famosa…
Pháo đài cổ Bồ Đào Nha. Đền Cheng Hood. Quảng trường Hà Lan.
Tiếp tục di chuyển đến Johor Bahru. Đoàn dùng cơm tối tại nhà hàng địa phương.
Nhận phòng khách sạn tại Johor Bahru nghỉ ngơi.

Ngày 4: JOHOR BAHRU – SINGAPORE – SENTOSA – CITY TOUR
Ăn sáng tại khách sạn. Trả phòng. Đoàn di chuyển ra khu vực cửa khẩu. Làm thủ tục xuất cảnh Malaysia – Nhập cảnh Singapore.
Xe và Hướng dẫn viên đón đoàn đi tham quan:
Tòa nhà Quốc Hội (Parliament House).
Công viên sư tử biển (Merlion Park), biểu tượng của đất nước Singapore.
Nhà hát Victoria – nhà hát cổ kính nhất Singapore. Nơi đây là tâm điểm cho nghệ thuật biểu diễn của đảo quốc sư tử ngay từ thời thuộc địa.
Nhà hát Esplanade nổi tiếng với biểu tượng “Trái sầu riêng” – nhà hát hiện đại bậc nhất của Singapore. Đây cũng là trung tâm biểu diễn văn hóa nghệ thuật tầm cỡ Thế giới.
Dùng BỮA TRƯA BUFFET BBQ. Sau đó khởi hành đi đảo Sentosa, tham quan:
Chụp hình với biểu tượng công viên giải trí Universal Studios.
Resorts World – tham quan Casino hiện đại nhất Châu Á tại khách sạn 5 sao lớn nhất Singapore.
Công viên Hải dương (S.E.A. Aquarium) – một trong những hồ cá lớn nhất thế giới được UNESCO công nhận. Ở đây, Quý khách chiêm ngưỡng hơn 100,000 động vật biển thuộc hơn 800 loài khác nhau từ khắp nơi trên Thế giới. (Chi phí tự túc)
Đoàn dùng bữa tối. Nhận phòng nghỉ ngơi hoặc tham gia chương trình 3 trong 1 khám phá Singapore về đêm – SINGAPORE BY NIGHT (Chi phí tự túc).
Khám phá cuộc sống trong lòng đất người dân Singapore bằng hệ thống Tàu điện ngầm MRT.
Trải nghiệm Du thuyền trên dòng sông Singapore ngắm toàn cảnh Clarke Quay và vịnh Marina Bay.
Khám phá trung tâm thương mại Suntec City – tìm hiểu Phong Thuỷ Thượng – Phong Thuỷ Hạ.
Trải nghiệm Du thuyền trên dòng sông Singapore

Ngày 5: GARDEN BY THE BAY – JEWEL CHANGI – SINGAPORE ✈ TPHCM
Quý khách dùng buffet sáng tại Khách sạn. Trả phòng. Tham quan:
Kỳ quan Gardens by the Bay (Những khu vườn bên Vịnh) đây là khu vườn nhân tạo rộng hơn 100ha, có hơn 250.000 loài thực vật quý hiếm, với các Siêu cây khổng lồ lấy năng lượng mặt trời vào ban ngày và tỏa sáng vào ban đêm. Từ đây Quý khách có thể chụp hình toàn cảnh “Chiếc du thuyền” nằm ở độ cao 200m trên đỉnh của ba tòa nhà khách sạn Marina Bay Sands.
Cửa hàng vàng bạc đá quí và cửa hàng dầu gió, Collagen dưỡng da
Ăn trưa. Xe đưa Quý khách ra sân bay. Tham quan:
Jewel Changi – kết hợp giữa thiên nhiên với sức sáng tạo của con người. Chiêm ngưỡng Rain Vortex cao 40m, thác nước trong nhà cao nhất thế giới, khám phá thung lũng rừng Shiseido xanh tươi với các loài thực vật được chăm sóc tỉ mẩn.
Đến giờ hẹn, đoàn làm thủ tục về Việt Nam, đáp chuyến bay về đến Thành phố Hồ Chí Minh.
CHUYẾN BAY VN654 18:25 – 19:30
Ăn trưa nhà hàng. Ăn tối trên máy bay.
CHUYẾN BAY VN656 20:45 – 21:50
Ăn trưa nhà hàng. Ăn tối trên máy bay.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Giá tour bao gồm
Vé máy bay khứ hồi SGN – KUL / SIN – SGN (Bao gồm 23kg hành lý ký gửi + 10kg xách tay đối với hãng VIETNAM AIRLINES/ hoặc 20kg hành lý ký gởi + 07kg xách tay đối với VIETJET).
Phí an ninh sân bay, bảo hiểm hàng không thuế phi trường 2 nước.
Xe máy lạnh vận chuyển suốt tuyến.
Vé tham quan và các bữa ăn như chương trình.
Khách sạn 4* địa phương. Tiêu chuẩn 2khách/phòng. Trường hợp lẻ nam/ nữ ghép phòng 3.
Singapore: Royal at Queen / Park Avenue Rochester/ YWCA Fort Canning/… hoặc tương đương.
Malacca: Rivieran Suite / Swan Garden /… hoặc tương đương.
Kuala Lumpur: Days and Suites/ Chowkit an Ormod/ WP hotel… hoặc tương đương.
Phục vụ nước suối 1 Chai/khách/ngày.
Các bữa ăn theo chương trình.
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình.
Bảo hiểm du lịch.
Quà tặng: Nón.

Giá tour không bao gồm
Hộ chiếu thời hạn còn đủ 6 tháng tính từ ngày về.
Các các điểm than quan không có trong chương trình.
Phụ thu phòng đơn với khách có nhu cầu ngủ riêng 1 phòng: 4.000.000 vnđ/khách/tour
Tip HDV và tài xế 650.000 vnđ/khách/tour.
Visa tái nhập đối với khách mang quốc tịch nước ngoài.
Hành lý quá cước quy định, xe vận chuyển và HDV ngoài giờ v.v…

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 20 ngày phí phạt = 50% tổng giá tour chương trình (Tính theo ngày làm việc).
Hủy tour trước 15 ngày phí phạt = 75% tổng giá tour chương trình (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (Tính theo ngày làm việc).
Đối với tour Lễ/ Tết: Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 15 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 45 ngày phí phạt = 50% tổng giá tour chương trình. (Tính theo ngày làm việc)
Hủy tour trước 30 ngày phí phạt = 75% tổng giá tour chương trình. (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình. (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bằng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.

Lưu ý
– Trước khi đăng ký tour xin quý khách vui lòng đọc kỹ chương trình tour, giá tour, các khoản bao gồm và không bao gồm trong chương trình và đặt cọc 50% tổng số tiền tour ngay khi đăng kí tour.
– Giá tour không áp dụng vào các dịp Lễ, Tết của Việt Nam, Singapore & Malaysia.
– Giá thuế hàng không là giá tạm tính , giá có thể tăng hoặc giảm vào thời điểm quý khách đăng ký.
– Trong trường hợp quý khách không trực tiếp đến đăng ký vui lòng liên hệ tìm hiểu kỹ thông tin từ người đến đăng ký thế…
– Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp đoàn không đủ khách, công ty có trách nhiệm thông báo cho Quý khách trước ngày khởi hành 04 ngày và sẽ thỏa thuận lại ngày khởi hành khác, hoặc hoàn trả toàn bộ số tiền mà Quý khách đã thanh toán.
– Các chuyến bay phụ thuộc vào hãng hàng không nên một số trường hợp giờ bay sẽ thay đổi mà không được báo trước. Thứ tự các điểm tham quan trong chương trình có thể thay đổi tùy tình hình thực tế nhưng vẫn bảo đảm tham quan đầy đủ như trong chương trình. Tên khách sạn sẽ được xác nhận chính thức vào ngày họp đoàn, trước ngày khởi hành 01 ngày.
– Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận đầy đủ sức khỏe để đi du lịch nước ngoài của Bác sĩ và phải có người thân dưới 60 tuổi (đầy đủ sức khỏe) đi theo.
– Trẻ em dưới 16 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
– Quý khách có yêu cầu ở phòng đơn, vui lòng thanh toán thêm tiền phụ thu.
– Công ty du lịch không nhận khách có thai từ 30 tuần trở lên tham gia các tour du lịch nước ngoài.
– Quý khách có nhu cầu tách đoàn vui lòng thông báo cho nhân viên khi đăng kí, đóng phí 1.400.000/khách
– Trong trường hợp Quý khách không được xuất cảnh hoặc bị từ chối nhập cảnh tại nước sở tại thì trách nhiệm không thuộc về phía công ty du lịch.
– Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.',
    'https://fiditour.com/wp-content/uploads/2025/03/du-lich-singapore-malaysia-323eqweq423423.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-singapore-malaysia-323eqweq423423eqeqwe.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-malaysia-singapore-5n4d-khoi-hanh-tu-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11738', 'Singapore & Malaysia 3N2Đ',
    'TP.HCM', 'Singapore', '3N2Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 42 DAY) + INTERVAL 7 HOUR,
    8717500, 6538000, 35, 33, 'https://fiditour.com/wp-content/uploads/2025/03/du-lich-singapore-3.jpg',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không và đáp chuyến bay. Tới sân bay quốc tế Changi, làm thủ tục nhập cảnh. Sau đó bắt đầu hành trình tham quan: VJ813 SGN – SIN 07:00…',
    'Ngày 1: TPHCM – SINGAPORE – CITY TOUR
Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không và đáp chuyến bay. Tới sân bay quốc tế Changi, làm thủ tục nhập cảnh. Sau đó bắt đầu hành trình tham quan:
VJ813 SGN – SIN 07:00 – 10:05
Ăn sáng tại sân bay VN. Ăn trưa.
Tòa nhà Quốc Hội (Parliament House).
Công viên sư tử biển (Merlion Park), biểu tượng của đất nước Singapore.
Nhà hát Victoria – nhà hát cổ kính nhất Singapore.
Nhà hát Esplanade nổi tiếng với biểu tượng “trái sầu riêng” – nhà hát hiện đại bậc nhất của Singapore. Đây cũng là trung tâm biểu diễn văn hóa nghệ thuật tầm cỡ Thế giới
Đoàn dùng bữa tối. Nhận phòng nghỉ ngơi hoặc tham gia chương trình 3 trong 1 khám phá Singapore về đêm – SINGAPORE BY NIGHT (Chi phí tự túc)
Khám phá cuộc sống trong lòng đất của Singapore bằng hệ thống Tàu điện ngầm MRT.
Thưởng thức chương trình nhạc nước Spectra Show tại resort Marina Bay Sands.
Trải nghiệm Du thuyền trên dòng sông Singapore ngắm toàn cảnh Clarke Quay và vịnh Marina Bay.

Ngày 2: GARDEN BY THE BAY – CHÙA RĂNG PHẬT – SENTOSA
Đoàn dùng bữa sáng tại khách sạn. Sau đó xe đưa đoàn đi tham quan:
Kỳ quan Gardens by the Bay (Những khu vườn bên Vịnh) đây là khu vườn nhân tạo rộng hơn 100ha, có hơn 250.000 loài thực vật quý hiếm, với các Siêu cây khổng lồ lấy năng lượng mặt trời vào ban ngày và tỏa sáng vào ban đêm. Từ đây Quý khách có thể chụp hình toàn cảnh “Chiếc du thuyền” nằm ở độ cao 200m trên đỉnh của ba tòa nhà khách sạn Marina Bay Sands.
Bảo tàng & Chùa Răng Phật nằm trong khu Chinatown, xây dựng vào năm 2007, nhưng nội thất được thiết kế tỉ mỉ của ngôi chùa và những triển lãm toàn diện về nghệ thuật và lịch sử Phật giáo tại đây sẽ kể lại cho quý du khách những câu chuyện về văn hóa đã hơn hàng trăm năm tuổi. Ngôi chùa được đặt tên theo một bảo vật mà các Phật tử tin là răng nanh bên trái của Đức Phật, được lấy từ giàn thiêu trong đám tang của ngài ở Kushinagar, Ấn Độ. Xá lợi Răng Phật được đặt trong một tháp Phật khổng lồ nặng 3.500 kg và được làm từ 320 kg vàng…
Tiếp tục tham quan và mua sắm ở:
Cửa hàng kim cương, đá quý (Diamond Industry).
Cửa hàng dầu gió, Collagen dưỡng da, sản phẩm truyền thống, nổi tiếng độc đáo của Singapore
Faber Mount – ngắm nhìn toàn cảnh Singapore từ trên cao
Đoàn dùng BUFFET TRƯA BBQ. Sau đó khởi hành đi đảo Sentosa tham quan:
⬥ Chụp hình với biểu tượng công viên giải trí Universal Studios
⬥ Resorts World – tham quan Casino hiện đại nhất Châu Á tại khách sạn 5 sao lớn nhất Singapore.
⬥ Công viên Hải dương (S.E.A. Aquarium) – một trong những hồ cá lớn nhất thế giới được UNESCO công nhận. Ở đây, Quý khách chiêm ngưỡng hơn 100,000 động vật biển thuộc hơn 800 loài khác nhau từ khắp nơi trên Thế giới.(Chi phí tự túc)
⬥ Tự do mua sắm tại trung tâm thương mại Vivocity
Đoàn dùng bữa tối ĐẶC SẢN BAK KUH TEH. Trở về khách sạn nghỉ ngơi. Nghỉ đêm tại Singapore.
Bảo tàng & Chùa Răng Phật

Ngày 3: SINGAPORE – TPHCM
Đoàn dùng buffet sáng tại khách sạn. Trả phòng. Xe đưa đoàn ra sân bay Changi, tham quan:
✔ Jewel Changi – kết hợp giữa thiên nhiên với sức sáng tạo của con người. Chiêm ngưỡng Rain Vortex cao 40m, thác nước trong nhà cao nhất thế giới, khám phá thung lũng rừng Shiseido xanh tươi với các loài thực vật được chăm sóc tỉ mẩn.
✔ Đến giờ hẹn, Quý khách làm thủ tục về Việt Nam, chuyến bay về đến Thành phố Hồ Chí Minh.
VJ814 SIN – SGN lúc 16:55 – 18:05
Ăn trưa tại nhà hàng địa phương.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Chú ý : Thứ tự chương trình có thể thay đổi theo sự sắp xếp của CTY để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan đã nêu trong chương trình.',
    'Giá tour bao gồm
Vé máy bay khứ hồi SGN – SIN– SGN (Bao gồm 20kg hành lý ký gửi và 07kg xách tay).
Phí an ninh sân bay, bảo hiểm hàng không thuế phi trường 2 nước.
Xe máy lạnh vận chuyển suốt tuyến.
Vé tham quan và các bữa ăn như chương trình.
Khách sạn 4*: Royal at Queen/ Park Avenue Rochester/ Boss/ V Lanvender/ Seacare/ RE! …. hoặc tương đương. Tiêu chuẩn 2khách/phòng. Trường hợp lẻ nam/ nữ ghép phòng 3.
Phục vụ nước suối suốt hành trình tour.
Trưởng đoàn và HDV địa phương phụ vụ suốt tuyến theo chương trình.
Bảo hiểm du lịch.
Quà tặng: Nón, bao da hộ chiếu.

Giá tour không bao gồm
Hộ chiếu thời hạn còn đủ 6 tháng tính từ ngày về.
Các các điểm than quan không có trong chương trình.
Phụ thu phòng đơn với khách có nhu cầu ngủ riêng: 3.900.000 vnđ/khách/tour (ngày thường)
Phụ thu phòng đơn với khách có nhu cầu ngủ riêng: 4.200.000 vnđ/khách/tour (Lễ, Tết, Hè)
Tip HDV và tài xế 380.000 vnđ/khách/tour.
Visa tái nhập đối với khách mang quốc tịch nước ngoài.
Hành lý quá cước quy định, xe vận chuyển và HDV ngoài giờ v.v…

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 20 ngày phí phạt = 50% tổng giá tour chương trình (Tính theo ngày làm việc).
Hủy tour trước 15 ngày phí phạt = 75% tổng giá tour chương trình (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (Tính theo ngày làm việc).
Đối với tour Lễ/ Tết: Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 15 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 45 ngày phí phạt = 50% tổng giá tour chương trình. (Tính theo ngày làm việc)
Hủy tour trước 30 ngày phí phạt = 75% tổng giá tour chương trình. (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình. (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bằng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.

Lưu ý
– Trước khi đăng ký tour xin quý khách vui lòng đọc kỹ chương trình tour, giá tour, các khoản bao gồm và không bao gồm trong chương trình và đặt cọc 50% tổng số tiền tour ngay khi đăng kí tour.
– Giá tour không áp dụng vào các dịp Lễ, Tết của Việt Nam & Singapore.
– Giá thuế hàng không là giá tạm tính , giá có thể tăng hoặc giảm vào thời điểm quý khách đăng ký.
– Trong trường hợp quý khách không trực tiếp đến đăng ký vui lòng liên hệ tìm hiểu kỹ thông tin từ người đến đăng ký thế…
– Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp đoàn không đủ khách, công ty có trách nhiệm thông báo cho Quý khách trước ngày khởi hành 04 ngày và sẽ thỏa thuận lại ngày khởi hành khác, hoặc hoàn trả toàn bộ số tiền mà Qúy khách đã thanh toán.
– Các chuyến bay phụ thuộc vào hãng hàng không nên một số trường hợp giờ bay sẽ thay đổi mà không được báo trước. Thứ tự các điểm tham quan trong chương trình có thể thay đổi tùy tình hình thực tế nhưng vẫn bảo đảm tham quan đầy đủ như trong chương trình. Tên khách sạn sẽ được xác nhận chính thức vào ngày họp đoàn, trước ngày khởi hành 01 ngày.
– Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận đầy đủ sức khỏe để đi du lịch nước ngoài của Bác sĩ và phải có người thân dưới 60 tuổi (đầy đủ sức khỏe) đi theo.
– Trẻ em dưới 16 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
– Quý khách có yêu cầu ở phòng đơn, vui lòng thanh toán thêm tiền phụ thu.
– Theo quy định tiêu chuẩn khách sạn, 02 người lớn chỉ được kèm 01 trẻ em ngủ ghép. Trẻ em thứ 02, Quý khách vui lòng đóng theo giá người lớn để có chế độ giường riêng.
– Công ty du lịch không nhận khách có thai từ 30 tuần trở lên tham gia các tour du lịch nước ngoài.
– Quý khách có nhu cầu tách đoàn vui lòng thông báo cho nhân viên khi đăng kí, đóng phí 1.400.000/khách
– Trong trường hợp Quý khách không được xuất cảnh hoặc bị từ chối nhập cảnh tại nước sở tại thì trách nhiệm không thuộc về phía công ty du lịch.
– Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.',
    'https://fiditour.com/wp-content/uploads/2025/03/du-lich-singapore-3-312313.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/chuong-trinh-tour-singapore-malaysia3n2d-khoi-hanh-tu-tphcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11727', 'Khám Phá Xứ Sở Kim Chi - Hàn Quốc Busan - Daegu - Seoul 4N5Đ',
    'TP.HCM', 'Hàn Quốc', '4N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 45 DAY) + INTERVAL 7 HOUR,
    16990000, 12742000, 30, 30, 'https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-5n4d.jpg',
    'Đến Sân bay quốc tế Gimhae, hướng dẫn viên đón đoàn chào mừng đoàn đến với thành phố cảng Busan. Để nạp thêm năng lượng sau chuyến bay đêm, đoàn dùng bữa sáng (Canh thịt heo hầm). Chùa Haedong Yonggungsa – Là một trong những ngôi chùa cổ…',
    'Ngày 1: BUSAN – DEAGU
Đến Sân bay quốc tế Gimhae, hướng dẫn viên đón đoàn chào mừng đoàn đến với thành phố cảng Busan. Để nạp thêm năng lượng sau chuyến bay đêm, đoàn dùng bữa sáng (Canh thịt heo hầm).
Chùa Haedong Yonggungsa – Là một trong những ngôi chùa cổ và còn nổi tiếng vì đây là ngôi chùa duy nhất ở Hàn Quốc được xây dựng ngay sát bờ biển.
Làng bích họa Gamcheon – được những nghệ sĩ phục dựng bằng những sắc màu đầy tính nghệ thuật được mệnh danh là Santorini của xứ Kim Chi.
Đoàn ăn trưa tại nhà hàng địa phương, sau đó tiếp tục tham quan:
Trải nghiệm đi tàu lửa ven biển Haeundae – nơi khách du lịch có thể ngắm toàn cảnh bãi biển Haeundae từ trên cao siêu đẹp ở Busan.
Cầu treo Gwangan là cây cầu trên biển dài nhất tại Hàn Quốc
Đoàn dùng bữa tối, đoàn di chuyển tới thành phố Deagu. Quý khách về khách sạn nhận phòng nghỉ ngơi và tự do khám phá Deagu về đêm.
Chùa Haedong Yonggungsa

Ngày 2: DEAGU – SEOUL
Quý khách ăn sang tại khách sạn và bắt đầu tham quan:
Công viên E-World – là công viên giải trí lớn thứ hai ở Hàn Quốc, công viên nhiều trò chơi hấp dẫn như tàu lượn siêu tốc và vòng quay cũng như thưởng thức các chương trình biểu diễn và tham quan một số điểm quay của các bộ phim truyền hình nổi tiếng của Hàn Quốc.
Đoàn ăn trưa tại nhà hàng địa phương, Đoàn tiếp tục tham quan:
Làng văn hóa HyangChon – nơi tái hiện lại những kỹ niệm về Daegu những năm 1900 – 1950.
Đoàn di chuyển đến ga Daegu trải nghiệm tàu cao tốc KTX về thủ đô Seoul.
Đoàn dùng bữa tối tại Seoul . Kết thúc 1 ngày trải nghiệm thú vị, quý khách về khách sạn nhận phòng và tự do nghỉ ngơi.
Công viên E-World

Ngày 3: SEOUL – CẢNH PHÚC CUNG
Quý khách ăn sang tại khách sạn và bắt đầu tham quan:
Hàn Quốc là một trong những nước đứng đầu thế giới về làm đẹp và công nghệ làm đẹp, quý khách sẽ được tham quan và sử dụng thử miễn phí tất cả các loại mỹ phẩm nổi tiếng tại cửa hàng mỹ phẩm nội địa.
Tiếp tục hành trình Đoàn đến Trung tâm nhân sâm chính phủ – nơi được chính phủ Hàn Quốc bảo trợ và tập đoàn Samsung cam kết về chất lượng sản phẩm.
Đoàn ăn trưa tại nhà hàng địa phương , Đoàn tiếp tục tham quan:
Cung điện Kyeongbok (Cảnh Phúc Cung) cung điện hoàng gia nằm ở phía bắc của thủ đô Seoul, được xây dựng vào năm 1395 dưới triều vua Taejo thuộc triều đại Joseon.
Viện bảo tàng truyền thống dân gian Quốc Gia Hàn Quốc – Nơi lưu giữ và bảo tồn các di sản văn hóa của Hàn Quốc với trên 10.000 mẫu vật phản ánh các nghi lễ, tôn giáo, cách bài trí nhà cửa và các đồ vật trong gia đình Triều Tiên truyền thống.
Blue House (Phủ Tổng Thống Hàn Quốc hay còn gọi là Nhà Xanh) tọa lạc tại trung tâm thủ đô Seoul. Nhà Xanh được xây dựng trên một khuôn viên rộng lớn với kiến trúc truyền thống Hàn Quốc kết hợp yếu tố hiện đại. ( chụp hình bên ngoài)
Làng cổ Bukchon Hanok – là nơi tập trung hàng trăm ngôi nhà hanok truyền thống của Hàn Quốc, được xây dựng từ triều đại Joseon.
Sau khi ăn tối tại nhà hàng địa phương.
Trải nghiệm mua sắm tại chợ đêm Myeongdong và cửa hàng miễn thuế Lotte.
Quý khách mua sắm tại cửa hàng miễn thuế Lotte/Shilla/Huynhdai với các thương hiệu cao cấp trên thế giới.
Kết thúc chương trình, Quý khách về khách sạn nhận phòng và tự do nghỉ ngơi.
Làng cổ Bukchon Hanok

Ngày 4: SEOUL – TP. HCM
Quý khách ăn sang tại khách sạn và bắt đầu tham quan:
Đoàn tham quan tìm hiểu và mua sắm tại cửa hàng Tinh dầu Thông Đỏ, tìm hiểu bài thuốc do Thần y Herjun sáng chế – thần dược Detox máu, phòng chống bệnh tiểu đường, cao huyết áp, đột quỵ, mỡ trong máu.v.v…
Đoàn tham quan mua sắm đặc sản nông sản nổi tiếng của người dân Hàn Quốc: nấm Linh Chi Thượng Hoàng, Sâm tươi, An Cung Ngưu Hoàng Hoàng, các loại kẹo sâm làm quà…
Quý khách mua sắm tại cửa hàng miễn thuế Shilla với các thương hiệu cao cấp trên thế giới.
Đoàn dùng bữa trưa (cơm trộn) tại nhà hàng địa phương. Đoàn tiếp tục tham quan:
Tham gia lớp học làm Kim Chi và mặc trang phục Hanbok truyền thống Hàn Quốc.
Sau đó tự do mua sắm tại trung tâm bách hóa.
Đoàn dùng bữa tối (fastfood) tại nhà hàng địa phương.
Xe đón Quý khách ra sân bay Incheon làm thủ tục đáp chuyến bay về sân bay Tân Sơn Nhất.
Về đến sân bay Tân Sơn Nhất đoàn làm thủ tục nhập cảnh Việt Nam và nhận lại hành lý cá nhân. Trưởng đoàn chào tạm biệt Quý khách và hẹn gặp lại.
Lưu ý: **Thứ tự các điểm tham quan và lộ trình chuyến đi có thể thay đổi tùy theo tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan như lúc đầu.**',
    'Giá tour bao gồm
Vé máy bay khứ hồi theo đoàn của hàng không VIETJET AIR (SGN-PUS-ICN-SGN) 20kg hành lý ký gửi + 7kg xách tay.
Bảo hiểm du lịch Quốc tế suốt tuyến.
Phí an ninh sân bay,bảo hiểm hàng không thuế phi trường 2 nước (có thể thay đổi lúc xuất vé).
Khách sạn tiêu chuẩn “3* Quốc Tế – 4*Hàn Quốc”: (2 người/phòng – phòng 3 người trường hợp đi lẻ nam hoặc nữ).
Deagu 3*: QueenVell, Grand …
Seoul 4*: Golden seoul, Sono Calm, Standford ,Orakai Hotel …
Các bữa ăn như chương trình.
Visa nhập cảnh Hàn Quốc 1 lần.
Vé tham quan như chương trình.
Xe máy lạnh vận chuyển suốt tuyến.
Phục vụ 1 chai nước suối/khách/ngày.
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình.

Giá tour không bao gồm
Chi phí cá nhân, hành lý quá cước, điện thoại, giặt ủi, tham quan ngoài chương trình.
Phụ thu phòng đơn (nếu có) (7.800.000 vnđ/tour).
Visa tái nhập Việt Nam cho khách quốc tịch nước ngoài (nếu có): (840.000 vnđ/khách).
Tips cho tài xế địa phương và hướng dẫn viên mức đề nghị: (910.000 vnđ/khách/tour).

Quy định trẻ em
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 75% giá tour người lớn + thuế (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% giá tour người lớn + thuế (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Đối tượng khách có thể tư vấn đi tour hàn quốc :
Khách đã đi các nước Đông Nam Á (Singapore, Malaysia, Thái Lan …) hoặc Trung Quốc hoặc Úc, Mỹ, các nước Châu Âu.
Khách có khả năng chứng minh tài chính tốt: công việc tốt, có tài sản (nhà đất, xe hơi, …)
Khách đi chung với gia đình.

Đối tượng khách có hồ sơ không mạnh
Khách trẻ đi du lịch một mình.
Khách có công việc không ổn định, mức lương không tốt.
Khách có tài chính yếu: sổ tiết kiệm 120.000.000 VND mới mở, không có nhà đất, xe hơi, …
Khách chưa đi du lịch lần nào hoặc chỉ đi 1 hoặc 2 lần ở các nước Đông Nam Á.
Khách ở một số vùng miền nhạy cảm mà Lãnh Sự Quán có thể từ chối: Hải Phòng, Nghệ An, Hà Tĩnh, miền Tây.

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt 50% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt 75% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Sau thời gian trên phí phạt 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.
Đối với những khách đã có visa, Công ty du lịch sẽ giữ hộ chiếu 3 tháng (thời hạn hiệu lực của visa) hoặc đóng dấu hủy visa.
Trường hợp Quý khách bị từ chối không cấp visa từ Lãnh Sự Quán:
Chi phí không hoàn lại là 1.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ trước 21 ngày tour khởi hành (chưa xuất vé máy bay)
Chi phí không hoàn lại là 3.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ sau 21 ngày cho đến ngày tour khởi hành. (Do các khoản đã chi trả như: Hoàn vé máy bay; dịch thuật; thư bảo lãnh; lệ phí visa…)

Lưu ý
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, Công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn..
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
Quý khách mang 2 Quốc tịch hoặc Travel document (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Đối với từng trường hợp cụ thể, khách có thể được yêu cầu đặt cọc từ 125.000.000 – 250.000.000 VNĐ/người trước chuyến đi (sau khi quay về Việt Nam, khách sẽ nhận lại đầy đủ số tiền đặt cọc). Sau khi có kết quả visa, nếu khách không đồng ý điều kiện trên, khách sẽ bị hủy visa đồng thời chịu mức phạt theo quy định “Điều kiện hủy phạt”.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn.
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Hồ sơ visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Ngày khởi hành có thể dời lại ít nhất 1 tuần do phụ thuộc vào kết quả visa của Lãnh Sự Quán.
Công ty du lịch sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Hàn Quốc.
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-5n4d3ewqe.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-5n4d-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-5n4d-2.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/kham-pha-xu-so-kim-chi-han-quoc-busan-daegu-seoul4n5d-khoi-hanh-tu-tp-hcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11710', 'Khám Phá Xứ Sở Kim Chi - Hàn Quốc Seoul - Nami - Everland 5N5Đ',
    'TP.HCM', 'Hàn Quốc', '5N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 48 DAY) + INTERVAL 7 HOUR,
    16990000, 12742000, 20, 19, 'https://fiditour.com/wp-content/uploads/2025/03/tour-du-lich-han-quoc-5n5d.jpg',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không cho quý khách đáp chuyến bay đi Hàn Quốc.',
    'Ngày 1: TP.HCM ✈ SEOUL (Nghỉ đêm trên máy bay)
Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục hàng không cho quý khách đáp chuyến bay đi Hàn Quốc.

Ngày 2: SEOUL – ĐẢO NAMI – THÁP N SEOUL
Đến sân bay Quốc Tế Incheon, hướng dẫn viên đón đoàn chào mừng đoàn đến với Thủ đô Seoul. Để nạp thêm năng lượng sau chuyến bay đêm, đoàn dùng bữa sáng (Mỳ Udon) tại nhà hàng địa phương.
Tiếp đến, Quý khách khởi hành đi tham quan:
Đảo Nami – Nổi tiếng với những bản màu sắc riêng theo từng mùa: Mùa thu rực rỡ ánh vàng đỏ của tán cây phong và rừng ngân hạnh; Mùa hè có cây cối mướt xanh; Mùa đông huyền ảo với tuyết phủ trắng xóa& cuối cùng đặc biệt là vào Mùa xuân hàng trăm cây hoa anh đào nhuộm sắc hồng rực rỡ, với mùi hương ngọt ngào phảng phất không khí và lànơi ra đời của nhiều bộ phim truyền hình nổi tiếng của Hàn Quốc đã làm dấy lên cơn sốt nghệ thuật thứ bảy tại các nước CHÂU Á và thế giới như: “Bản Tình Ca Mùa Đông“.
Đoàn ăn trưa với món (Gà Nướng), Đoàn tiếp tục tham quan:
Điểm tham quan chạy chương trình mùa đông ( từ giữa tháng 12 đến hêt tháng 2):
❄ Khu trượt tuyết ELYSIAN GANGCHON – hệ thống khu giải trí phức hợp nằm trong khung cảnh hoành tráng của vùng núi TỈNH GANGWONDO. Quý khách có thể tận hưởng cảm giác thú vị trước thiên nhiên bao phủ tuyết trắng, lưu lại các bức ảnh kỷ niệm mùa tuyết rơi và trải nghiệm môn thể thao trượt tuyết trên đường trượt có độ cao hơn 50m. Theo sự hướng dẫn của Hướng dẫn viên, Quý khách sẽ làm quen với các bài học trượt tuyết bằng máng trượt hoặc có thể sử dụng gậy trượt. (chi phí thuê quần áo, dụng cụ trượt tuyết tự túc, khoảng 1.500.000 vnđ).
Tháp N Seoul – tọa lạc trên núi Namsan mang đến cho du khách những góc nhìn toàn cảnh của thành phố, và đã trở thành một biểu tượng của Seoul. (Phí thang máy lên tháp tự túc).
Đoàn dùng bữa tối (Lẩu nấm) . Kết thúc 1 ngày trải nghiệm thú vị, quý khách về khách sạn nhận phòng và tự do nghỉ ngơi.
Đảo Nami

Ngày 3: CITY TOUR SEOUL – CUNG ĐIỆN – LÀNG HANOK
Quý khách khởi hành đi ăn sáng và bắt đầu tham quan:
Hàn Quốc là một trong những nước đứng đầu thế giới về làm đẹp và công nghệ làm đẹp, quý khách sẽ được tham quan và sử dụng thử miễn phí tất cả các loại mỹ phẩm nổi tiếng tại cửa hàng mỹ phẩm nội địa.
Tiếp tục hành trình Đoàn đến Trung tâm nhân sâm chính phủ – nơi được chính phủ Hàn Quốc bảo trợ và tập đoàn Samsung cam kết về chất lượng sản phẩm.
Đoàn ăn trưa với món (Gà Hầm Sâm), Đoàn tiếp tục tham quan:
Cung điện Kyeongbok (Cảnh Phúc Cung) cung điện hoàng gia nằm ở phía bắc của thủ đô Seoul, được xây dựng vào năm 1395 dưới triều vua Taejo thuộc triều đại Joseon.
Viện bảo tàng truyền thống dân gian Quốc Gia Hàn Quốc – Nơi lưu giữ và bảo tồn các di sản văn hóa của Hàn Quốc với trên 10.000 mẫu vật phản ánh các nghi lễ, tôn giáo, cách bài trí nhà cửa và các đồ vật trong gia đình Triều Tiên truyền thống.
Blue House (Phủ Tổng Thống Hàn Quốc hay còn gọi là Nhà Xanh) tọa lạc tại trung tâm thủ đô Seoul. Nhà Xanh được xây dựng trên một khuôn viên rộng lớn với kiến trúc truyền thống Hàn Quốc kết hợp yếu tố hiện đại.
Quảng trường Gwanghwamun – chính quyền Seoul quy hoạch nơi này thành điểm nhấn chính cho thành phố, giống như đại lộ Champ-Élysées ở Paris hay quảng trường Thiên An Môn ở Bắc Kinh. Quảng trường Gwanghwamun – tọa lạc trên mảnh đất rộng 340m, dài 557m với các công trình đa dạng như đài phun nước, thảm hoa, cây xanh … Đây là một trong những niềm tự hào của người dân Seoul.
Suối Cheonggyecheon – con suối trong mát dài 5.8 km giữa lòng thủ đô Seoul.
Làng Hanok – là một làng nghề truyền thống đã được bảo tồn nguyên vẹn trong đô thị 600 tuổi, bao gồm rất nhiều con hẻm, các ngôi nhà hanok, những mái chùa cổ.
Quý khách mua sắm tại cửa hàng miễn thuế Lotte/Shilla/Huynhdai với các thương hiệu cao cấp trên thế giới.
Tặng vé show nghệ thuật DRAWING SHOW: biểu diễn vẽ nghệ thuật vui nhộn và hài hước từ các chàng trai tài hoa theo phong cách Hàn Quốc.
Sau đó Quý khách tự do khám phá và mua sắm tại chợ Dongdeamun sầm uất nhất Seoul. Sau đó Đoàn dùng bữa tối và về khách sạn nghỉ ngơi.
Quảng trường Gwanghwamun

Ngày 4: SEOUL – CÔNG VIÊN GIẢI TRÍ
Quý khách khởi hành đi ăn sáng và bắt đầu tham quan:
Tiếp tục Đoàn tham quan tìm hiểu và mua sắm tại cửa hàng Tinh dầu Thông Đỏ, tìm hiểu bài thuốc do Thần y Herjun sáng chế- thần dược Detox máu, phòng chống bệnh tiểu đường, cao huyết áp, đột quỵ, mỡ trong máu.v.v…
Đoàn tham quan mua sắm đặc sản nông sản nổi tiếng của người dân Hàn Quốc: nấm Linh Chi Thượng Hoàng, Sâm tươi, An Cung Ngưu Hoàng Hoàng, các loại kẹo sâm làm quà…
Tham gia lớp học làm Kimbab và mặc trang phục Hanbok truyền thống Hàn Quốc.
Đoàn ăn trưa với món (cơm truyền thống), Đoàn tiếp tục tham quan:
Điểm tham quan theo mùa ( từ tháng 12 đến hêt tháng 02)
Tham quan Lotte World – khu phức hợp vui chơi giải trí lớn tại thủ đô Seoul, bao gồm một công viên giải trí trong nhà lớn nhất thế giới và lập kỷ lục Guiness. Khu vui chơi ngoài trời gọi là Magic Island, hòn đảo nhân tạo bên trong một hồ nước được kết nối Monorail, phức hợp mua sắm, rạp chiếu phim, khách sạn sang trọng, bảo tàng dân gian Hàn Quốc… Lotte World phục vụ hơn 8.000.000 du khách mỗi năm và được xem là một trong những công viên giải trí đẳng cấp thế giới ở Châu Á…
Điểm tham quan theo mùa ( từ tháng 03 đến hêt tháng 11)
Tham quan Công viên giải trí phức hợp Everland – nổi tiếng với nhiều trò chơi & các màn trình diễn hấp dẫn. Một trong mười công viên lớn nhất thế giới với nhiều trò chơi cảm giác mạnh, khu vườn thú hoang dã Safari, khu gấu trúc…, Quý khách sẽ thả mình vui chơi trong những vườn hoa sặc sỡ, cùng tham gia diễu hành với đoàn vũ công của công viên.
🌸(Điểm tham quan sẽ mở cửa từ ngày cuối tháng 3 – đầu tháng 4 hàng năm)
Đoàn đến công viên Yeoui-Do – Nằm trên trục sông Hàn là một trong những địa điểm ngắm hoa nổi tiếng nhất ở Hàn Quốc. Với hơn 1.600 cây anh đào nên mỗi năm vào dịp lễ hội khu vực này lúc nào cũng đông đúc dân địa phương và khách du lịch tham gia. Đến đây ngoài thưởng hoa, du khách còn có thể thưởng thức các món ăn đường phố tuyệt ngon hay tham gia những màn biểu diễn đường phố độc đáo.
Sau khi ăn tối (thịt nướng)tại nhà hàng địa phương, Quý khách về khách sạn và tự do nghỉ ngơi.
Tham quan Công viên giải trí phức hợp Everland

Ngày 5: SEOUL ✈ HỒ CHÍ MINH
Quý khách trả phòng khởi hành đến nhà hàng dùng bữa sáng.
Sau đó tự do mua sắm tại trung tâm bách hóa và đóng kiện hành lý.
Đoàn dùng bữa trưa (cơm trộn) tại nhà hàng địa phương.
Xe đón Quý khách ra sân bay Inchoen làm thủ tục đáp chuyến bay về sân bay Tân Sơn Nhất.
Về đến sân bay Tân Sơn Nhất đoàn làm thủ tục nhập cảnh Việt Nam và nhận lại hành lý cá nhân. Trưởng đoàn chào tạm biệt Quý khách và hẹn gặp lại.
sân bay Inchoen
Lưu ý: **Thứ tự các điểm tham quan và lộ trình chuyến đi có thể thay đổi tùy theo tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan như lúc đầu.**',
    'Giá tour bao gồm
Vé máy bay khứ hồi theo đoàn của hàng không VIETNAM AIRLINE (SGN-ICN-SGN) 23kg hành lý ký gửi + 10kg xách tay.
Bảo hiểm du lịch Quốc tế suốt tuyến.
Phí an ninh sân bay,bảo hiểm hàng không thuế phi trường 2 nước (có thể thay đổi lúc xuất vé).
Khách sạn tiêu chuẩn “3* Quốc Tế – 4*Hàn Quốc”: (2 người/phòng – phòng 3 người trường hợp đi lẻ nam hoặc nữ).
Seoul 4*: Golden seoul, Sono Calm, Standford ,Orakai Hotel …
Các bữa ăn như chương trình.
Visa nhập cảnh Hàn Quốc 1 lần.
Vé tham quan như chương trình.
Xe máy lạnh vận chuyển suốt tuyến.
Phục vụ 1 chai nước suối/khách/ngày.
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình.

Giá tour không bao gồm
Chi phí cá nhân, hành lý quá cước, điện thoại, giặt ủi, tham quan ngoài chương trình.
Phụ thu phòng đơn (nếu có) (7.500.000 vnđ/tour).
Visa tái nhập Việt Nam cho khách quốc tịch nước ngoài (nếu có): (840.000 vnđ/khách).
Tips cho tài xế địa phương và hướng dẫn viên mức đề nghị: (910.000 vnđ/khách/tour)

Quy định trẻ em
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 75% giá tour người lớn + thuế (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% giá tour người lớn + thuế (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Đối tượng khách có thể tư vấn đi tour hàn quốc :
Khách đã đi các nước Đông Nam Á (Singapore, Malaysia, Thái Lan …) hoặc Trung Quốc hoặc Úc, Mỹ, các nước Châu Âu.
Khách có khả năng chứng minh tài chính tốt: công việc tốt, có tài sản (nhà đất, xe hơi, …)
Khách đi chung với gia đình.

Đối tượng khách có hồ sơ không mạnh
Khách trẻ đi du lịch một mình.
Khách có công việc không ổn định, mức lương không tốt.
Khách có tài chính yếu: sổ tiết kiệm 110.000.000 VND mới mở, không có nhà đất, xe hơi, …
Khách chưa đi du lịch lần nào hoặc chỉ đi 1 hoặc 2 lần ở các nước Đông Nam Á.
Khách ở một số vùng miền nhạy cảm mà Lãnh Sự Quán có thể từ chối: Hải Phòng, Nghệ An, Hà Tĩnh, miền Tây.

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt 50% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt 75% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Sau thời gian trên phí phạt 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.
Đối với những khách đã có visa, Công ty du lịch sẽ giữ hộ chiếu 3 tháng (thời hạn hiệu lực của visa) hoặc đóng dấu hủy visa.
Trường hợp Quý khách bị từ chối không cấp visa từ Lãnh Sự Quán:
Chi phí không hoàn lại là 1.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ trước 21 ngày tour khởi hành (chưa xuất vé máy bay)
Chi phí không hoàn lại là 3.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ sau 21 ngày cho đến ngày tour khởi hành. (Do các khoản đã chi trả như: Hoàn vé máy bay; dịch thuật; thư bảo lãnh; lệ phí visa…)

Lưu ý
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, Công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn..
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
Quý khách mang 2 Quốc tịch hoặc Travel document (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Đối với từng trường hợp cụ thể, khách có thể được yêu cầu đặt cọc từ 125.000.000 – 250.000.000 VNĐ/người trước chuyến đi (sau khi quay về Việt Nam, khách sẽ nhận lại đầy đủ số tiền đặt cọc). Sau khi có kết quả visa, nếu khách không đồng ý điều kiện trên, khách sẽ bị hủy visa đồng thời chịu mức phạt theo quy định “Điều kiện hủy phạt”.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn.
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Hồ sơ visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Ngày khởi hành có thể dời lại ít nhất 1 tuần do phụ thuộc vào kết quả visa của Lãnh Sự Quán.
Công ty du lịch sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Hàn Quốc.
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-6432424-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/quang-truong-gwanghwamun-2.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-64234324-1.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-63123213123-2.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/kham-pha-xu-so-kim-chi-han-quoc-seoul-nami-everland5n5d-khoi-hanh-tu-tp-hcm/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-11689', 'Khám Phá Xứ Sở Kim Chi - Hàn Quốc Busan - Daegu - Seoul 6N5Đ',
    'TP.HCM', 'Hàn Quốc', '6N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 51 DAY) + INTERVAL 7 HOUR,
    19990000, 14992000, 40, 33, 'https://fiditour.com/wp-content/uploads/2025/03/tour-du-lich-han-quoc-5n5d32131.jpg',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng đoàn làm thủ tục hàng không cho quý khách đáp chuyến bay đi Hàn Quốc.',
    'Ngày 1: TP.HCM ✈ BUSAN (Nghỉ đêm trên máy bay)
Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng đoàn làm thủ tục hàng không cho quý khách đáp chuyến bay đi Hàn Quốc.

Ngày 2: BUSAN  GAYA THEME PARK
Đến Sân bay quốc tế Gimhae, hướng dẫn viên đón đoàn chào mừng đoàn đến với thành phố cảng Busan. Để nạp thêm năng lượng sau chuyến bay đêm, đoàn dùng bữa sáng với thức ăn nhanh (Fast food). Đoàn khởi hành tham quan 1 trong 2 điểm:
Chùa Haedong Yonggungsa – Là một trong những ngôi chùa cổ và còn nổi tiếng vì đây là ngôi chùa duy nhất ở Hàn Quốc được xây dựng ngay sát bờ biển. (Điểm tham quan theo mùa từ Tháng 05-Tháng 08).
Đường hầm rượu vang- con đường dài gần 1 km, trong đó còn có các bức trang 3D, tiểu cảnh kết hợp ánh sáng để khách chụp ảnh, tại đây du khách còn có thể trải nghiệm Đạp xe trên đường ray xe lửa thưởng ngoạn dòng sông Nakdong chảy qua thành phố Gimhae. (Điểm tham quan theo mùa từ Tháng 09 -Tháng 04).
Đoàn ăn trưa với món (Thịt heo hầm kiểu Hàn) tại nhà hàng địa phương, Đoàn tiếp tục tham quan:
Công viên chủ đề Gaya Theme Park – nơi mọi người có thể thưởng thức những nét văn hóa và cuộc sống của Vương quốc Kaya xưa. Bên cạnh đó, du khách có thể xem một vở kịch lịch sử ở đó cùng với nhiều hoạt động mạo hiểm.
Tặng vé show nghệ thuật HERO PAINTER SHOW: biểu diễn vẽ nghệ thuật vui nhộn và hài hước từ các chàng trai tài hoa theo phong cách Hàn Quốc.
Trải nghiệm đi tàu điện ven biển Haeundae – nơi khách du lịch có thể ngắm toàn cảnh bãi biển Haeundae từ trên cao siêu đẹp ở Busan.
Đoàn dùng bữa tối (Thịt xào). Kết thúc 1 ngày trải nghiệm thú vị, quý khách về khách sạn nhận phòng nghỉ ngơi và tự do khám phá chợ đêm Busan về đêm.
Chùa Haedong Yonggungsa

Ngày 3: BUSAN – DAEGU
Quý khách ăn sang tại khách sạn và bắt đầu tham quan:
Làng bích hoạ Gamcheon – được những nghệ sĩ phục dựng bằng những sắc màu đầy tính nghệ thuật được mệnh danh là Santorini của xứ Kim Chi.
Đoàn di chuyển đến thành phố Deagu xinh đẹp.
Làng văn hóa HyangChon – nơi tái hiện lại những kỹ niệm về Daegu những năm 1900 – 1950.
🌸 Công viên Songhae – công viên ven sông ngắm hoa anh đào đẹp nhất tại Daegu.
Đoàn ăn trưa với món Canh Sườn, Đoàn tiếp tục tham quan:
Tham quan trường đại học Keimyung– ngôi trường được mệnh danh là đẹp nhất nhì xứ sở Kim Chi, được biết đến là địa điểm quay phim của những bộ phim đình đám của Hàn Quốc (Vườn sao băng).
Đoàn dùng bữa tối (Gà hầm sâm). Kết thúc 1 ngày trải nghiệm thú vị, quý khách về khách sạn nhận phòng và tự do nghỉ ngơi.
Làng văn hóa HyangChon

Ngày 4: DAEGU – SEOUL – CẢNH PHÚC CUNG
Quý khách ăn sang tại khách sạn và di chuyển đến ga Daegu trải nghiệm tàu cao tốc KTX về thủ đô Seoul. Sau khi đến Seoul đoàn tiếp tục tham quan:
Cung điện Kyeongbok (Cảnh Phúc Cung) cung điện hoàng gia nằm ở phía bắc của thủ đô Seoul, được xây dựng vào năm 1395 dưới triều vua Taejo thuộc triều đại Joseon.
Viện bảo tàng truyền thống dân gian Quốc Gia Hàn Quốc – Nơi lưu giữ và bảo tồn các di sản văn hóa của Hàn Quốc với trên 10.000 mẫu vật phản ánh các nghi lễ, tôn giáo, cách bài trí nhà cửa và các đồ vật trong gia đình Triều Tiên truyền thống.
Blue House (Phủ Tổng Thống Hàn Quốc hay còn gọi là Nhà Xanh) tọa lạc tại trung tâm thủ đô Seoul. Nhà Xanh được xây dựng trên một khuôn viên rộng lớn với kiến trúc truyền thống Hàn Quốc kết hợp yếu tố hiện đại.
Đoàn ăn trưa với món Cá nướng, Đoàn tiếp tục tham quan:
Hàn Quốc là một trong những nước đứng đầu thế giới về làm đẹp và công nghệ làm đẹp, quý khách sẽ được tham quan và sử dụng thử miễn phí tất cả các loại mỹ phẩm nổi tiếng tại cửa hàng mỹ phẩm nội địa.
Tiếp tục hành trình Đoàn đến Trung tâm nhân sâm chính phủ – nơi được chính phủ Hàn Quốc bảo trợ và tập đoàn Samsung cam kết về chất lượng sản phẩm.
Sau khi ăn tối ( lẩu nấm) tại nhà hàng địa phương.
Quý khách mua sắm tại cửa hàng miễn thuế Lotte/Shilla/Huynhdai với các thương hiệu cao cấp trên thế giới.
Kết thúc chương trình, Quý khách về khách sạn nhận phòng và tự do nghỉ ngơi.
Cung điện Kyeongbok

Ngày 5: SEOUL – ĐẢO NAMI
Quý khách ăn sang tại khách sạn và bắt đầu tham quan:
Đoàn tham quan tìm hiểu và mua sắm tại cửa hàng Tinh dầu Thông Đỏ, tìm hiểu bài thuốc do Thần y Herjun sáng chế – thần dược Detox máu, phòng chống bệnh tiểu đường, cao huyết áp, đột quỵ, mỡ trong máu.v.v…
Đoàn tham quan mua sắm đặc sản nông sản nổi tiếng của người dân Hàn Quốc: nấm Linh Chi Thượng Hoàng, Sâm tươi, An Cung Ngưu Hoàng Hoàng, các loại kẹo sâm làm quà…
Tham gia lớp học làm Kim Chi và mặc trang phục Hanbok truyền thống Hàn Quốc.
Đoàn dùng bữa trưa (cơm trộn) tại nhà hàng địa phương. Đoàn tiếp tục tham quan:
Đảo Nami – Nổi tiếng với những bản màu sắc riêng theo từng mùa: Mùa thu rực rỡ ánh vàng đỏ của tán cây phong và rừng ngân hạnh; Mùa hè có cây cối mướt xanh; Mùa đông huyền ảo với tuyết phủ trắng xóa& cuối cùng đặc biệt là vào Mùa xuân hàng trăm cây hoa anh đào nhuộm sắc hồng rực rỡ, với mùi hương ngọt ngào phảng phất không khí và là nơi ra đời của nhiều bộ phim truyền hình nổi tiếng của Hàn Quốc đã làm dấy lên cơn sốt nghệ thuật thứ bảy tại các nước CHÂU Á và thế giới như: “Bản Tình Ca Mùa Đông“.
Sau khi ăn tối (Gà Nướng) tại nhà hàng địa phương, Quý khách về khách sạn và tự do nghỉ ngơi.
Đảo Nami

Ngày 6: SEOUL ✈ HỒ CHÍ MINH
Quý khách trả phòng khởi hành đến nhà hàng dùng bữa sáng.
Sau đó tự do mua sắm tại trung tâm bách hóa và đóng kiện hành lý.
Đoàn dùng bữa trưa (cơm trộn) tại nhà hàng địa phương.
Xe đón Quý khách ra sân bay Inchoen làm thủ tục đáp chuyến bay về sân bay Tân Sơn Nhất.
Về đến sân bay Tân Sơn Nhất đoàn làm thủ tục nhập cảnh Việt Nam và nhận lại hành lý cá nhân. Trưởng đoàn chào tạm biệt Quý khách và hẹn gặp lại.
Lưu ý: **Thứ tự các điểm tham quan và lộ trình chuyến đi có thể thay đổi tùy theo tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan như lúc đầu.**',
    'Giá tour bao gồm
Vé máy bay khứ hồi theo đoàn của hàng không VIETNAM AIRLINE (SGN-PUS-ICN-SGN) 23kg hành lý ký gửi + 10kg xách tay.
Bảo hiểm du lịch Quốc tế suốt tuyến.
Phí an ninh sân bay,bảo hiểm hàng không thuế phi trường 2 nước (có thể thay đổi lúc xuất vé).
Khách sạn tiêu chuẩn “3* Quốc Tế – 4*Hàn Quốc”: (2 người/phòng – phòng 3 người trường hợp đi lẻ nam hoặc nữ).
Busan 3*: Layers , TT Gopo …
Deagu 3*: QueenVell, Grand …
Seoul 4*: Golden seoul, Sono Calm, Standford ,Orakai Hotel …
Các bữa ăn như chương trình.
Visa nhập cảnh Hàn Quốc 1 lần.
Vé tham quan như chương trình.
Xe máy lạnh vận chuyển suốt tuyến.
Phục vụ 1 chai nước suối/khách/ngày.
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình.

Giá tour không bao gồm
Chi phí cá nhân, hành lý quá cước, điện thoại, giặt ủi, tham quan ngoài chương trình.
Phụ thu phòng đơn (nếu có) (10.000.000 vnđ/tour).
Visa tái nhập Việt Nam cho khách quốc tịch nước ngoài (nếu có): (840.000 vnđ/khách).
Tips cho tài xế địa phương và hướng dẫn viên mức đề nghị: (1.090.000 vnđ/khách/tour).

Quy định trẻ em
Trẻ nhỏ dưới 2 tuổi: 30% giá tour người lớn (sử dụng giường chung với người lớn).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 75% giá tour người lớn + thuế (Không có chế độ giường riêng).
Trẻ em từ 2 tuổi đến dưới 11 tuổi: 100% giá tour người lớn + thuế (Có chế độ giường riêng).
Trẻ em đủ 11 tuổi trở lên: 100% giá tour người lớn.

Đối tượng khách có thể tư vấn đi tour hàn quốc :
Khách đã đi các nước Đông Nam Á (Singapore, Malaysia, Thái Lan …) hoặc Trung Quốc hoặc Úc, Mỹ, các nước Châu Âu.
Khách có khả năng chứng minh tài chính tốt: công việc tốt, có tài sản (nhà đất, xe hơi, …)
Khách đi chung với gia đình.

Đối tượng khách có hồ sơ không mạnh
Khách trẻ đi du lịch một mình.
Khách có công việc không ổn định, mức lương không tốt.
Khách có tài chính yếu: sổ tiết kiệm 120.000.000 VND mới mở, không có nhà đất, xe hơi, …
Khách chưa đi du lịch lần nào hoặc chỉ đi 1 hoặc 2 lần ở các nước Đông Nam Á.
Khách ở một số vùng miền nhạy cảm mà Lãnh Sự Quán có thể từ chối: Hải Phòng, Nghệ An, Hà Tĩnh, miền Tây.

Điều kiện hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt 50% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt 75% tổng giá tour chương trình (+phí visa nếu có). (Tính theo ngày làm việc)
Sau thời gian trên phí phạt 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.
Đối với những khách đã có visa, Công ty du lịch sẽ giữ hộ chiếu 3 tháng (thời hạn hiệu lực của visa) hoặc đóng dấu hủy visa.
Trường hợp Quý khách bị từ chối không cấp visa từ Lãnh Sự Quán:
Chi phí không hoàn lại là 1.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ trước 21 ngày tour khởi hành (chưa xuất vé máy bay)
Chi phí không hoàn lại là 3.500.000 VNĐ/khách, Áp dụng Quý khách book tour và nộp hồ sơ sau 21 ngày cho đến ngày tour khởi hành. (Do các khoản đã chi trả như: Hoàn vé máy bay; dịch thuật; thư bảo lãnh; lệ phí visa…)

Lưu ý
Do tính chất là đoàn ghép khách lẻ, công ty du lịch sẽ có trách nhiệm nhận khách đăng ký cho đủ đoàn (15 khách người lớn trở lên) thì đoàn sẽ khởi hành đúng lịch trình. Nếu số lượng đoàn dưới 15 khách, công ty có trách nhiệm thông báo cho khách trước ngày khởi hành 7 ngày và sẽ thỏa thuận lại ngày khởi hành mới.
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, Công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn..
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
Quý khách mang 2 Quốc tịch hoặc Travel document (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Đối với từng trường hợp cụ thể, khách có thể được yêu cầu đặt cọc từ 125.000.000 – 250.000.000 VNĐ/người trước chuyến đi (sau khi quay về Việt Nam, khách sẽ nhận lại đầy đủ số tiền đặt cọc). Sau khi có kết quả visa, nếu khách không đồng ý điều kiện trên, khách sẽ bị hủy visa đồng thời chịu mức phạt theo quy định “Điều kiện hủy phạt”.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn.
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Hồ sơ visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Ngày khởi hành có thể dời lại ít nhất 1 tuần do phụ thuộc vào kết quả visa của Lãnh Sự Quán.
Công ty du lịch sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Hàn Quốc.
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-6du.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-6323213.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-64234324.jpg
https://fiditour.com/wp-content/uploads/2025/03/du-lich-han-quoc-busan-daegu-seoul-5n-63123213123-1.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/kham-pha-xu-so-kim-chi-han-quoc-busan-daegu-seoul6-ngay-5-dem/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-10714', 'Sydney - Melbourne 7N6Đ',
    'TP.HCM', 'Úc', '7N6Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 54 DAY) + INTERVAL 7 HOUR,
    44990000, 33742000, 40, 36, 'https://fiditour.com/wp-content/uploads/2024/08/uc.jpeg',
    '16:00: Quý khách tập trung tại sân bay Tân Sơn Nhất, trưởng đoàn của công ty đón Quý khách tại cổng D2, ga đi Quốc tế làm thủ tục đáp chuyến bay đi Melbourne. Quý khách nghỉ đêm trên máy bay. Chuyến bay dự kiến: VJ085 SGNSYD 19:05 07:00+1',
    'Ngày 1: TP.HCM – SYDNEY
16:00: Quý khách tập trung tại sân bay Tân Sơn Nhất, trưởng đoàn của công ty đón Quý khách tại cổng D2, ga đi Quốc tế làm thủ tục đáp chuyến bay đi Melbourne. Quý khách nghỉ đêm trên máy bay. Chuyến bay dự kiến: VJ085 SGNSYD 19:05 07:00+1

Ngày 2: CITY SYDNEY
7:00 Đoàn tới Syd, xe và HDV đón khách, đưa đi tham quan:
Phố cổ The Rocks – nơi những người da trắng đầu tiên định cư ở Úc.
Vườn Bách Thảo (Botanic Garden) – vườn thực vật được mở cửa từ năm 1816 với diện tích 30 hectares.
Nhà hát Con Sò (Sydney Opera House) có kiến trúc cực kỳ ấn tượng và nổi tiếng của Sydney với ba mặt hướng ra biển.
Darling Habour- một cảng biển nhộn nhịp nơi có nhiều quán cà phê lãng mạn ngoài trời nổi tiếng ở Sydney.
Chợ cá Fish Market
Dùng bữa trưa và tối tại nhà hàng địa phương
Về khách sạn, nghỉ ngơi. Tự do khám phá Sydney về đêm.

Ngày 3: SYDNEY – BLUE
Sáng: Sau khi dùng điểm tâm sáng, Đoàn tham quan:
Khu bảo tồn thiên nhiên Blue Mountain – di sản thế giới, nơi còn lưu giữ nguyên vẹn những nét hoang sơ từ thời thổ dân sinh sống.
Tự do chụp hình núi Ba chị em (Three sisters), nếu may mắn du khách có thể chụp được những bức hình cùng với người thổ dân với ống khèn và những giai điệu truyền thống.
Trải nghiệm tàu kéo Sennic World.
Tối: đoàn về khách sạn ăn tối và nghỉ ngơi.

Ngày 4: SYDNEY – MELBOURNE
Dùng bữa sáng tại khách sạn, làm thủ tục trả phòng, ra sân bay làm thủ tục đáp chuyến bay đi Mel. Chuyến bay dự kiến: SYDMEL 0930 1100
Đến Syd, đoàn dùng bữa trưa, sau đó tham quan:
China Town (khu phố China) – khu phố người Hoa nhộn nhịp
Phố Swanston
Nhà Thờ Thánh Patrick – ngôi nhà thờ cổ được xây dựng vào thế kỷ 19 với kiến trúc Gothic đặc trưng.
Treasure House
Vườn thực vật Fitzroy – là khu vườn lịch sử đẹp nhất của thành phố Melbourne. Khu vườn có lịch sử được xây dựng như một khu bảo tồn vào năm 1848, thiết kế của khu vườn theo kiểu thời kì Victoria cổ điển. Vào mùa xuân, khu vườn trở nên rực rỡ với sự khoe sắc của nhiều loài hoa khác nhau.
Dùng cơm tối tại nhà hàng địa phương. Về khách sạn nhận phòng, nghỉ ngơi.

Ngày 5: PUFFING BILLY / NÚI TUYẾT MOUNT BULLER
Sáng: Quý khách dùng điểm tâm tại khách sạn. Khởi hành tham quan:
Xe lửa hơi nước: Puffing Billy – Hành trình trên tàu Puffing Billy sẽ đưa bạn đi qua dãy Dandenong xanh mướt đẹp huyền diệu của nước Úc trên một đường tàu hơi nước được bảo tồn cực kỳ tốt. Là cơ hội tuyệt vời cho bạn một chuyến đi thư giãn và hít thở bầu không khí trong lành khi tàu chạy qua khu rừng nhiệt đới ôn hòa.
Công viên Dangdenong – thuộc bang Victoria cách thành phố Melbourne khoảng 38km. Với tổng diện tích lên đến 1.900 ha, đây là khu lưu trú và phát triển của rất nhiều loài động thực vật. Nơi sinh sống lý tưởng của nhiều loài chim quý hiếm, cùng rất nhiều chủng loại lan tuyệt đẹp …và cả một hệ sinh thái gần giống với khu rừng cận nhiệt đới.
Trưa: Đoàn dùng cơm trưa và tiếp tục tham quan Công viên Maru Koala
Maru Koala Park – Đến với công viên du khách có cơ hội đươc trò chuyện thân thiết với những chú gấu koala và cả gia đình nhà chúng, thậm chí còn được tận tay cho chúng ăn. Bên cạnh đó còn có chuột túi kăng-ga-ru, chuột túi wallaby hay những loài thú bạch tạng quý hiếm. Ngoài ra, tại đây còn có loài gấu túi hay quỷ Tasmanian bản địa chỉ có tại Úc.
Từ tháng 06 – 08, mùa đông sẽ áp dụng điểm tham quan Núi tuyết (Không đi Puffing Billy, Dandenong, Công viên Maru Koala).
Núi tuyết Mount Buller – vì tháng 6 – 8 về, trong khi cái nóng oi bức của những ngày hè đang thôi thúc những người yêu xê dịch tìm về với biển thì ở phía bên kia Nam Bán Cầu, nước Úc đang vào mùa đông với tuyết rơi trắng xóa. Một trong những nơi mà bạn có thể ngắm tuyết đẹp nhất và trải nghiệm trò chơi trượt tuyết thú vị nhất chính là ở Melbourne – Núi tuyết Buller.
Nơi đây có 3 đường trượt từ dễ đến khó, thách thức tài năng của bạn. Vừa trượt tuyết, vừa được ngắm nhìn khung cảnh tuyết phủ trắng xóa đẹp ngỡ ngàng thì thật là một trải nghiệm không thể nào quên.
Bên cạnh đó, Quý khách còn được tự do mua sắm và thưởng thức một bữa ăn với Fish and Chips, đặc sản nổi tiếng của người dân Úc.
Về lại trung tâm, dùng bữa tối. Về khách sạn nghỉ ngơi.

Ngày 6: + 7
BALLARAT – HÁI TRÁI CÂY (Ăn sáng, trưa, tối)
Sáng: Sau khi dùng bữa sáng, đoàn khởi hành đến Thị trấn Ballarat:
Thị trấn Ballarrat là nơi phong trào đào vàng của Victoria khởi phát. Nơi này có lịch sử từ năm 1838, khi một người nhập cư đến cắm đất tại bờ biển Black Swamps, và từ đó hình thành một thị trấn nhỏ. Đến năm 1851, tiếng gọi của vàng đã phá tan bầu không khí yên tĩnh của thị trấn này, và chỉ trong vòng vài tháng nhiều ngàn người đã đổ xô đến đây để tìm vàng. Sự bùng nổ dân số đã giúp cho vùng này công bố là một thị trấn vào năm 1852. Ngày nay, Ballarat lại trở về với không khí yên tĩnh thuở nào.
Quý khách tự do mua sắm tại khu DFO – Tất cả các cửa hàng bán trực tiếp, những mặt hàng ở đây không qua đại lý hay phân phối nên giá rất rẻ. Trung tâm không chỉ đáp ứng nhu cầu của những người yêu thích thời trang mà con là nơi cung cấp những vật phẩm trang trí nhà cửa hay nguyên liệu để làm nên bữa ăn ngon,…
Dùng bữa tối tại nhà hàng địa phương. Sau đó, di chuyển ra sân bay, làm thủ tục đáp chuyến bay về Việt Nam. Chuyến bay: MELSGN VJ082 01:30 07:30
07:30: về đến Tp.HCM, kết thúc chương trình. Chia tay và hẹn gặp lại Quý khách.
Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Giá tour bao gồm
Vé máy bay quốc tế khứ hồi của hãng hàng không ( 7kg xách tay, 25kg ký gửi )
Vé nội địa từ Syd qua Mel
Thuế hàng không gồm: thuế phi trường 2 nước, phí an ninh, phụ thu phí…
Khách sạn tiêu chuẩn quốc tế 3 sao, 2 khách/phòng, trường hợp nam/nữ lẻ ngủ phòng ba.
Ăn uống theo chương trình.
Vận chuyển bằng xe du lịch tiêu chuẩn Quốc tế.
Phí tham quan thắng cảnh, vào cửa một lần.
Bảo hiểm du lịch toàn cầu, suốt tuyến
Trưởng đoàn đi từ Việt Nam suốt tuyến
Quà tặng lưu niệm

Giá tour không bao gồm
Chi phí phòng đơn, điện thoại, giặt là, đi lại ngoài giờ…
Hành lý quá cước
Phí visa Úc 4.000.000vnđ/khách
Các chi phí phát sinh không đề cập trong chương trình.
Tiền Tip cho HDV và lái xe ở nước ngoài 49USD/tour/người.
Chi phí đi lại để lấy dấu vân tay (khi nộp hồ sơ visa) tại HN hoặc HCM
Xe phục vụ trung bình 10 giờ/1 ngày đảm bảo theo lịch trình thăm quan, nếu phát sinh thêm giờ, quý khách vui lòng trả trực tiếp 100Aud/1 giờ
Phụ thu phòng đơn: 10.000.000vnđ/khách/tour.

Quy trình đăng ký và thực hiện:
Quý khách vui lòng đem theo Passport (bản chính), và đóng cọc 25.000.000 VND/ Khách khi đăng
ký tour.
Đóng phần tour còn lại trước khởi hành ít nhất 10 ngày làm việc (Không tính ngày lễ, tết và Thứ 7, chủ nhật).
Cung cấp hồ sơ xin visa trước ngày khởi hành ít nhất 50 ngày.
Công ty sẽ hướng dẫn thủ tục xin visa, cách điền các mẫu đơn visa, đăng ký ngày nộp hồ sơ, khách hàng phải có mặt để nộp hồ sơ và mang theo hồ sơ bản gốc để đối chiếu.

Điều kiện hủy tour
Vì đây là chương trình du lịch trong “Trạng thái bình thường mới” nên không được phép hủy/chuyển hoặc dời ngày tour. Quý khách chịu phạt Toàn bộ số tiền tour đã đóng nếu hủy/chuyển hoặc dời ngày tour.
Đối với những trường hơp khách đi cùng nhóm (từ 2 khách trở lên), khách nào đậu/có sẵn Visa nhưng không tham gia chuyến đi với bất kì lí do gì, sẽ bị phạt phí là 25,000,000 VND/ Khách.
Trong trường hợp không thể tham dự được tour, quý khách vui lòng mang Biên bản đăng ký tour & biên lai đóng tiền đến văn phòng Cty Công ty để làm thủ tục hủy/chuyển tour. Phải thông báo cho Công ty bằng văn bản hoặc email (không giải quyết các trường hợp liên hệ chuyển/hủy tour qua điện thoại).
**Lưu ý: Bên cạnh việc khách hàng hủy tour sẽ dựa vào các điều kiện hủy phạt như trên. Đồng thời, đối với những khách đã có visa xin visa theo đoàn của Công ty, chúng tôi sẽ giữ hộ chiếu cho đến khi thời hạn visa kết thúc, hết hiệu lực được phép nhập cảnh, đồng thời công ty sẽ thông báo với LSQ/ĐSQ (nơi cấp visa) để đóng dấu mộc “Cancel – hủy” visa của khách. Vì chúng tôi chịu trách
nhiệm trong việc nhập cảnh và xuất cảnh của quý khách.

Lưu ý
Quý khách từ 18 tuổi trở lên: Thẻ xanh covid (khách đã tiêm vaccines ngừa covid đủ liều, thời gian hoàn tất mũi 2 trước 14 ngày và không quá 06 tháng), khách là F0 đã khỏi bệnh (có giấy chứng nhận của Sở Y Tế và không quá 06 tháng), có thể thay đổi tùy tình hình điểm xuất phát và điểm đến.
Quý khách cần có Giấy xét nghiệm âm tính Covid-19 bằng phương pháp RT-PCR/RT-LAM trong vòng 72h từ lúc lấy mẫu/hoặc phân tích mẫu đến thời điểm nhập cảnh nước sở tại (có thể thay đổi tùy tình hình thực tế).
Cập nhật và khai báo sức khỏe trước khi tour khởi hành. Thường xuyên rửa tay bằng xà phòng, dung dịch sát khuẩn. Nếu có biểu hiện sốt, ho, đau họng, khó thở báo ngay cho trưởng đoàn để kịp hỗ trợ xử lý.
Quý khách vui lòng xem kỹ chương trình, giá tour, phần bao gồm và không bao gồm được liệt kê chi tiết trong chương trình.
Đối với những trường hợp hồ sơ không được nộp tại trung tâm tiếp nhận hồ sơ Tp. Hồ Chí Minh, Quý khách vui lòng chịu toàn bộ chi phí đi lại sau khi công ty chúng tôi hoàn tất hồ sơ và lấy lại lịch hẹn để nộp hồ sơ tại Hà Nội/ Đà Nẵng.
Trường hợp Quý khách không đồng ý, vui lòng chịu phí phạt 25,000,000 VND/ khách.
Trường hợp đoàn không đủ 15 khách khởi hành (15 khách đi và về theo hành trình tour), Công ty có quyền thay đổi, dời tour sang ngày khởi hành gần nhất. Nếu khách hàng không sắp xếp được công việc để tham gia tour kế tiếp, chúng tôi sẽ hoàn trả lại tiền cọc tour/tiền tour sau khi đã trừ đi lệ phí xin visa của các khách mà không chịu thêm bất kỳ chi phí và trách nhiệm nào (Đồng thời Visa sẽ được thông báo hủy trên LSQ/ ĐSQ)).
Do tính chất visa Úc, thời hạn xét hồ sơ có thể kéo dài lâu hơn ngày khởi hành đã đăng ký. Vì vậy, trong những trường hợp bất khả kháng, công ty sẽ hỗ trợ khách hàng đổi ngày khởi hành sau đó. Nếu khách hàng không sắp xếp được thời gian tham gia các đoàn sau thì sẽ bị mất phí visa cùng các dịch vụ khác với số tiền 12.500.000 VND.
Đối với những khách hàng chỉ mua Land tour (tức dịch vụ mặt đất tại nước muốn đến), Công ty sẽ không khuyến khích khách hàng tự mua/xuất vé máy bay khi chưa có sự xác nhận tour chắc chắn khởi hành từ Công ty. Chúng tôi không chịu trách nhiệm về chi phí chuyến đi: khách sạn mua thêm, vé máy bay, visa… của khách hàng nếu tour không khởi hành.
Quý khách mang quốc tịch nước ngoài hoặc là Việt kiều phải có visa rời mang theo lúc đi tour.
Quý khách mang quốc tịch nước ngoài có visa tái nhập Việt Nam 01 lần, phải làm visa tái nhập VN
để nhập cảnh vào VN lần tiếp theo.
Quý khách mang 2 Quốc tịch hoặc Travel document (chưa nhập quốc tịch) vui lòng thông báo với nhân viên bán tour ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan (nếu có).
Quý khách chỉ mang thẻ xanh (thẻ tạm trú tại nước ngoài) và không còn hộ chiếu VN còn hiệu lực thì không du lịch sang nước thứ ba được.
Trường hợp trẻ em đi với người nhà (không phải Bố Mẹ) phải nộp kèm giấy ủy quyến được chính quyền địa phương xác nhận (do Bố Mẹ ủy quyền dắt đi tour).
Đối với khách hàng từ 70 tuổi – đến 79 tuổi: yêu cầu ký cam kết sức khỏe với Công ty & giấy khám sức khỏe để đi du lịch nước ngoài do bác sĩ cấp. Công ty khuyến khích đóng thêm phí bảo hiểm cao cấp tùy theo tour. Bất cứ sự cố nào xảy ra trên tour, Công ty sẽ không chịu trách nhiệm.
Không nhận khách hàng từ 80 tuổi trở lên & khách hàng mang thai từ tháng thứ 5 trở lên. Khách hàng mang thai vui lòng thông báo ngay khi đăng ký tour để được tư vấn.
Tùy theo hồ sơ sẽ yêu cầu ký quỹ cho Công ty từ 300.000.000 VND/khách trở lên. Khi đi tour về, Công ty sẽ hoàn trả lại cho khách…
Sau khi Cty thông báo ký quỹ mà quý khách không ký quỹ (dù đã đậu visa) đồng nghĩa khách chưa hoàn tất thủ tục thanh toán và được coi là tự hủy tour. Quý khách sẽ không được tham gia chuyến đi và công ty sẽ áp dụng mức phạt theo quy định mục hủy vé.
Đối với Bảo hiểm du lịch quốc tế: sẽ được áp dụng theo Quy tắc bảo hiểm công ty đã mua cho khách hàng. Công ty sẽ có nhiệm vụ cung cấp hồ sơ bảo hiểm đã mua để khách có thể làm việc trực tiếp với bảo hiểm và công ty hoàn toàn không chịu trách nhiệm với những phát sinh liên quan đến
bảo hiểm của quý khách. Đồng thời, công ty sẽ được miễn trừ trách nhiệm đối với những vấn đề liên quan đến sức khỏe của khách trong suốt quá trình tham quan, lưu trú.
Công ty có quyền thay đổi hãng hàng không vào giờ chót tùy thuộc vào các hãng hàng không, thời tiết…
Giờ bay có thể thay đổi mà không thông báo trước do phụ thuộc vào hãng hàng không.
Tùy theo đièu kie ̣n thực tế mà chương trình tham quan có thể thay đổi hành trình lên xuống cho phù hợp và các tuyến điểm du lịch vãn đảm bảo đày đủ như lúc ban đầu. Tuy nhiên, Công ty sẽ được miễn trừ trách nhiệm bảo đảm các điểm tham quan trong trường hợp khách quan như:
Xảy ra thiên tai: bão lụt, hạn hán, động đất…
Sự cố về an ninh: biểu tình, khủng bố, đình công…
Sự cố về hàng không: dời, hủy, hoãn chuyến bay, trục trặc kỹ thuật bay, an ninh bay…
Dịch bệnh…
Nếu những trường hợp trên xảy ra, Công ty sẽ xem xét để hoàn chi phí không tham quan cho khách trong điều kiện có thể (sau khi đã trừ lại các dịch vụ đã thực hiện: phí làm visa, tiền vé máy bay….và không chịu trách nhiệm bồi thường thêm bất kỳ chi phí nào khác).
Trường hợp Quý khách không được xuất cảnh và nhập cảnh tại nước sở tại, Công ty được miễn trừ trách nhiệm và không hoàn trả tiền tour. Quý khách tự túc chi phí mua vé máy bay quay về Việt Nam.
Tùy theo tình hình cấp Visa của Lãnh Sự Quán và vé máy bay, ngày khởi hành có thể dời lại từ 1 đến 7 ngày so với ngày khởi hành ban đầu hoặc vào đoàn khởi hành tiếp theo gần nhất. Và Trong trường hợp này, Công ty sẽ không hoàn lại phí visa nếu Quý khách hủy tour, và Visa của Quý khách
sẽ được giữ lại cho đến khi có thông báo hủy từ phía Lãnh Sự Quán.
Hồ sơ xin visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Đối với những trường hợp bị mất cắp trong quá trình tham quan, lưu trú (hành lý, tài sản, tiền bạc, hộ chiếu…) tại nước sở tại, Công ty sẽ hỗ trợ về mặt giấy tờ liên quan, và không có trách nhiệm bồi thường/ hoàn lại những chi phí phát sinh do việc mất cắp xảy ra.
Sau khi Visa được cấp, Công ty sẽ giữ lại Visa cho đến ngày khởi hành. Trường hợp Quý khách muốn lấy lại passport để đi du lịch hay công tác, Quý khách vui lòng nộp những giấy tờ liên quan đến chuyến đi và được yêu cầu kí quỹ (300.000.000 VND) để đảm bảo cho việc Visa được sử dụng đúng mục đích ban đầu.',
    NULL,
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/hanh-trinh-kham-pha-sydney-melbourne-7n6d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-10581', 'Nhật Bản - Hokkaido - Noboribetsu - Otaru - Sapporo - Tokyo Cung Đường Hokkaido Cao Cấp 6N5Đ',
    'TP.HCM', 'Nhật Bản', '6N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 57 DAY) + INTERVAL 7 HOUR,
    45890000, 34418000, 25, 19, 'https://fiditour.com/wp-content/uploads/2024/08/hokaido.jpeg',
    '✓ Sáng : Đoàn đáp xuống sân bay Quốc tế Haneda – Tokyo, sau đó đoàn làm thủ tục nối chuyến đến Chitose trên chuyến bay JL507 HND – CTS 08:55-10:30. Di chuyển đến Noboribetsu ăn trưa, sau đó tham quan: • Làng văn hóa cổ Noboribetsu Date…',
    'Ngày 1: HANEDA ✈ CHITOSE ✈ NOBORIBETSU ( Ăn trưa, tối )
✓ Sáng : Đoàn đáp xuống sân bay Quốc tế Haneda – Tokyo, sau đó đoàn làm thủ tục nối chuyến
đến Chitose trên chuyến bay JL507 HND – CTS 08:55-10:30. Di chuyển đến Noboribetsu ăn trưa, sau
đó tham quan:
• Làng văn hóa cổ Noboribetsu Date Jidaimura: nơi tái hiện một cách tỉ mỉ không gian lịch sử,
văn hóa thời kỳ Edo (1603-1868). Ngôi làng có nhiều điểm tham quan khác nhau, bao gồm dinh
thự samurai, nhà ninja, cửa hàng truyền thống.
• Tặng mỗi khách vé xem show biểu diễn Ninja truyền thống – đưa quý khách về không gian lịch
sử, khám phá và tìm hiểu về văn hóa Ninja
• Thung lũng Jigokudani: với các suối nước nóng nhiệt độ cao (khoảng từ 80 độ trở lên) và nhiều
hố phun khí tạo nên cảnh quan đặc trưng
✓ Tối : Nhận phòng khách sạn, nghỉ ngơi. Nghỉ đêm tại Noboribetsu.
Trải nghiệm mặc Yukata tắm ôn tuyền thuỷ liệu pháp Onsen của người Nhật.

Ngày 2: NOBORIBETSU ✈ OTARU ✈ SAPPORO ( Ăn sáng, trưa, tối )
✓ Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Di chuyển tham
quan:
● Chụp ảnh tại hồ Toya: là một phần của Công viên Quốc gia Shikotsu Toya, được tạo thành do
dung nham của núi lửa Usu. Đây cũng là nơi ngắm lá vàng rất đẹp tại khu vực.
● Thung lũng Jozankei: thung lũng xinh đẹp được biết đến là một trong những địa điểm ngắm lá
đỏ đẹp nhất Hokkaido. Tại đây, quý khách ngắm cảnh tham quan tại:
▪ Cầu Nishiki Momiji: bắc qua Sông Otarunai chảy xuống Công viên Karyuenchi, tận hưởng
không gian đầy thi vị với tiếng nước chảy róc rách và sắc màu tuyệt đẹp của lá phong vào mùa
thu
▪ Cầu treo Futami Tsuribashi: cây cầu màu đỏ anh đào đặc trưng, thưởng thức khung cảnh
tuyệt vời với sông Toyohira và những ngọn đồi lá vàng xung quanh.
✓ Trưa : Dùng bữa trưa tại nhà hàng địa phương với. Sau đó tham quan:
• Kênh Otaru: kênh đào nhân tạo dài 1,1 km được xây dựng vào thế kỷ 19 cho các tàu nhỏ vận
chuyển hàng hóa về kho. Nổi tiếng với vẻ đẹp lãng mạn đầy hoài cổ và là nơi lý tưởng để tản bộ
thư giãn trong ngày.
• Trải nghiệm đi thuyền trên kênh đào Otaru: hành trình kéo dài 40 phút, nhìn ngắm, nghe
giới thiệu các điểm nổi bật của thành phố: lịch sử của những cây cầu, các nhà kho cũ bằng đá –
những chứng tích lịch sử cho sự hình thành và phát triển của thành phố Otaru.
• Bảo tàng hộp nhạc Otaru: là một tòa nhà gạch xinh đẹp với lối kiến trúc thời kì Phục hưng.
Tại đây, quý khách sẽ được chiêm ngưỡng các loại hộp âm nhạc đủ màu sắc, kích cỡ, hình dáng
và niên đại.
✓ Tối: Ăn tối. Nhận phòng khách sạn, nghỉ ngơi. Nghỉ đêm tại Sapporo

Ngày 3: SAPPORO CITY TOUR ( Ăn sáng, trưa, tối )
✓ Sáng : Quý khách dùng điểm tâm sáng tại khách sạn, khởi hành đi tham quan:
⚫ Chợ hải sản Nijo : được cho là phát triển từ đầu thời Minh Trị, ví như “Nhà bếp của người dân
Sapporo”. Tại đây, quý khách sẽ khám phá sự tấp nập của chợ
với nhiều gian hàng hải sản tiêu biểu vùng Hokkaido như cua,
cá hồi, sò điệp, các loài cá và các loại thực phẩm gia công chỉ
có tại Nhật.
⚫ Sapporo Beer Museum – không thể bỏ qua bảo tàng bia
nổi tiếng của Nhật Bản, được mở cửa vào năm 1987 để
công chúng tìm hiểu về quy trình sản xuất bia tươi của
thương hiệu bia Sapporo mang tính biểu tượng cũng như
để quảng bá cho nghề làm bia. Tặng mỗi khách 1 đơn vị
bia Sapporo truyền thống.
✓ Trưa : Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
• Công viên Shiroi Koibito : là một điểm tham quan độc đáo
ở thành phố Sapporo, nơi đây quý khách có cơ hội được tham
quan dây chuyền sản xuất loại bánh quy lưỡi mèo kẹp socola
trắng – Shiroi Koibito.
• Công viên Odori: một ốc đảo trong khu vực trung tâm của
Sapporo, được mở rộng trên trục đường chính của Odori với
nhiều tiểu cảnh xanh đặc sắc.
• Sapporo TV Tower – tháp truyền hình được xây dựng năm
1957 nằm trong công viên Odori xinh đẹp. Trong khuôn viên
công viên còn có quảng trường với đài phun nước, những tác phẩm điêu khắc đầy nghệ thuật.
• Tự do tham quan, mua sắm tại phố Tanukikoji – một trong những khu mua sắm lâu đời và nổi
tiếng nhất ở Sapporo, với hàng chục nhà hàng, quán bar và khu giải trí. (nếu có đủ thời gian)
✓ Tối : Dùng bữa tối. Nghỉ đêm tại Sapporo

Ngày 4: SAPPORO ✈ TOKYO ( Ăn sáng , trưa, tối )
✓ Sáng: Quý khách dùng điểm tâm sáng. Đoàn làm thủ tục trả phòng. Di chuyển đến sân bay Chitose
làm thủ tục đáp chuyến bay JL506 CTS-HND (11:00 – 12:40) về sân bay quốc tế Haneda. Ăn
trưa, sau đó tham quan:
• Đảo Odaiba: công trình nhân tạo “lấp biển” nổi tiếng tại Nhật với chức năng ban đầu phòng thủ
thành phố. Ngày nay, khu vực này phát triển thành trung tâm thương mại, khu giải trí cực kỳ
sầm uất, tấp nập.
• Aqua City Odaiba: khu phức hợp trung tâm thương mại, mua sắm, ăn uống; với vị trí tuyệt vời
có thể nhìn thấy trung tâm Tokyo qua Tượng Nữ thần Tự do và Cầu Cầu vồng.
✓ Tối: Đoàn ăn tối. Nhận phòng khách sạn, nghỉ đêm tại Tokyo.

Ngày 5: TOKYO ✈ NARIRA ✈ TP.HCM
✓ Sáng : Quý khách dùng điểm tâm sáng tại khách sạn, làm thủ tục trả phòng. Đoàn tham quan:
⚫ Chùa Asakusa: còn gọi là Sensoji – với lối kiến trúc đặc trưng mang đậm dấu ấn Nhật Bản, có
thể nói đây là ngôi chùa cổ nhất và quan trọng bậc nhất Tokyo. Chụp hình với chiếc đèn lồng
bằng giấy khổng lồ treo ở chính giữa cổng là biểu tượng của Asakusa.
⚫ Tháp truyền hình Tokyo Skytree: một trong những biểu tượng của Nhật Bản (chụp ảnh bên
ngoài)
⚫ Mua sắm tại Trung tâm điện tử Akihabara hoặc Aeon Narita Mall Nhật Bản (tùy vào thời
gian thực tế cho phép)
✓ Trưa : Đoàn dùng bữa trưa. Sau đó di chuyển ra sân bay Narita làm thủ tục đáp chuyến bay JL759
NRT – SGN 17:45 – 21:55 của hãng hàng không Japan Airlines về Việt Nam.
✓ Đáp xuống Sân bay Tân Sơn nhất, chia tay đoàn và hẹn gặp lại.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thựctế.',
    'Giá tour bao gồm
Phương tiện vận chuyển, xe đưa đón tham quan tại Nhật Bản.
Vé máy bay khứ hồi theo hãng hàng không Vietnam Airlines.
Bao gồm hành lý kí gửi 23kg (1 kiện), xách tay 12kg.
Khách sạn tiêu chuẩn 3 sao.
Ăn uống (sáng, trưa, chiều) theo chương trình.
Vé tham quan du lịch có trong chương trình.
Bảo hiểm du lịch, mức bồi hoàn tối đa 1.200.000.000 vnđ/ trường hợp.
Thuế VAT (0%) & phí phục vụ.
Hướng dẫn viên du lịch suốt tuyến.
Visa nhập cảnh Nhật Bản.

Giá tour không bao gồm
Tiền bồi dưỡng hướng dẫn viên & tài xế địa phương: 150.000 vnđ/khách/ngày
Phụ thu phòng đơn: 1.200.000 vnđ/khách/đêm
Các chi phí cá nhân & ăn uống ngoài chương trình.
Các chi phí không nằm trong danh mục đã “bao gồm” trên.

Điều kiện hủy tour
• Nếu hủy tour khách thanh toán các khoản lệ phí hủy tour, hủy vé máy bay cụ thể:
Nếu hủy chuyến du lịch ngay sau khi Đại Sứ Quán, Lãnh Sự Quán đã cấp visa: công ty du lịch có quyền hủy visa đã có, đồng thời khách sẽ chịu phí hủy theo điều khoản bên dưới:
Ngay sau khi đặt cọc tour và trước ngày khởi hành là 30 ngày: Phí hủy là 2.000.000 VNĐ
Trước ngày đi 21-30 ngày : Thanh toán 50% trên giá tour .
Trước ngày đi 14-21 ngày : Thanh toán 70% trên giá tour .
Trước ngày đi 14 ngày : Thanh toán 100% trên giá tour .
Trường hợp Quý khách bị từ chối visa : sẽ được hoàn phí 100%.

Lưu ý
Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận sức khỏe để đi du lịch nước ngoài do bác sĩ cấp và giấy cam kết sức khỏe với Công ty. Bất cứ sự cố nào xảy ra trên tour, Công ty du lịch sẽ không chịu trách nhiệm.
Quý khách mang thai xin vui lòng báo cho Công Ty khi đăng ký tour để được tư vấn thêm thông tin. Không nhận khách mang thai từ 5 tháng trở lên vì lí do an toàn cho khách.
Giá tour không bao gồm chi phí visa tái nhập vào Việt Nam đối với Việt kiều & Ngoại kiều.
Khi đăng ký, Quý Khách vui lòng nộp hộ chiếu còn giá trị trên 6 tháng tính từ ngày về.
Trường hợp quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, Công Ty sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Nếu khách là Việt kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Thứ tự và chi tiết trong chương trình có thể thay đổi để phù hợp với tình hình khách quan (thời tiết, giao thông…)
CTY sẽ không chịu trách nhiệm bảo đảm điểm tham quan trong các trường hợp xảy ra thiên tai, sự cố về an ninh, sự cố về hàng không,…
Khi đăng ký tour du lịch, Quý khách vui lòng đọc kỹ chương trình, giá tour, các khoản bao gồm cũng như không bao gồm trong chương trình, các điều kiện hủy tour trên biên nhận đóng tiền. Trong trường hợp Quý khách không trực tiếp đến đăng ký tour mà do người khác đến đăng ký thì Quý khách vui lòng tìm hiểu kỹ chương trình từ người đăng ký cho mình.',
    'https://fiditour.com/wp-content/uploads/2024/01/1-2.png
https://fiditour.com/wp-content/uploads/2024/08/nobori.jpeg
https://fiditour.com/wp-content/uploads/2024/08/tokyo.jpeg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/nhat-ban-hokkaido-noboribetsu-otaru-sapporo-tokyo-cung-duong-hokkaido-cao-cap-6n5d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-10582', 'Nhật Bản - Mùa Thu Cung Đường Vàng - Osaka - Nara - Kyoto - Yamanashi - Tokyo - Narita 6N5Đ',
    'TP.HCM', 'Nhật Bản', '6N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 60 DAY) + INTERVAL 7 HOUR,
    29890000, 22418000, 30, 23, 'https://fiditour.com/wp-content/uploads/2024/01/2-4.png',
    'Đến sân bay Kansai, làm thủ tục nhập cảnh. Khởi hành đi tham quan : ❖ Đền Todaiji: một ngôi chùa danh tiếng thuộc Hoa Nghiêm tông, ở thành phố Nara, Nhật Bản. Đại Phật điện là công trình kiến trúc gỗ lớn nhất thế giới. Nơi đây đặt pho…',
    'Ngày 1: KANSAI ✈ NARA ✈ OSAKA ( Ăn sáng, trưa, tối )
Sáng: Đến sân bay Kansai, làm thủ tục nhập cảnh. Khởi hành đi tham quan :
❖ Đền Todaiji: một ngôi chùa danh tiếng thuộc Hoa Nghiêm tông, ở thành phố Nara, Nhật Bản. Đại
Phật điện là công trình kiến trúc gỗ lớn nhất thế giới. Nơi đây đặt pho tượng Phật Tỳ Lô Giá Na
đúc bằng đồng đen, cũng là một kỷ lục nặng 500 tấn.
❖ Công viên Nara: nổi tiếng là nơi có nhiều chú nai thuần hóa. Quý khách có thể ngắm cảnh, chụp ảnh và vui chơi cùng những
chú nai ở đây.
Trưa: Đoàn dùng bữa với đặc sản bò Kobe trứ danh. Sau đó, di chuyển đến Osaka, tham quan:
❖ Lâu đài Osaka: là biểu tượng chính của Osaka, được xây dựng
từ thế kỷ XVI bởi Toyotomi Hideyoshi – người đầu tiên hoàn
thành công cuộc thống nhất Nhật Bản. (chụp ảnh bên ngoài)
❖ Mua sắm tại Shinsaibashi: khu mua sắm sầm uất nhất Osaka mang nét đặc trưng tổng hợp giữa Mỹ và Nhật Bản với hàng trăm cửa hàng liền kề nhau, góp mặt của hàng trăm thương hiệu nổi tiếng.
Tối: Đoàn dùng bữa tối. Nghỉ đêm tại khách sạn 4 sao ở Osaka.

Ngày 2: OSAKA ✈ YAMANASHI ✈ NAGOYA ( Ăn sáng, trưa, tối )
Sáng : Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng.Di chuyển tham quan:
❖ Chùa Thanh Thuỷ (Kiyomizu): một trong những địa danh tiêu biểu khi nhắc về vùng đất Kyoto. Thu hút du khách bởi quang cảnh thiên nhiên có thể ngắm nhìn từ ngôi chùa đóng cột gỗ chênh vênh giữa lưng núi.
Trưa : Dùng bữa trưa tại
nhà hàng địa phương. Sau đó, di chuyển về Nagoya :
Lễ hội lá Phong tại thung lũng Korankei: với hai bên sườn núi bao phủ bởi cây phong lá đỏ Nhật Bản, với hơn 11 phân loài biến thể quý hiếm. Đặc biệt, từ trên cầu Cầu Taigetsukyo bắc qua thung lũng, quý khách có thể phóng tầm mắt ôm trọn vẻ đẹp mùa thu lá đỏ tuyệt vời.
Tối: Đoàn dùng bữa tối và nhận phòng khách sạn để nghỉ ngơi. Nghỉ đêm tại Nagoya.

Ngày 3: NAGOYA ✈ YAMANASHI ✈ FUJI ( Ăn sáng, trưa, tối )
Sáng: Quý khách dùng điểm tâm sáng tại khách sạn. Đoàn làm thủ tục trả phòng. Sau đó, trải nghiệm di chuyển bằng tàu Shinkansen – được xem là niềm tự hào của nền giao thông Nhật Bản.
Núi Phú Sĩ – Là ngọn núi cao nhất Nhật Bản so với mực nước biển là 3776 mét. Đây cũng là danh lam thắng cảnh, di tích lịch sử, và đã được công nhận là di sản văn hóa thế giới. Quý khách sẽ lên trạm dừng chân thứ 5 ở độ cao 2.300m để ngắm núi Phú Sĩ rõ hơn (Nếu thời tiết cho phép).
Trưa : Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Dạo thuyền trên hồ Ashi: là một hồ nước nằm trên miệng núi lửa ở vùng Hakone Nhật Bản, thưởng thức cảnh đẹp mùa thu quanh hồ và ngắm nhìn núi Phú Sĩ ở phía xa.
Cánh đồng cỏ lau Sengokuhara: nổi tiếng với cỏ lau Nhật, được trồng để dùng lợp mái nhà trong thời kì Edo, thưởng ngoạn khung cảnh những bông cỏ lau đang đong đưa trong gió đầy lãng mạn.
Tối : Đoàn dùng bữa tối theo với đặc sản Cua Tuyết.
Sau đó đoàn về khách sạn nhận phòng nghỉ ngơi. Nghỉ đêm tại Yamanashi.
Trải nghiệm tắm Onsen – một kiểu ôn tuyền thủy liệu pháp của người Nhật.

Ngày 4: YAMANASHI ✈ TOKYO ✈ NARITA ( Ăn sáng , trưa, tối )
Sáng: Quý khách dùng điểm tâm sáng. Đoàn làm thủ tục trả phòng. Khởi hành đi tham quan:
Làng văn hoá Oshino Hakkai: được Unesco công nhận là Di sản Văn hóa Thế giới. Nơi đây là điểm đến lý tưởng dành cho những người yêu thích sự yên bình, cảm nhận thiên nhiên tươi đẹp của du lịch Nhật.
Chụp ảnh tại đại lộ Icho Namiki: một trong những con đường đẹp nhất ở Tokyo, đặc trưng với hai hàng cây bạch quả tại chuyển sắc tạo nên khung cảnh rực rỡ màu vàng cam, sáng bừng khung cảnh phố thị.
Trưa: Đoàn dùng bữa trưa. Sau đó tiếp tục tham quan:
Chùa Asakusa: còn gọi là Sensoji – với lối kiến trúc đặc trưng mang đậm dấu ấn Nhật Bản, có thể nói đây là ngôi chùa cổ nhất và quan trọng bậc nhất Tokyo. Chụp hình với chiếc đèn lồng bằng giấy khổng lồ treo ở chính giữa cổng là biểu tượng của Asakusa. Dạo quanh phố mua sắm Nakamise dẫn vào chùa Asakusa nhộn nhịp với hằng trăm gian hàng đồ truyền thống, quà lưu niệm và món ăn địa phương.
Mua sắm tại trung tâm điện tử Akihabara, gắn liền với các nhân vật anime và manga nổi tiếng được trưng bày nổi bật trong các cửa hàng. (Nếu có đủ thời gian )
Tối : Xe đưa đoàn dùng bữa tối, về khách sạn 4 sao để nghỉ ngơi. Nghỉ đêm tại NARITA.

Ngày 5: ✈ TP.HCM
Sáng: Quý khách dùng bữa sáng, làm thủ tục trả phòng, sau đó xe đưa đoàn ra sân bay quốc tế Narita và làm thủ tục đáp chuyến bay Vietjet Air VJ823 (08:55 – 13:55 ) về lại TP. Hồ Chí Minh.
Đáp xuống Sân bay Tân Sơn nhất, chia tay đoàn và hẹn gặp lại quý khách.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thựctế.
GIÁ TOUR TRỌN GÓI BAO GỒM:
Vé máy bay khứ hồi theo đoàn (SGN-KIX// NRT-SGN) bao gồm hành lý ký gửi và xách tay.
Khách sạn 3 sao (2 người/ phòng, trường hợp phòng 3 nếu khách đi lẻ 1 hoặc 3 người).
Visa theo đoàn nhập cảnh Nhật Bản.
Các bữa ăn theo chương trình.
Vé vào cổng một lần các nơi tham quan theo chương trình tour.
Xe máy lạnh đưa đón tham quan theo chương trình
Bảo hiểm du lịch toàn cầu trị giá 100.000.000 VNĐ/khách/Trường hợp.
Hướng dẫn viên phục vụ đoàn theo chương trình tour.
Hướng dẫn viên du lịch suốt tuyến.
Visa nhập cảnh Nhật Bản.
GIÁ TOUR TRỌN GÓI KHÔNG BAO GỒM:
Hộ chiếu còn thời hạn trên 6 tháng.
Phụ thu phòng đơn 6.000.000 VNĐ (dành cho khách yêu cầu ở phòng đơn).
Chi phí cá nhân: nước uống, giặt ủi, hành lý quá cước, điện thoại, chụp hình…
Tip cho hướng dẫn viên và tài xế (900.000 VNĐ /Khách/Tour).
Visa tái nhập Việt Nam dành cho khách quốc tịch nước ngoài.
Các chi phí khác không nằm trong mục bao gồm.',
    NULL,
    'https://fiditour.com/wp-content/uploads/2024/08/laudaiosaka.jpeg
https://fiditour.com/wp-content/uploads/2024/08/nui-phu-si.jpeg
https://fiditour.com/wp-content/uploads/2024/08/canhdongcolau.jpeg
https://fiditour.com/wp-content/uploads/2024/08/langvanhoa.jpeg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/nhat-ban-mua-thu-cung-duong-vang-osaka-nara-kyoto-yamanashi-tokyo-narita-6n5d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-10090', 'Hành Trình Về Đất Phật - Ấn Độ - Nepal 7N7Đ',
    'TP.HCM', 'Ấn Độ', '7N7Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 63 DAY) + INTERVAL 7 HOUR,
    29990000, 22492000, 20, 19, 'https://fiditour.com/wp-content/uploads/2025/01/ando-nepal-Lumbini.jpg',
    'Đêm đầu tiên lúc 23:45: Trưởng đoàn đón đoàn tại cổng D2, cột số 12, ga đi quốc tế Sân bay Tân Sơn Nhất để làm thủ tục đáp chuyến bay của hàng hàng không Indigo Airlines đi Kolkata. Sáng: Đoàn tới sân bay Kolkata, làm thủ tục nhập cảnh Ấn…',
    'Ngày 1: TP. HỒ CHÍ MINH – VARANASI
Đêm đầu tiên lúc 23:45: Trưởng đoàn đón đoàn tại cổng D2, cột số 12, ga đi quốc tế Sân bay Tân Sơn Nhất để làm thủ tục đáp chuyến bay của hàng hàng không Indigo Airlines đi Kolkata.
Sáng: Đoàn tới sân bay Kolkata, làm thủ tục nhập cảnh Ấn Độ.
Đoàn ăn sáng và làm thủ tục đáp chuyến bay 6E822 đến Varanasi.
Xe và Hướng dẫn viên địa phương đón đoàn, đưa đoàn tới dùng bữa trưa tại khách sạn, sau đó đi tham quan
Vườn Lộc Uyển (Sarnath) – là nơi Đức Phật thuyết pháp lần đầu tiên sau khi Ngài Thành Đạo, bài “TỨ DIỆU ĐẾ” cho 05 anh em nhà Kiều Trần Như. Đây là nơi rao giảng đầu tiên sau khi Đức phật Thích Ca Mâu Ni giác ngộ. Vườn Lộc Uyển có Bảo tàng Khảo cổ học, bảo tháp Dhamekh, chùa Trung Quốc, đền Miến Điện, đền Tây Tạng… Là nơi người từ khắp nơi trên thế giới đến để thờ phượng quanh năm.
Tham quan Bảo tàng Sarnath, chiêm ngưỡng bảo vật và tìm hiểu về lịch sử của Ấn Độ và Phật Giáo.
Tối: Quý đoàn dùng cơm tối tại nhà hàng địa phương.
Nghỉ đêm tại Varanasi.

Ngày 2: VARANASI – SRAVASTI
Sáng: Quý đoàn làm thủ tục trả phòng khách sạn sớm và di chuyển lên tàu ngắm bình minh trên sông Hằng – chỉ một khoảnh khắc trên sông thôi, chúng ta cũng sẽ được chứng kiến Khổ đế – Sanh, Lão, Bệnh, Tử…
Đoàn dùng bữa sáng và làm thủ tục trả phòng khách sạn. Sau đó khởi hành đi city tour Varanashi bao gồm
Monkey Temple: Các đền thờ khắp nước Ấn Độ đều có hình ảnh Hanuman, vị thần khỉ nổi tiếng với vũ khí là quả chùy (gada), biểu tượng của lòng dũng cảm.
Durga Mata Temple và Bharat Mata temple: 2 trong số 20 ngôi đền Hindu giáo đẹp nhất Ấn Độ nên ghé thăm tại thành phố cổ Varanasi
Trưa: Quý đoàn dùng bữa trưa trên đường về Sravasti, sau đó tham quan
Thăm phế tháp Sudatta là ngôi phế tháp cổ nhất tại Shravasti, Ấn Độ. Tháp này được xây bởi cư sĩ Tu Đạt (Sudatta) một thương gia triệu phú giàu có và thường hay giúp đỡ cho những kẻ cô đơn nghèo khổ nên dân chúng địa phương tặng cho ông ta cái tên đặc biệt “Anathapindika” có nghĩa là “Cấp Cô Độc”.
Phế tháp Angulimala (ngài Vô Não), nơi Angulimala được hỏa táng.
Tối: Đến Sravasti đoàn ăn tối, Quý khách nhận phòng nghỉ ngơi. Nghỉ đêm tại Sravasti.

Ngày 3: SRAVASTI – LUMBINI
Sáng: Sau bữa sáng Quý đoàn làm thủ tục trả phòng và khởi hành đi chiêm bái:
Rừng Thệ Đà hay Kỳ Viên Tịnh Xá (Jetavana Vihara): nơi Đức Phật đã thuyết pháp tại đây cho tăng đoàn trong 24 mùa an cư kiết hạ.
Cây Bồ Đề Ananda: được trồng làm biểu tượng hiện thân của Đức Phật cho những Phật tử, cư sĩ đến đảnh lễ trong thời gian Đức Phật vắng mặt hay giảng pháp ở những nơi khác.
Trưa: Sau bữa trưa Quý đoàn khởi hành đi Lâm Tỳ Ni (Lumbini)
Tối: Đến Lâm Tì Ni, Quý đoàn dùng cơm tối , nhận phòng nghỉ ngơi.

Ngày 4: LUMBINI – KUSHINAGAR
Sáng: Sau bữa sáng, Quý khách trả phòng, chiêm bái và đảnh lễ tại:
Vườn Lâm Tì Ni – nơi Đức Phật đản sanh. Đoàn sẽ đảnh lễ tại 02 vị trí quan trọng nhất trong vườn là Nơi Thái Tử Sĩ Đạt Ta đản sanh và trụ đá Vua A Dục.
Đền thờ Hoàng hậu Maya – được xây dựng cách nay gần 2600 năm, cách Kathmandu thủ đô Nepal khoảng 240km – là cái nôi của Phật giáo mô tả cảnh hoàng hậu Maya sinh thái tử Tất-đạt-đa (Đức Phật).
Quý đoàn dùng cơm trưa và khởi hành về Câu Thi Na.
Tối: Đến Câu Thi Na (Kushinagar) Quý đoàn nhận phòng, ăn tối.
Nghỉ đêm tại Câu Thi Na.

Ngày 5: KUSHINAGAR – VAISHALI – RAJGIR
Sáng: Quý đoàn dậy sớm làm thủ tục trả phòng khách sạn và di chuyển chiêm bái và đảnh lễ:
Tháp Trà Tỳ – Nơi làm lễ Trà tỳ Kim Thân của Đức Phật và Xá Lợi được chia thành 08 phần bằng nhau cho 8 quốc gia mộ đạo.
Đền Đại Niết Bàn nơi cách đây hơn 2554 năm khi Đức Phật nhập diệt, được xây tại thánh tích Câu Thi Na để tôn thờ xá lợi của Đức Phật, đồng thời để kỉ niệm nơi Đức Phật đã xả bỏ báo thân sanh diệt, an trú vào niết bàn bất diệt.
Quý khách cùng làm lễ Đắp Y Phật tại đây
Trưa: Quý đoàn hành hương dùng bữa trưa xong tiếp tục chiêm bái:
Trụ đá vua A Dục Kolhua: là 1 khối đá sa thạch nguyên khối cao 6,7m với tượng Sư Tử trên đầu, quay mặt về hướng bắc, đánh dấu nơi Đức Phật giảng bài pháp cuối cùng, hàm chứa các nội dung nói đến chuyến đi vào cõi Niết Bàn của Người.
Quý đoàn tiếp tục đến thành phố Rajgir (Vương Xá thành), kinh đô đầu tiên của vương quốc cổ Magadha (Ma Kiệt Đà), nơi Đức Phật thường đi khất thực và là trung tâm nghiên cứu Phật Giáo qua nhiều thế kỷ.
Tối: Quý đoàn về đến Rajgir, dùng bữa tối, nhận phòng nghỉ ngơi.

Ngày 6: RAJGIR – NALANDA – BODHGAYA
Sáng: Sau khi ăn sáng, Quý đoàn rời Rajgir, khởi hành đi tham quan:
Viện Đại học Nalanda: trường đại học Phật giáo đầu tiên và lớn nhất trên thế giới với diện tích 49 km2, được thành lập 400 năm sau khi Đức Phật nhập diệt. Đây là quê hương của ngài Xá Lợi Phất và cũng là nơi ngài nhập diệt trước Đức Phật.
Đỉnh núi Linh Thứu (Gijjhakuta): một ngọn núi nhỏ như hình con kền kền tọa lạc ở phía Nam thành Vương Xá. Đây là nơi Đức Phật từng thuyết giảng Bát Nhã Tâm Kinh, Diệu Pháp Liên Hoa và cũng là nơi Đức Phật rất thích ngồi thiền mỗi ngày. Và đây là nơi đã từng diễn ra Linh Sơn hội chư thượng Phật.
Trưa: Quý đoàn Phật tử cúng thọ trai sau đó viếng thăm:
Làng Sujata: cách Bồ Đề Đạo Tràng 2km, đảnh lễ đền thờ Sujata để tỏ lòng tri ân đối với người đã cúng dường bát cháo sữa cho Thái Tử Tất Đạt Đa khi ngài bị kiệt sức bên dòng sông Ni Liên Thiền.
Sông Ni Liên Thiền: nơi Thái Tử thả bình bát và phát nguyện thành đạo.
Sau đó, Quý đoàn di chuyển về Bodhgaya. Quý Phật tử dùng bữa tối và đảnh lễ Tháp Đại Giác chiêm ngưỡng tháp Đại Giác Ngộ và Cội Bồ Đề về đêm với ánh đèn lung linh, Quý đoàn có thể ngồi thiền và đọc kinh tại đây. Nghỉ ngơi tại Bodhgaya.

Ngày 7: BODHGAYA – HỒ CHÍ MINH
Sáng: Quý đoàn hành hương dùng điểm tâm. Quý Phật tử sắp xếp vào đảnh lễ Tháp Đại Giác và cội Bồ Đề trước khi rời đất Phật.
Tháp Đại Giác: Là một trong Tứ Thánh Tích của Phật Giáo. Là nơi đánh dấu sự giác ngộ của Đức Phật Thích Ca.
Cội Bồ Đề: Nơi Thái tử Tất Đạt Đa đã ngồi thiền 49 ngày để đạt được đại giác ngộ. Trải qua hơn 2600 năm, cây Bồ Đề từng bị đốn hạ, rồi trồng lại nhiều lần, ngày nay hậu duệ của Cội Bồ Đề vẫn phát triển mạnh mẽ và vẫn không thay đổi so với vị trí ban đầu.
Quý đoàn tự do mua sắm các mặt hàng lưu niệm.
Trưa: Quý đoàn dùm cơm tại nhà hàng, làm thủ tục trả phòng rồi ra sân bay quốc tế Gaya để bay về Việt Nam với chuyến bay dự kiến của hãng hàng không Indigo Airlines đi Hồ Chí Minh (quá cảnh tại Kolkata).
02:35 Về đến sân bay Tân Sơn Nhất, Quý đoàn hành hương làm thủ tục nhập cảnh Việt Nam. Trưởng Đoàn chia tay Quý Phật tử và hẹn gặp lại. Kết thúc chương trình “Tứ động tâm”
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Giá tour bao gồm
Vé máy bay khứ hồi SGN/VNS/GAY/SGN (07 kg hành lý xách tay + 30kg hành lý ký gửi (tối đa 02 kiện)
Visa Nepal
Visa Ấn Độ
Phí an ninh sân bay, bảo hiểm phi trường.
Khách sạn 4 sao tiêu chuẩn nội địa Ấn (phòng đôi 2 người/phòng; trường hợp khách lẻ sẽ xếp 3 người/phòng)
Buffet chay mặn và bữa ăn tại nhà hàng theo chương trình.
Y dâng Phật
Xe máy lạnh vận chuyển suốt tuyến.
Vé tham quan theo chương trình.
Hướng dẫn viên địa phương và hướng dẫn viên từ Việt nam theo đoàn suốt tuyến.
Nước suối 01 chai/khách/ngày.
Bảo hiểm du lịch toàn chặng trị giá 1,150,000,000 VND tương đương 50,000USD

*thủ tục xin visa ấn độ, nepal*
– Hộ chiếu còn hạn trên 6 tháng tính đến ngày kết thúc tour
– Hình thẻ nền trắng 4×6

Giá tour không bao gồm
Tiền cúng dường, dâng hương tại chùa.
Các chi phí cá nhân, hành lý quá cước, điện thoại, giặt ủi, tham quan ngoài chương trình.
Chi phí phát sinh trong trường hợp bất khả kháng như hoãn/huỷ chuyến bay, tăng giá vé, các trường hợp thiên tai bất khả kháng.
Các dịch vụ không có trong chương trình.
Visa tái nhập cảnh Việt Nam cho khách có quốc tịch nước ngoài.
Tiền Tip cho HDV và lái xe ở nước ngoài: 10 usd/ngày/khách (70 usd toàn chặng)
Phụ thu phòng đơn 5.000.000/khách

Huỷ tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 14 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 30 ngày phí phạt = 50% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình (+phí visa nếu có) (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (+ phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty hoặc qua fax, email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.

Lưu ý
• Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, Công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn.
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể thay đổi mà không được thông báo trước.
(Hộ chiếu) Phải còn thời hạn sử dụng trên 6 tháng (Tính từ ngày khởi hành).
Tour thuần túy du lịch, suốt chương trình Quý khách không được rời đoàn.
Visa đoàn Quý khách phải đi và về cùng đoàn, không được phép tách đoàn hoặc ở lại.
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour
Trẻ em dưới 15 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ
Cty sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ Trung Quốc.',
    'https://fiditour.com/wp-content/uploads/2022/12/5-14.png
https://fiditour.com/wp-content/uploads/2022/12/6-7.png
https://fiditour.com/wp-content/uploads/2022/12/7-5.png
https://fiditour.com/wp-content/uploads/2022/12/8-2.png
https://fiditour.com/wp-content/uploads/2022/12/9-2.png',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/hanh-trinh-ve-dat-phat-an-do-nepal-7n7d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-10066', 'Brunei - Dubai - Abu Bhabi 6N5Đ',
    'TP.HCM', 'Dubai', '6N5Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 66 DAY) + INTERVAL 7 HOUR,
    28990000, 21742000, 25, 21, 'https://fiditour.com/wp-content/uploads/2024/04/1.png',
    'Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ tục và đáp chuyến bay của hãng Hoàng Gia Brunei ( Royal Brunei Airlines 4* ). Sau đó tiếp tục nối chuyến bay đến Dubai. BI382 SGN – BWN 14:05 – 17:10…',
    'Ngày 1: TP.HCM – BRUNEI – DUBAI
Quý khách tập trung tại sân bay Tân Sơn Nhất ga đi quốc tế, Trưởng Đoàn hướng dẫn làm thủ
tục và đáp chuyến bay của hãng Hoàng Gia Brunei ( Royal Brunei Airlines 4* ). Sau đó tiếp tục nối
chuyến bay đến Dubai.
BI382 SGN – BWN 14:05 – 17:10
BI97 BWN – DXB 19:15 – 23:30
– Trên máy bay, Quý khách sẽ được phục vụ bữa ăn tự chọn theo thực đơn Âu – Á hấp dẫn. Đến sân
bay Dubai, làm thủ tục nhập cảnh, sau đó xe và hướng dẫn viên địa phướng đón đoàn và đưa về
khách sạn nhận phòng nghỉ ngơi.

Ngày 2: DUBAI  CHỢ VÀNG
Sáng: Quý khách dùng bữa sáng tại khách sạn, sau đó, quý khách bắt đầu hành trình tham quan:\\
Quý khách dừng chân bên nhánh long Dubai Creek để tham quan chợ vàng Gold Souk và chợ hương liệu Spice Souk.
Tiếp theo điều mà du khách cảm thấy thú vị nhất ở đây là sử dụng dịch vụ “taxi nước” truyền thống dọc theo tuyến đường từ khu vực hành chính ở Deria đến các khu chợ cổ độc đáo ở Dubai.
Đoàn dùng cơm trưa, tiếp tục chương trình tham quan.
Dubai Mall – Quý khách tham quan mua sắm với những gian hàng của các thương hiệu nổi tiếng hàng đầu như Dolce & Gabbana, Alexander McQueen, Marks & Spencer…, tại đây còn có Công viên nước Dubai, Trung tâm Discovery, cửa hàng kẹo lớn nhất thế giới Candylicious, công viên trong nhà rộng hơn 7.000 m2 và sân trượt băng trong nhà. Bên trong Dubai Mall còn có rạp chiếu phim Reel với 22 phòng chiếu cao cấp.
Tháp Burj Khalifa – Tòa tháp này là điểm nhấn thu hút khách du lịch của Dubai, bao gồm khu dân cư, thương mại, khách sạn, vui chơi giải trí, trung tâm mua sắm lớn nhất thế giới. Quý khách dừng chân chụp hình lưu niệm tại đây, có thể tự túc chi phí tới Đài quan sát cao nhất thế giới đặt ở tầng 124 của tòa nhà.
18:30 Quý khách chiêm ngưỡng Water Fountain show đặc sắc – một sự kết hợp hoàn hảo giữa âm thanh ánh sáng và những điệu vũ tuyệt đẹp của nước.
Đoàn đi dùng bữa tối tại nhà hàng, sau đó về khách sạn nhận phòng nghỉ ngơi tại Dubai.

Ngày 3: DUBAI – SA MẠC SAFARI
Quý khách dùng điểm tâm sáng và bắt đầu chương trình:
Đoàn tham quan Đảo cọ nhân tạo (Palm Jumeirah) – Ngồi
tàu điện trên không sẽ giúp quý khách đến đảo cọ nhanh chóng và có cơ hội chiêm ngưỡng vẻ đẹp của hòn đảo nhân tạo từ trên cao.
Đoàn chụp hình trước Khách sạn 7 sao nổi tiếng Thế giới
Burj Al Arab – ngọn tháp của Ả Rập cao 321m. Đây là một trong những khách sạn bậc nhất Thế giới, có hình thuyền buồm Ả Rập, là biểu tượng cho sự đô thị hoá của Dubai và nằm trên một hòn đảo nhân tạo cách đất liền 280m.
Tham quan cửa hàng Thảm
Đoàn dùng bữa trưa sau đó tiếp tục hành trình khám phá Sa
mạc Safari (1xe/6 khách) bằng xe chuyên dụng Land Cruiser.
Đến điểm dừng chân, cửa ngõ trước khi vào Sa mạc. Quý khách bắt đầu cuộc phiêu lưu của mình với cảm giác mạo hiểm trên các đồi cát. Cuối hành trình, Quý khách sẽ đến điểm cắm trại Lạc đà – một địa điểm tập kết của người dân địa phương để đón các đoàn khách du lịch. Chính nơi đây Quý khách sẽ tận hưởng cảm giác tuyệt vời khi chiêm ngưỡng hoàng hôn sa mạc như một dân du mục thực thụ. Quý khách sẽ được chào đón một cách nồng ấm bởi người dân nơi đây, thưởng thức những tách cafe Ả Rập, hút thử sheesha, uống thử sữa lạc đà…và đặc biệt là một bữa tiệc buffet BBQ cùng với các vũ công belly dance cực kỳ quyến rũ.

Ngày 4: DUBAI – ABU DHABI
Kết thúc chương trình xe đưa Đoàn về khách sạn nghỉ ngơi.
Sau bữa điểm tâm sáng, đoàn khởi hành đi tham quan Abu Dhabi. Xe đưa đi tham quan :
Đoàn tham quan Thánh đường Hồi giáo Sheikh Zayed. Đây là thánh đường xa hoa nhất thế giới, với những vật liệu xa xỉ như đá cẩm thạch trắng, pha lê màu Swarovski, thảm Ba Tư… Cả thánh đường có đến 82 mái vòm và 1.048 chiếc cột bên ngoài có hình cây chà là – loài cây đặc trưng của Trung Đông. Ngoài ra thánh đường còn có sức chứa đáng kinh ngạc với hơn 40.000 tín đồ cầu nguyện cùng một lúc.
Dates Market – khu chợ nông sản, nơi bày bán các sản vật đặc trưng của vùng như chà là, ngũ cốc, hoa quả khô…
Làng di sản (Heritage Village) – Tại đây quý khách tìm hiểu về lịch sử, cuộc sống của dân tộc ở Abu Dhabi trong quá khứ – nơi chỉ có những trang trại trên sa mạc, lều bằng lông thú, làng chài và khu chợ cũ.
Đảo YAS (Yas Island) – hòn đảo xinh đẹp và hiện đại với công viên mô phỏng theo hình dạng của hãng xe đua nổi tiếng thế giới Ferrari World.
Tự do mua sắm tại Yas Mall – địa điểm mua sắm, ăn uống và vui chơi giải trí của Abu Dhabi nằm ở trung tâm đảo Yas.
Xe đưa đoàn dọc theo Đại lộ Corniche nổi tiếng thưởng ngoạn cảnh đẹp bên Vịnh Ba Tư.
Quý khách dùng bữa trưa Buffet quốc tế tại Khách sạn 5*
Chụp nhìn bên ngoài và Ngắm nhìn tòa lâu đài nguy nga và sang trọng Emirates Palace – “thiên đường 7* trên mặt đất” và đắt đỏ nhất hành tinh với 40 tấn vàng được dùng để trang trí
Quý khách có cơ hội thưởng thức bánh phủ vàng (Chi phí tự túc)
Vườn hoa Miracle Garden: Công viên hoa Dubai Miracle rộng 72.000 m2 nằm ở Dubailand – khu phức hợp giải trí nằm ở Dubai. Công viên này tự hào với hơn 150 triệu bông hoa – và hơn 120 giống khác nhau. Với thành tựu đó, Dubai Miracle Garden là vườn hoa tự nhiên lớn nhất thế giới và năm 2021 đã đánh dấu mùa thứ 10 của nơi này.

Ngày 5: DUBAI – BRUNEI
Đoàn dùng cơm tối và về khách sạn nghỉ ngơi.
Qúy khách làm thủ tục trả phòng, dùng bữa sáng, sau đó di chuyển ra sân bay về Brunei trên chuyến bay
BI098 DXB – BWN 05:15 – 17:30
Đến sân bay Brunei – Bandar Seri Begawan, xe và hướng dẫn địa phương đón đoàn đưa đi ăn tối.
Chợ đêm Gadong – Đây là một địa điểm yêu thích của Brunei cho một loạt các món ăn địa phương ngon nhưng giá cả phải chăng, cũng là một nơi gặp gỡ yêu thích cho mọi tầng lớp xã hội. Điểm thu hút chính của chợ đêm Gadong chắc chắn là khu vực bán đồ ăn. Trái cây nhiệt đới và hải sản ở đây rất phong phú, tươi ngon và được bán với mức giá rất thấp.
Đoàn dùng cơm tối và về khách sạn nghỉ ngơi.
Qúy khách tự do tham quan, mua sắm tại Brunei.

Ngày 6: BRUNEI – TP. HỒ CHÍ MINH
Quý khách dùng bữa sáng và làm thủ tục trả phòng. Sau đó, xe đưa quý khách đi tham quan:
Làng văn hoá lịch sử Kampung Ayer – Water Viilage hơn 600 năm (hơn 30 ngàn cư dân sinh sống trong những ngôi nhà xây dựng nổi trên mặt nước với đầy đủ tiện nghi khác hẳn với dáng vẻ bên ngoài).
Trưa: Qúy khách dùng bữa trưa tại nhà hàng địa phương, sau đó, xe đưa đoàn tham quan:
Thánh đường Hồi giáo Jame Asr Hassanil Bolkiah trị giá vật chất hàng tỷ đô la Mỹ.
Thánh đường Hồi giáo Omar Ali Saifuddien.
Chụp ảnh lưu niệm bên ngoài Hoàng cung Istana Nurul Iman.
Bảo tàng Hoàng gia Regalia – với nhiều biểu tượng dát vàng, bạc và các loại đá quý như Cung điện hoàng gia, xe ngựa hoàng gia, huy hiệu hoàng gia…
Quý khách di chuyển ra sân bay và làm thủ tục chuyến bay của hãng hàng không hoàng gia Brunei về lại đến thành phố Hồ Chí Minh. Chia tay và hẹn gặp lại quý khách.
BI383 BWN – SGN 20:00 – 20:55
Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách !',
    'Giá tour bao gồm
Vé máy bay khứ hồi theo đoàn của hàng không Royal Brunei Airlines 4* (SGN – BRUNEI – DUBAI – BRUNEI – SGN ) bao gồm 7kg hành lý xách tay + 20kg hành lý kí gửi.
Bảo hiểm du lịch Quốc tế suốt tuyến.
Phí an ninh sân bay, bảo hiểm hàng không thuế phi trường 2 nước (có thể thay đổi tại thời
điểm xuất vé).
Khách sạn tiêu chuẩn 4* (2 – 3 người/phòng): 4 đêm KS tại Dubai + 1 đêm tại Brunei.
Các bữa như trong chương trình trong đó có 1 bữa ăn buffet tại ks 5* quốc tế và 01 Bữa
tối BBQ tại Sa Mạc.
Visa nhập cảnh UAE 1 lượt, Phí du lịch Tourism Dirham.
Phục vụ Nước uống theo xe trong các ngày du lịch.
Tham quan Đảo Cọ bằng tàu điện 1 lượt
Trải nghiệm taxi nước kiểu Arab – Water taxi.
Xe máy lạnh vận chuyển suốt tuyến.
Vé tham quan như chương trình.
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình.

Giá tour không bao gồm
Hộ chiếu thời hạn không dưới 6 tháng tính từ ngày về.
Các chi phí phát sinh không đề cập trong chương trình.
Vé tham quan các điểm ngoài chương trình.
Phụ thu phòng đơn với khách có nhu cầu ngủ riêng 1 phòng: 10.000.000 vnđ/khách/tour
Tip HDV và tài xế 1.050.000/khách/tour.
Visa tái nhập đối với khách mang quốc tịch nước ngoài.
Hành lý quá cước quy định, xe vận chuyển và HDV ngoài giờ v.v..

Điều kiện xin visa
Bản scan Hộ chiếu (còn thời hạn trên 6 tháng tính theo ngày về) + hình 4 x 6: 1 tấm.
Giấy kết hôn (vợ chồng đi chung – nếu có).
Trẻ em dưới 18 tuổi phải có kèm theo bản sao khai sinh, giấy cho phép đi du lịch của bố mẹ.
Trường hợp nếu trẻ em dưới 18 tuổi không đi chung với bố/mẹ thì phải làm visa cho bố/mẹ phí 2.400.000 vnđ

Điều kiện hoàn/hủy tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc (+phí visa nếu có).
Hủy tour trước 25 ngày phí phạt = 50% tổng giá tour chương trình(+phí visa nếu có) (Tính theo ngày làm việc)
Hủy tour trước 20 ngày phí phạt = 75% tổng giá tour chương trình(+phí visa nếu có)(Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình(+phí visa nếu có). (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bặng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.
Thời gian hủy tour được tính cho ngày làm việc, không tính thứ bảy, chủ nhật và các ngày Lễ Tết.
Trường hợp Quý khách bị từ chối không cấp visa từ Lãnh Sự Quán:
– Công ty sẽ hoàn trả lại tiền tour và thu phí visa + phí hoàn vé máy bay là 4.500.000 VNĐ/khách
Qúy khách có thể nộp lại visa khẩn: 2.400.000 VNĐ/khách nếu bị từ chối cấp visa lần 1

Lưu ý
Nếu khách hàng bị cơ quan xuất nhập cảnh từ chối xuất cảnh hoặc nhập cảnh vì lí do cá nhân hay nhân thân, công ty du lịch sẽ không chịu trách nhiệm và sẽ không hoàn trả tiền tour.
Không giải quyết cho bất kì lí do thăm thân, kinh doanh…để tách đoàn..
Do các chuyến bay phụ thuộc vào các hãng Hàng Không nên trong một số trường hợp giờ bay có thể.
thay đổi mà không được thông báo trước.
Nếu khách là Việt Kiều hoặc nước ngoài có visa rời phải mang theo lúc đi tour.
Trường hợp quý khách đã có visa sẽ được trừ lại 2.000.000 vnđ.
Trẻ em dưới 18 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
Hồ sơ visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Ngày khởi hành có thể dời lại ít nhất 1 tuần do phụ thuộc vào kết quả visa của Lãnh Sự Quán.
Cty du lịch sẽ hỗ trợ về thủ tục hồ sơ trong khả năng khi Quý khách bị từ chối nhập cảnh vào lãnh thổ UAE.
**Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Cty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh**.',
    'https://fiditour.com/wp-content/uploads/2024/04/1-1.png
https://fiditour.com/wp-content/uploads/2024/04/2-1.png
https://fiditour.com/wp-content/uploads/2024/04/3-1.png
https://fiditour.com/wp-content/uploads/2024/04/4.png',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/brunei-dubai-abu-bhabi-6n5d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-9319', 'Malaysia - Singapore - Bay Vietjet 5N4Đ',
    'TP.HCM', 'Singapore', '5N4Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 69 DAY) + INTERVAL 7 HOUR,
    11290000, 8468000, 40, 36, 'https://fiditour.com/wp-content/uploads/2024/03/Avatar-Japan.png',
    'Trưởng đoàn đón Quý khách tại sân bay quốc tế Tân Sơn Nhất, làm thủ tục khởi hành đi Malaysia trên chuyến bay VJ825 lúc 09h40. Tới sân bay quốc tế Kuala Lumpur, đoàn làm thủ tục nhập cảnh. Trưa:Đoàn dùng bữa trưa nhẹ tại nhà hàng, xe và…',
    'Ngày 1: TP.HCM – KUALA LUMPUR
Sáng: Trưởng đoàn đón Quý khách tại sân bay quốc tế Tân Sơn Nhất, làm thủ tục khởi hành đi Malaysia trên chuyến bay VJ825 lúc 09h40.
Tới sân bay quốc tế Kuala Lumpur, đoàn làm thủ tục nhập cảnh.
Trưa:Đoàn dùng bữa trưa nhẹ tại nhà hàng, xe và HDV đón quý khách bắt đầu hành trình tham quan:
Quảng trường Độc Lập
Tượng Đài Chiến Sĩ Vô Danh
Thánh đường Hồi Giáo quốc gia
Cung Điện Hoàng Gia
Tối: Đoàn dùng bữa tối tại nhà hàng. Nhận phòng khách sạn nghỉ ngơi, tự do khám phá Kuala Lumpur.

Ngày 2: KUALA LUMPUR – GENTING DAY TOUR
Sáng: Đoàn dùng bữa sáng tại khách sạn. Xe đưa đoàn tiếp tục hành trình tham quan:
Tháp đôi Petronas – niềm tự hào của người dân Malaysia, quý khách có thể tự do khám phá và shopping ở khu trung tâm thương mại trong tháp đôi.
Mua sắm tại cửa hàng đặc sản địa phương: thưởng thức trà sâm Tongkat Ali, cà phê trắng, cửa hàng đồng hồ miễn thuế …
Động Batu – chinh phục 272 bậc thang đủ sắc màu, khám phá hang động bí ẩn, nhìn toàn cảnh bức tượng thần Murugan cao hơn 42m và tham quan các đền thờ với nhiều bức tượng độc đáo của Ấn Độ giáo.
Trưa: Đoàn dùng bữa trưa tại nhà hàng. Tiếp tục tham quan :
Cao nguyên Genting – chinh phục độ cao hơn 2000m bằng hệ thống cáp treo dài 3,4km. Khám phá thế giới sống động tại cao nguyên như: mua sắm, thử vận may tại Genting Casino nổi tiếng Đông Nam Á. (Nếu cáp treo bảo trì, sẽ di chuyển bằng xe)
Tối: Đoàn dùng bữa tối tại nhà hàng. Nhận phòng khách sạn nghỉ ngơi, nghỉ đêm tại Kuala Lumpur.

Ngày 3: KUALA LUMPUR – CITY TOUR MALACCA ( Ăn sáng/trưa/tối)
Sáng: Đoàn dùng bữa sáng, trả phòng khách sạn. Sau đó, xe và HDV đón đoàn tiếp tục tham quan:
Ghé thăm nhà máy Chocolate – nơi làm ra những viên chocolate nổi tiếng nhất Malaysia.
Tham quan Khu Putrajaya – trung tâm hành chính mới (New City) của Malaysia, còn được xem là thành phố thông minh đẳng cấp thế với những địa danh du lịch nổi tiếng như: Nhà thờ hồi giáo Putra, Văn phòng Thủ Tướng, Trung Tâm Hội Nghị. (Chụp hình bên ngoài)
Trưa: Đoàn dùng bữa trưa tại nhà hàng. Cùng tham quan các điểm đến đặc sắc tại Malacca như:
Nhà thờ Thánh Saint Paul
Pháo đài cổ Bồ Đào Nha
Quảng trường Hà Lan
Pháo đài A’famosa
Khu phố cổ Jonkers
Đền Cheng Hood.
Tối: Đoàn dùng bữa tối tại nhà hàng địa phương. Sau bữa tối, xe đưa đoàn đến thành phố Johor Bahru nghỉ đêm tại Johor Bahru.

Ngày 4: JOHOR BAHRU – SINGAPORE – SENTOSA ( Ăn sáng/ trưa/chiều)
Sáng: Đoàn dùng bữa sáng tại khách sạn, làm thủ tục trả phòng, khởi hành đến quốc đảo quốc Sư Tử – Singapore, làm thủ tục nhập cảnh, bắt đầu với các điểm tham quan
Parliament House – Tòa nhà Quốc hội
Merlion Park – Biểu tượng sư tử biển mình cá đặc trưng mang lại sự phồn thịnh cho đất nước Singapore. Từ đây, du khách có thể thấy trọn một trong những vòng đu quay cao nhất Châu Á – Singapore Flyer.
Nhà hát Victoria – Nhà hát cổ kính nhất Singapore.
Nhà hát Esplanade
Tham quan, mua sắm tại: cửa hàng vàng bạc đá quý, một trong những xưởng chế tác kim cương lớn nhất tại đất nước này. Cửa hàng dầu gió, Collagen dưỡng da và các sản phẩm truyền thống nổi tiếng khác của Singapore.
Gardens by the Bay – khu vườn nhân tạo rộng hơn 100 ha, có hơn 250.000 loài thực vật Qúy hiếm, với các “siêu cây” khổng lồ lấy năng lượng mặt trời vào ban ngày và tự tỏa sáng vào ban đêm. Từ đây Quý khách có thể chụp hình toàn cảnh “Chiếc du thuyền” nằm ở độ cao 200m nối liền 3 đỉnh của 3 tòa tháp khách sạn Marina Bay Sands. (Chụp hình bên ngoài).
Trưa: Đoàn dùng bữa trưa tại nhà hàng. Sau đó, xe đưa đoàn đi Đảo Sentosa.
Đảo Sentosa – điểm đến độc đáo, thu hút bởi sự kết hợp thú vị giữa di sản văn hóa, thiên nhiên đa dạng và bàn tay tài hoa của con người với các công viên giải trí, trung tâm nghỉ dưỡng tiện nghe hàng đầu.
Chụp hình với biểu tượng Công viên Giải trí Universal Studios.
Khám phá Resort World và tham quan khu Casino hiện đại nhất Châu Á.
Tối: Đoàn dùng bữa tối tại nhà hàng. Nhận phòng khách sạn nghỉ ngơi.
Hoặc cùng tham gia chương trình SINGAPORE BY NIGHT – khám phá một Singapore lộng lẫy về đêm (chi phí tự túc)
Khám phá cuộc sống bên dưới lòng đất của Singapore bằng hệ thống tàu điện ngầm MRT.
Đi du thuyền trên Vịnh Marina Bay Sand và ngắm ánh sáng rực rỡ của khu ăn chơi xa hoa bậc nhất Singapore – Clarke Quay.
Khám phá trung tâm thương mại Suntec City – tìm hiểu Thượng Phong Thuỷ và Hạ Phong Thuỷ cuả Singapore.

Ngày 5: SINGAPORE – TP.HCM
Sáng: Quý khách dùng bữa sáng tại khách sạn. Làm thủ tục trả phòng, xe đón đoàn đi thăm quan:
Thác nước Jewel Changi – địa điểm check in hot nhất Singapore hay còn được biết đến với tên Rain Vortex là thác nước trong nhà cao nhất thế giới, với độ cao 40m.
Trưa: Đoàn dùng bữa trưa tại nhà hàng. Sau đó HDV và xe sẽ đưa đoàn ra sân bay.
Đến hẹn, hướng dẫn viên đưa đoàn ra sân bay Quốc tế Changi, làm thủ tục trên chuyến bay VJ812 lúc 13h05 đưa đoàn xuất cảnh về lại Việt Nam.
Chia tay Quý khách và kết thúc chương trình. Hẹn gặp lại quý khách!
Chú ý : Thứ tự chương trình có thể thay đổi theo sự sắp xếp của CTY để phù hợp với tình hình thực tế nhưng vẫn đảm bảo đầy đủ các điểm tham quan đã nêu trong chương trình.',
    'Giá tour bao gồm
Quà tặng: Nón du lịch.
Vé máy bay khứ hồi SGN – SIN – KUL – SGN (Bao gồm hành lý 20kg ký gửi + 07kg xách tay)
Bảo hiểm du lịch
Phí an ninh sân bay, thuế phi trường 2 nước
Khách sạn 3, 4* tiêu chuẩn (2-3 người/phòng)
Tại Singapore: MIRAMAR, CHANCELLOR ORCHARD hoặc khách sạn có tiêu chuẩn tương đương.
Tại Indonesia: Pacific Palace Hotel, M1 Hotel hoặc khách sạn có tiêu chuẩn tương đương.
Tại Malaysia: SWAN GARDENS, RIVERIA và ROYAL BUKIT BINTANG, HOLIDAY INN KLCC hoặc khách sạn có tiêu chuẩn tương đương.
Phục vụ nước suối suốt hành trình tour
Các bữa ăn như chương trình
Xe máy lạnh vận chuyển suốt tuyến
Vé tham quan như chương trình
Trưởng đoàn và HDV địa phương phục vụ suốt tuyến theo chương trình

Giá tour không bao gồm
Phụ thu Phòng đơn 4.200.000VNĐ (cho khách có yêu cầu ngủ 1 người/phòng)
Chi phí cá nhân. Hành lý quá cước qui định.
Xe vận chuyển ngoài chương trình + Các show về đêm.
Tiền Tips cho HDV và tài xế: 5$/khách/ngày,tương đương 25$/khách/tour.
Visa tái nhập Việt Nam, visa nhập cảnh Indonesia, áp dụng cho khách nước ngoài (Khu vực Đông Nam Á được miễn)

Huỷ tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 20 ngày phí phạt = 50% tổng giá tour chương trình (Tính theo ngày làm việc).
Hủy tour trước 15 ngày phí phạt = 75% tổng giá tour chương trình (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (Tính theo ngày làm việc).
Đối với tour Lễ/ Tết: Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 15 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 45 ngày phí phạt = 50% tổng giá tour chương trình. (Tính theo ngày làm việc)
Hủy tour trong hoặc trước 30 ngày phí phạt = 75% tổng giá tour chương trình. (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình. (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bằng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.

Lưu ý
– Trước khi đăng ký tour xin quý khách vui lòng đọc kỹ chương trình tour, giá tour, các khoản bao gồm và không bao gồm trong chương trình và đặt cọc 50% tổng số tiền tour ngay khi đăng kí tour.
– Giá tour không áp dụng vào các dịp Lễ, Tết của Việt Nam, Singapore & Malaysia.
– Giá thuế hàng không là giá tạm tính , giá có thể tăng hoặc giảm vào thời điểm quý khách đăng ký.
– Trong trường hợp quý khách không trực tiếp đến đăng ký vui lòng liên hệ tìm hiểu kỹ thông tin từ người đến đăng ký thế…
– Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp đoàn không đủ khách, công ty có trách nhiệm thông báo cho Quý khách trước ngày khởi hành 04 ngày và sẽ thỏa thuận lại ngày khởi hành khác, hoặc hoàn trả toàn bộ số tiền mà Qúy khách đã thanh toán.
– Các chuyến bay phụ thuộc vào hãng hàng không nên một số trường hợp giờ bay sẽ thay đổi mà không được báo trước. Thứ tự các điểm tham quan trong chương trình có thể thay đổi tùy tình hình thực tế nhưng vẫn bảo đảm tham quan đầy đủ như trong chương trình. Tên khách sạn sẽ được xác nhận chính thức vào ngày họp đoàn, trước ngày khởi hành 01 ngày.
– Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận đầy đủ sức khỏe để đi du lịch nước ngoài của Bác sĩ và phải có người thân dưới 60 tuổi (đầy đủ sức khỏe) đi theo.
– Trẻ em dưới 16 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
– Quý khách có yêu cầu ở phòng đơn, vui lòng thanh toán thêm tiền phụ thu.
– Công ty du lịch không nhận khách có thai từ 30 tuần trở lên tham gia các tour du lịch nước ngoài.
– Quý khách có nhu cầu tách đoàn vui lòng thông báo cho nhân viên khi đăng kí, đóng phí 1.400.000/khách
– Trong trường hợp Quý khách không được xuất cảnh hoặc bị từ chối nhập cảnh tại nước sở tại thì trách nhiệm không thuộc về phía công ty du lịch.
– Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.
Kính chúc Quý khách một chuyến đi bổ ích và thú vị!',
    'https://fiditour.com/wp-content/uploads/2023/11/1-4.png
https://fiditour.com/wp-content/uploads/2023/11/2-7.png
https://fiditour.com/wp-content/uploads/2023/11/3-7.png
https://fiditour.com/wp-content/uploads/2023/11/4-5.png
https://fiditour.com/wp-content/uploads/2023/11/5-1.png',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/malaysia-singapore-5n4d-bay-vietjet/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-8353', 'Du Thuyền - Khám Phá Vẻ Đẹp Mê Hoặc Vùng Địa Trung Hải Cùng Du Thuyền Costa Toscana - Barcelona - Palma De Mallorca - Palermo - Civitavecchia - Savona - Marseille 11N10Đ',
    'TP.HCM', 'Địa Trung Hải', '11N10Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 72 DAY) + INTERVAL 7 HOUR,
    117990000, 88492000, 35, 34, 'https://fiditour.com/wp-content/uploads/2023/12/8.png',
    'VIETNAM – BARCELONA (ĂN TRÊN MÁY BAY) 19h55 Quý khách tập trung tại sân bay quốc tế Tân Sơn Nhất, Trưởng đoàn đón và hỗ trợ đoàn làm thủ tục cho chuyến bay dự kiến đến Sân bay quốc tế Dubai. ☞ Chuyến bay từ TP.HCM 1 EK 393 14DEC SGNDXB…',
    'Ngày 1: (14/12)
VIETNAM – BARCELONA (ĂN TRÊN MÁY BAY)
19h55 Quý khách tập trung tại sân bay quốc tế Tân Sơn Nhất, Trưởng đoàn đón và hỗ trợ đoàn làm thủ tục cho chuyến bay dự kiến đến Sân bay quốc tế Dubai.
☞ Chuyến bay từ TP.HCM
1 EK 393 14DEC SGNDXB 22:55 – 04:25 15DEC
2 EK 185 15DEC DXBBCN 08:15 – 12:50
08h15 Quý khách làm thủ tục nối chuyến đi Barcelona, Tây Ban Nha.
Đoàn dùng bữa và nghỉ ngơi trên máy bay

Ngày 2: (15/12)
BARCELONA ( ĂN SÁNG, TRƯA, TỐI)
12h50 Tới sân bay sân bay quốc tế Barcelona, làm thủ tục nhập cảnh
Xe và HDV đón và đưa quý khách dùng cơm trưa tại nhà hàng địa phương.
14h00 Đoàn khởi hành tham quan Barcelona, là thiên đường của kiến trúc và nghệ thuật, nơi sự sáng tạo không ngừng thổi hồn vào từng góc phố. Thành phố nổi bật với sự hòa quyện hoàn hảo giữa các công trình kiến trúc độc đáo và các biểu hiện nghệ thuật tinh tế.
Sân vận động Camp Nou là sân vận động lớn nhất châu Âu và là niềm tự hào của FC Barcelona. Với sức chứa ấn tượng và không khí sôi động, mệnh danh là thánh đường bóng đá Châu Âu. (chụp ảnh bên ngoài)
Tòa nhà Casa Batlló – là kiệt tác kiến trúc của Antoni Gaudí ở Barcelona, nổi bật với thiết kế uốn lượn và màu sắc rực rỡ. Được gọi là “Ngôi Nhà Xương”, đây là một biểu tượng của sự sáng tạo và nghệ thuật hiện đại., di sản Thế giới UNESCO. (chụp ảnh bên ngoài)
Tòa nhà Casa Mila – hay La Pedrera, là một tuyệt tác của Antoni Gaudí tại Barcelona, nổi bật với vẻ đẹp độc đáo và sáng tạo. Các đường cong mềm mại và thiết kế uyển chuyển của tòa nhà thể hiện sự đổi mới và tinh tế trong kiến trúc hiện đại. Casa Milà không chỉ là một công trình nổi bật mà còn là một tác phẩm nghệ thuật, khẳng định sự sáng tạo và sự kỳ diệu của Gaudí. (chụp ảnh bên ngoài).
18h00 Đoàn dùng bữa tối tại nhà hàng
19h30 Quý khách về khách sạn nhận phòng và nghỉ ngơi.

Ngày 3: (26/05)
BARCELONA – CHECK IN DU THUYỀN ( ĂN SÁNG, TRƯA, TỐI)
07h00 Quý khách dùng bữa sáng tại khách sạn và làm thủ tục trả phòng.
08h00 Xe đón và đưa đoàn đi tham quan:
Nhà thờ Sagrada Familia, xây dựng từ 1882 theo thiết kế của kiến trúc sư Gaudi, nhà kiến trúc đại tài của Barcelona. Tòa nhà là một trong những kiệt tác về kiến trúc nổi tiếng trên thế giới. (Tham quan bên ngoài)
Quảng trường Catalunya, là trái tim nhộn nhịp của Barcelona, nơi kết nối các tuyến đường chính và khu vực thương mại sầm uất. Với không gian rộng lớn và bầu không khí sống động mang đến những trải nghiệm đặc sắc và năng động.
Đại lộ La Ramblas, nơi hội tụ của văn hóa, nghệ thuật và cuộc sống đô thị. Con phố nổi tiếng này cuốn hút với những quầy hàng đa dạng, các quán cà phê quyến rũ, và những màn biểu diễn nghệ thuật đường phố độc đáo.
Tượng đài Columbus, đánh dấu nơi Christopher Columbus trở về và báo cáo với nữ hoàng về chuyến đi khám phá ra châu Mỹ.
12h00 Đoàn dùng cơm trưa tại nhà hàng địa phương.
15h00 Xe đưa đoàn đến cảng, HDV hướng dẫn quý khách làm thủ tục lên du thuyền.
18h30 Du thuyền rời bến, bắt đầu cuộc hành trình trên du thuyền 5 sao COSTA TOSCANA. Quý khách sẽ cảm nhận sự trong trẻo, thanh bình, thơ mộng khi lênh đênh trên đại dương mênh mông rộng lớn và ngắm nhìn phong cảnh tuyệt đẹp.
19h00 Thưởng thức bữa tối và hòa mình vào không gian nhộn nhịp vui tươi trên du thuyền.

Ngày 4: (17/12)
PALMA DE MALLORCA (ĂN BA BỮA)
08h00 Du thuyền cập cảng Palma De Mallorca – hay còn gọi là Majorca, hòn đảo lớn nhất thuộc quần đảo Baleares được xem là điểm du lịch hút khách nhất của Tây Ban Nha. Palma là thủ phủ của Mallorca, một trong những thành phố đẹp nhất Địa Trung Hải Mallorca còn lưu giữ những dấu ấn thiết kế thời Trung Cổ.
Quý khách dùng bữa sáng trên du thuyền, xe và HDV đón đoàn đi tham quan:
Nhà thờ Le Seu: nổi bật với mặt tiền đồ sộ và các cửa sổ kính màu rực rỡ. Xây dựng từ thế kỷ 13, công trình này ấn tượng với không gian rộng lớn, các cột cao vút và chi tiết trang trí tinh xảo. Ánh sáng chiếu qua các cửa sổ kính tạo nên hiệu ứng ánh sáng kỳ diệu, tăng thêm vẻ đẹp huyền bí của nhà thờ.
Tòa nhà thị chính Mallorca: Tọa lạc tại trung tâm thành phố Palma de Mallorca, Tòa Nhà Thị Chính là một công trình kiến trúc đầy ấn tượng và mang đậm dấu ấn lịch sử. Được xây dựng vào thế kỷ 17, tòa nhà nổi bật với mặt tiền phong cách Baroque độc đáo và những chi tiết trang trí tinh xảo.
Phố cổ Palma: Còn được biết đến là “La Ciutat,” là trái tim lịch sử của Palma de Mallorca. Với những con đường lát đá hẹp, những quảng trường xinh đẹp, và các công trình kiến trúc từ thời Trung Cổ và Phục Hưng, phố cổ Palma mang đến cho du khách một hành trình quay ngược thời gian.
Quý khách dùng bữa trưa tại nhà hàng địa phương và tham quan, chụp ảnh gần khu vực bến cảng.
15h00 Quý khách quay về du thuyền
18h00 Đoàn dùng bữa tối và thưởng thức các chương trình giải trí đặc sắc trên du thuyền.
Du thuyền rời thành phố cảng Palma De Mallorca.

Ngày 5: (18/12)
KHÁM PHÁ DU THUYỀN COSTA TOSCANA (ĂN BA BỮA)
08h00 Quý khách dùng bữa sáng và tự do trải nghiệm các dịch vụ trên du thuyền.
Quý khách có thể ngâm mình trong làn nước mát mẻ hoặc tham gia hoạt động thể thao thú vị trên du thuyền. Quý khách khám phá những hoạt động sáng tạo theo lịch trình trên “ ”
Squok Club: là một thiên đường vui chơi tuyệt vời dành cho trẻ em. Được thiết kế đặc biệt để kích thích sự sáng tạo và khám phá, Squok Club cung cấp một loạt các hoạt động giải trí thú vị, từ trò chơi điện tử hấp dẫn đến các buổi học nghệ thuật và thủ công. Với không gian vui nhộn, các khu vực chơi riêng biệt và các hoạt động hàng ngày, Squok Club mang đến cho bé một môi trường an toàn và đầy hứng khởi. Đội ngũ nhân viên nhiệt tình và giàu kinh nghiệm luôn sẵn sàng tạo ra những trải nghiệm tuyệt vời và đáng nhớ.
Công viên nước trên biển: Du thuyền có 4 đường trượt nước theo phong cách đua xe chạy song song với nhau và 4 hồ bơi chính ngoài trời/ trong nhà cùng nhiều bồn tắm nước nóng. Một trong những đặc điểm tuyệt vời nhất của Costa Toscana là không gian boong tàu mở rộng với các ghế tắm nắng được bố trí thoải mái và các ô che nắng rộng rãi, du
khách có thể thoải mái nằm thư giãn, đọc sách hoặc thưởng thức đồ uống giải khát từ quầy bar gần đó.
Solemio Spa & Salon: là một ốc đảo thư giãn tuyệt vời, mang đến cho du khách những trải nghiệm chăm sóc sắc đẹp và sức khỏe đẳng cấp. Tại đây, du khách có thể tận hưởng các liệu trình spa sang trọng như massage thư giãn, liệu pháp chăm sóc da, và các dịch vụ làm đẹp chuyên nghiệp. Với không gian thiết kế tinh tế và yên tĩnh, Solemio Spa & Salon cung cấp một môi trường lý tưởng để thư giãn và tái tạo năng lượng.
Colosseo Theater: Với thiết kế hiện đại và hoành tráng, nhà hát này có sức chứa lớn, cho phép du khách thưởng thức các buổi biểu diễn đẳng cấp từ nhạc kịch, xiếc, đến các buổi trình diễn ca nhạc và khiêu vũ. Sân khấu của Colosseo Theater được trang bị hệ thống âm thanh và ánh sáng tiên tiến, đảm bảo mỗi buổi biểu diễn đều trở thành một sự kiện đáng nhớ. Không gian thoải mái với ghế ngồi rộng rãi và tầm nhìn tốt từ mọi góc độ giúp khán giả có trải nghiệm tối ưu.
Quý khách dùng bữa tối, thưởng thức SHOW BIỂU DIỄN đặc sắc tại nhà hát lớn trên Du Thuyền.

Ngày 6: (19/12)
PALERMO, Ý (ĂN BA BỮA)
08h00 Du thuyền cập cảng Palermo, quý khách dùng bữa sáng trên du thuyền.
Palermo, thành phố quyến rũ của Sicily, nổi bật như một viên ngọc lấp lánh trong lòng Địa Trung Hải. Với sự kết hợp tinh tế giữa vẻ đẹp lịch sử và sự sống động hiện đại, Palermo quyến rũ du khách bằng những con phố rợp bóng cây, những khu chợ đầy màu sắc và các quán cà phê ấm cúng. Mỗi góc phố của thành phố này đều mang đến một câu chuyện, từ di sản văn hóa phong phú đến sự ấm áp của người dân địa phương.
10h00 Xe đón đoàn tham quan:
Viếng thăm Nhà thờ Gesù (Chiesa del Gesù): là một viên ngọc quý của Palermo, nổi bật với vẻ đẹp kiến trúc Baroque và sự lôi cuốn thanh thoát. Xây dựng từ thế kỷ 16, nhà thờ này quyến rũ với các chi tiết điêu khắc tinh xảo và nội thất lộng lẫy, nơi lớp vàng lá lấp lánh và những bức tranh tường sắc nét tạo nên một không gian trang nghiêm và uy nghi.
Nhà thờ Chính tòa Palermo (Cattedrale di Palermo) là một biểu tượng lịch sử và văn hóa quan trọng ở Palermo, Sicily. Được xây dựng vào thế kỷ 12, nhà thờ này được dành tôn vinh Đức Trinh Nữ Maria Thăng Thiên (Santa Vergine Maria Assunta), nhà thờ nằm trong khu vực được UNESCO công nhận là Di sản Thế giới, cụ thể là trong danh sách Di sản Thế giới của “Các Địa điểm Lịch sử của Palermo, Cefalù và Monreale.”
Dạo bộ tham quan quảng trường Baroque tuyệt đẹp Quattro Canti, công trình để đời của kiến trúc sư Giulio Lasso, thiết kế theo đặt hàng của phó vương
Sicily. Gần đó là đài phun nước Fontana Pretoria xinh xắn, ban đầu được xây ở Florence nhưng sau được chuyển về Palermo. Với đài phun nước vĩ đại và những bức tượng tinh xảo, quảng trường tạo nên một không gian ấn tượng và đầy mê hoặc. Kiến trúc Baroque tại đây thể hiện sự hài hòa hoàn hảo giữa sự trang trí cầu kỳ và động lực mạnh mẽ, phản ánh sự lôi cuốn của phong cách này.
12h00 Đoàn trở về dùng bữa trưa tại nhà hàng trên du thuyền.
16h30 Du thuyền rời cảng Palermo
Đoàn dùng bữa tối và thưởng thức các chương trình giải trí đặc sắc trên du thuyền.

Ngày 7: (20/12)
CIVITAVECCHIA / ROME, Ý (ĂN BA BỮA)
08h30 Du thuyền cập cảng Civitavecchia (Rome)
Quý khách dùng bữa sáng trên du thuyền, xe đón đoàn tham quan:
Thánh địa Vatican to lớn và nguy nga nhất thế giới, là quốc gia với diện tích nhỏ nhất thế giới, Vatican là nơi duy nhất toàn bộ quốc gia được UNESCO công nhận là di sản văn hóa thế giới, mỗi năm Vatican đón hàng triệu du khách và người hành hương.
12h00 Đoàn dùng bữa trưa tại nhà hàng địa phương.
Tiếp tục tham quan:
Quảng trường Tây Ban Nha, nơi mà người dân thành Rome rất yêu thích vì nó cung cấp một không gian đẹp, thư thái. Có lẽ vì thế mà nơi này đã thu hút rất nhiều nhiếp ảnh gia tới để sáng tác.
Đài phun nước Trevi Fountain, đáy hồ trong veo lấp lánh những đồng tiền xu được du khách quay lưng ném xuống với ước mong sẽ quay lại Rome.
Đấu Trường La Mã Colosseum, nơi diễn ra những cuộc giác đấu giữa tù nhân La Mã với thú dữ dưới sự chứng kiến của công chúng và Hoàng đế La Mã (Chụp hình bên ngoài)
17h00 Xe đưa đoàn đến cảng, quý khách trở lại du thuyền.
19h00 Du thuyền rời cảng Rome
Đoàn dùng bữa tối và thưởng thức các chương trình giải trí đặc sắc trên du thuyền.

Ngày 8: (21/12)
SAVONA, Ý (ĂN BA BỮA)
08h00 Du thuyền cập cảng Savona, quý khách dùng bữa sáng trên du thuyền.
10h00 Xe đón đoàn tham quan:
Pháo đài Priamar: nằm trên Corso Giuseppe Mazzini – Pháo đài Priamar là một biểu tượng lịch sử và kiến trúc nổi bật của Savona. Được xây dựng vào thế kỷ 16, pháo đài này từng là một pháo đài quân sự quan trọng và nay là một di tích lịch sử thu hút du khách từ khắp nơi. Kiến trúc ấn tượng với các bức tường kiên cố và lối đi rộng rãi, pháo đài Priamar không chỉ mang giá trị lịch sử mà còn cung cấp tầm nhìn toàn cảnh tuyệt đẹp ra biển và thành phố Savona.
La Torretta: là một ngọn tháp hải đăng cổ kính và biểu tượng nổi bật của Savona. Được xây dựng vào thế kỷ 14, tháp này mang tên nhà thám hiểm nổi tiếng Leon Pancaldo, người đồng hành cùng Magellan trong cuộc hành trình vòng quanh thế giới đầu tiên. Piazza Leon Pancaldo, khu vực xung quanh tháp, là một quảng trường nhộn nhịp với các quán cà phê và cửa hàng, nơi du khách có thể thư giãn và tận hưởng không khí địa phương.
12h00 Quý khách dùng bữa trưa tại nhà hàng địa phương và tiếp tục tham quan:
Cappella Sistina, Piazza del Duomo – là một kỳ quan nghệ thuật không thể bỏ qua ở Savona. Được xây dựng vào thế kỷ 16, nhà nguyện này mê hoặc du khách với thiết kế tinh tế và các tác phẩm nghệ thuật phong phú. Bức tranh và điêu khắc bên trong thể hiện vẻ đẹp của phong cách Phục hưng và Baroque, tạo nên một không gian trang nghiêm và quyến rũ.
Đài Tưởng Niệm Chiến Tranh: là một công trình trang nghiêm và đầy ý nghĩa, vinh danh những người đã hy sinh trong các cuộc chiến tranh. Với kiến trúc trang nhã và các chi tiết chạm khắc tinh xảo, đài tưởng niệm không chỉ là một biểu tượng của lòng dũng cảm mà còn là một không gian thiêng liêng để tưởng nhớ và tri ân những anh hùng đã ngã xuống.
15h30 Xe đưa đoàn về cảng
17h30 Du thuyền rời cảng Savona
Đoàn dùng bữa tối và thưởng thức các chương trình giải trí đặc sắc trên du thuyền.

Ngày 9: (22/12)
MARSEILLE (ĂN BA BỮA)
07h00 Quý khách ăn sáng trên du thuyền.
09h00 Thuyền cập bến Marseille, thành phố cổ nhất nước Pháp và châu Âu, xe đón đoàn tham quan:
Cung điện Palais Longchamps, một công trình đặc sắc dưới thời Đệ Nhị Đế Chế với hàng cột hùng vĩ tạo thành vòng bán nguyệt quanh một đài nước đồ sộ.
(chụp ảnh bên ngoài)
Nhà thờ Notre Dame de la Garde– một trong những biểu tượng của Marseille được xây dựng từ
năm 1218, tại đây có thể nhìn toàn cảnh thành phố Marseille. (Nghe giới thiệu về nhà thờ)
Dạo Vallon des Auffes, bến cảng nhỏ bên bờ biển Marseille, nơi neo đậu của nhiều thuyền cá truyền thống, phố bán đồ lưu niệm, phố mua sắm La Canebière.
12h00 Đoàn trở về dùng bữa trưa tại nhà hàng trên du thuyền.
18h00 Du thuyền rời cảng Marseille
Nghỉ đêm trên du thuyền.

Ngày 10: (23/12)
BARCELONA – VIỆT NAM ( ĂN SÁNG )
08h30 Du thuyền cập cảng Barcelona. Đoàn dùng bữa sáng và làm thủ tục trả phòng rời du thuyền.
Đoàn đi mua sắm tại Barcelona và tự do ăn trưa tại Chợ Boqueria, tọa lạc trên đại lộ La Rambla, là điểm đến ẩm thực không thể bỏ qua ở Barcelona. Bước vào chợ, cảm nhận ngay sự nhộn nhịp với các quầy hàng đầy ắp trái cây tươi ngon, thịt heo muối jamón ibérico và xúc xích chorizo.
13h00 Sau bữa trưa, xe đón đoàn đi tham quan:
Cung Điện Âm Nhạc Catalan (Palau de la Música Catalana), nằm trên đại lộ Sant Pere ở Barcelona, nổi bật với kiến trúc Modernisme Catalan lộng lẫy. Mặt tiền của tòa nhà gây ấn tượng với các cột gạch trang trí rực rỡ, hoa văn tinh xảo và mái vòm bằng gạch đỏ. Những chi tiết chạm khắc tỉ mỉ và các yếu tố nghệ thuật kết hợp hài hòa tạo nên một biểu tượng văn hóa độc đáo, phản ánh tài năng sáng tạo của kiến trúc sư Lluís Domènech i Montaner.
Công Viên Güell: Một kiệt tác của Antoni Gaudí, nổi bật trên đỉnh đồi Barcelona với vẻ đẹp huyền bí và mê hoặc. Những con đường uốn lượn và khu vườn xanh mướt dẫn lối đến những công trình trang trí đầy màu sắc, nơi kiến trúc và nghệ thuật hòa quyện một cách hoàn hảo. Đài quan sát trên cao mở ra tầm nhìn, nơi thành phố và biển cả hòa quyện trong một bức tranh rộng lớn. Quảng trường ngoài trời với không khí trong lành mời gọi sự tĩnh lặng và chiêm nghiệm.
17h00 Đoàn di chuyển ra sân bay, làm thủ tục xuất cảnh bay về Việt Nam.
☞ Chuyến bay về TP.HCM
1 EK 188 23DEC BCNDXB 20:25 – 05 55 24DEC
2 EK 392 24DEC DXBSGN 09:35 – 19:35
05h55 Đoàn quá cảnh tại Thổ Nhĩ Kỳ.

Ngày 11: (24/12)
VIỆT NAM
09h35 Đoàn tiếp tục chuyến bay về Việt Nam, quý khách nghỉ ngơi trên máy bay.
19h35 Về đến Việt Nam, hướng dẫn viên chia tay đoàn, kết thúc chương trình du lịch.
Chia tay Quý khách. Hẹn gặp lại quý khách!
*Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.',
    'Giá tour bao gồm
Vé máy bay khứ hồi từ Tp. Hồ Chí Minh đến Châu Âu đã bao gồm các loại thuế, lệ phí sân bay và 30kg hành lý ký gửi, 8kg hành lý xách tay; hãng hàng không Emirates Airlines
Phí visa nhập cảnh Châu Âu
01 đêm khách sạn 4 sao tại Barcelona
07 đêm trên du thuyền
Bồi dưỡng nhân viên phục vụ trên du thuyền.
Tận hưởng các dịch vụ vui chơi giải trí và ẩm thực trên du thuyền COSTA TOSCANA.
Các điểm tham quan bên ngoài.
Các bữa ăn trên du thuyền và trên bờ khi đi tham quan theo chương trình.
Xe đưa đón tham quan trên bờ khi Du thuyền cập cảng tại các điểm đến.
Nước uống trên xe 01 chai nước/khách/ngày khi đi tham quan.
Bảo hiểm du lịch toàn cầu
Quà tặng của công ty
Trường đoàn từ Việt Nam theo đoàn suốt tuyến thân thiện, chuyên nghiệp

Giá tour không bao gồm
Chi phí cá nhân: điện thoại, ăn uống, vận chuyển ngoài chương trình.
Visa nhập cảnh lại Việt Nam đối với quý khách thuộc các quốc tịch nước ngoài phải cần visa nhập cảnh Việt Nam
Bồi dưỡng cho hướng dẫn viên từ Việt Nam, hướng dẫn viên địa phương và lái xe 7 EURO/ngày tour.

Những lưu ý khác
Chương trình có thể thay đổi phụ thuộc vào tình hình thực tế nhưng vẫn đảm bảo đủ các điểm tham quan đã đề cập. Trong trường hợp đoàn khởi hành đúng vào ngày có hội chợ thương mại tại các thành phố lớn, khách sạn nghỉ đêm sẽ được thay đổi sang thành phố khác để đảm bảo giá công bố được bảo lưu.
Quý khách có kế hoạch thăm thân trong chương trình cần thông báo với công ty du lịch để khớp lịch trình cuối cùng trước khi đặt vé máy bay hoặc bất kỳ loại hình dịch vụ nào.
Trẻ em dưới 18 tuổi tham gia tour nhưng không có cha mẹ đi cùng thì phải có giấy uỷ quyền của cha và mẹ.
Việc nhập cảnh vào bất kỳ đất nước nào là do sự chấp thuận của nước sở tại.
Quý khách mang 2 quốc tịch hoặc travel document (chưa nhập quốc tịch) vui lòng thông báo với nhân viên tư vấn ngay thời điểm đăng ký tour và nộp bản gốc kèm các giấy tờ có liên quan.
Quý khách từ 75 tuổi trở lên cần có giấy xác nhận sức khoẻ của bác sĩ để đi du lịch nước ngoài và giấy cam kết sức khỏe với Công ty. Yêu cầu phải có người thân đi cùng.
Quý khách mang thai xin vui lòng báo cho nhân viên bán tour ngay tại thời điểm đăng ký để được tư vấn thêm thông tin. Vì an toàn cho Quý khách, quý khách không nên tham dự tour khi thai kỳ dưới 3 tháng và trên 6 tháng
Do tính chất tour ghép đoàn, nếu trước ngày khởi hành 5 ngày mà Công Ty không gom đủ 10 khách hoặc số khách được cấp visa trước khởi hành 5 ngày không đảm bảo tối thiểu 10 khách thì
Công Ty có quyền huỷ đợt khởi hành đồng và cùng khách hàng sắp xếp chọn ngày đi mới căn cứ theo kết quả visa được cấp. Trong trường hợp 2 bên không thể thống nhất phương án mới và Khách hàng không đồng ý với phương án thay đổi chương trình hay dời ngày khởi hành thì Công ty Du lịch phải hoàn lại giá trị tour sau khi trừ phí xin visa (nếu có)

Điều kiện hoàn/hủy tour
Trong trường hợp không thể tham dự được tour, quý khách vui lòng thông báo cho Công ty và chịu phí huỷ như sau:
Sau khi đăng ký TOUR, phí cọc sẽ không được hoàn lại.
Trước ngày TOUR khởi hành dưới 60 ngày, chi phí không được hoàn lại 50% giá TOUR.
Trước ngày TOUR khởi hành dưới 30 ngày, chi phí không hoàn lại 75% giá TOUR.
Trước ngày khởi hành dưới 15 ngày, chi phí không hoàn lại 100% giá TOUR.
(Thời gian hủy tour được tính trong ngày làm việc, không tính Thứ Bảy, Chủ Nhật và các ngày nghỉ Lễ)
Việc hủy bỏ tour với công ty phải được thông báo trực tiếp qua email, tin nhắn điện thoại và phải được công ty du lịch xác nhận. Việc hủy bỏ qua điện thoại không được chấp thuận.
Khách bị từ chối xuất cảnh tại Việt Nam hoặc nhập cảnh tại nơi đến: Khách chịu 100% tổng chi phí tour (không được hoàn tiền).
Trường hợp đến ngày khởi hành mà khách vẫn chưa ra kịp kết quả visa, quý khách có thể chọn ngày khởi hành tour kế tiếp hoặc nhận lại tiền tour đã đóng sau khi trừ đi chi phí visa
Đối với trường hợp quý khách đặt tour đi cùng nhóm bạn hoặc gia đình (từ 2 khách trở lên), nếu một người trong nhóm không đạt visa mà huỷ tour thì khách rớt visa chịu phí visa và vé máy bay nếu đã xuất vé, nhưng các thành viên khác đã đạt visa mà huỷ tour sẽ áp dụng theo chính sách hủy tour chung.
Chương trình tour theo giá ưu đãi, không áp dụng cho chuyển đổi hoặc dời ngày tour

Lưu ý
Quý khách vui lòng xem kỹ chương trình, giá tour, phần bao gồm và không bao gồm được liệt kê chi tiết trong chương trình.
Tùy theo điều kiện thực tế mà chương trình tham quan có thể thay đổi hành trình lên xuống cho phù hợp tuy nhiên các tuyến điểm Du Lịch vẫn đảm bảo đầy đủ.
Các chuyến bay có thể thay đổi vào giờ chót tùy thuộc vào các hãng hàng không, thời tiết…
Trường hợp Quý khách không được xuất cảnh và nhập cảnh vì lý do cá nhân, CTY được miễn trừ trách nhiệm và sẽ không hoàn trả tiền tour.
Hồ sơ xin visa sau khi nộp vào Lãnh Sự Quán sẽ không được hoàn trả lại.
Theo quy định mới của Lãnh Sự, sau khi được cấp visa vì bất kỳ lý do nào mà quý khách không tham gia theo đoàn cùng Công ty, Công ty có trách nhiệm báo hủy visa đã được cấp của quý khách với Lãnh Sự.
Quý khách vui lòng không tách đoàn và đi theo đúng chương trình. Nếu có nhu cầu tách đoàn vui lòng thông báo cho nhân viên tư vấn ngay khi đăng ký tour để được tư vấn thêm thông tin và các chi phí phát sinh (nếu có).
Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận đầy đủ sức khỏe để đi du lịch nước ngoài của Bác sĩ và phải có người thân dưới 60 tuổi (đầy đủ sức khỏe) đi theo. Ngoài ra quý khách từ 70 tuổi trở lên vui lòng mua thêm phí bảo hiểm cao cấp (phí thay đổi tùy theo tour).
Quý khách là người nước ngoài hoặc là Việt Kiều, vui lòng THÔNG BÁO VỚI NHÂN VIÊN ĐỂ NHẬN TƯ VẤN và mang theo đầy đủ tất cả hộ chiếu (mang theo cả 02 hộ chiếu trường hợp có 02 quốc tịch), và visa Việt Nam (dán vào hộ chiếu hoặc tờ rời) khi đi tour.
Quý khách chỉ mang thẻ xanh (thẻ tạm trú tại nước ngoài) và không còn hộ chiếu VN còn hiệu lực thì không đăng ký tham quan du lịch sang nước thứ ba được.
Trẻ em từ 2 tuổi đến dưới 14 tuổi phải có Giấy khai sinh khi đi với bố mẹ hoặc Giấy khai sinh + Giấy ủy quyền khi đi với người trưởng thành (từ 18 tuổi trở lên) nếu không phải là bố mẹ.
Việc nhập cảnh vào bất kỳ đất nước nào là do sự chấp thuận của nước sở tại, Công Ty không chịu trách nhiệm nếu Quý khách bị từ chối nhập cảnh.

Miễn trừ trách nhiệm
Trong những trường hợp bất khả kháng như: đình công, khủng bố, bệnh dịch, thiên tai. Hoặc do sự cố có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như: máy bay, tàu hỏa… Công ty sẽ giữ quyền thay đổi lộ trình hoặc hủy bỏ chuyến đi du lịch vì sự an toàn cho Quý khách. Công Ty sẽ được miễn trừ trách nhiệm bồi thường những thiệt hại phát sinh (nếu có).',
    'https://fiditour.com/wp-content/uploads/2023/12/Sagrada-Familia.jpg
https://fiditour.com/wp-content/uploads/2023/12/6fd545bbf3a24e33b05f7c7a4ddfa08d.jpg
https://fiditour.com/wp-content/uploads/2023/12/C429_Squok_563x396.jpg.image_.554.312.low_.webp
https://fiditour.com/wp-content/uploads/2023/12/istockphoto-615075296-170667a.jpg',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/du-thuyen-kham-pha-dia-cuc-alaska-12n11d/

INSERT INTO tours (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date, adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, notes, gallery_urls, status, region)
VALUES (
    (SELECT id FROM categories WHERE name = 'Tour quốc tế' LIMIT 1), 'FDT-8342', 'Campuchia - Angkor Wat Huyền Bí 4N3Đ',
    'TP.HCM', 'Campuchia', '4N3Đ', 'Máy bay',
    DATE_ADD(CURDATE(), INTERVAL 75 DAY) + INTERVAL 7 HOUR,
    5490000, 4118000, 30, 22, 'https://fiditour.com/wp-content/uploads/2023/12/5.png',
    'Hướng dẫn viên đón khách tại điểm hẹn khởi hành đi Cambodia. Ăn sáng tại Trảng Bàng với đặc sản bánh canh nổi tiếng. Qua cửa khẩu biên giới Việt Nam – Cambodia làm thủ tục nhập cảnh 9h00: Sau đó tiếp tục men theo quốc lộ 8 qua tỉnh Prey…',
    'Ngày 1: TP.HCM  SIÊM RIỆP
Sáng: Hướng dẫn viên đón khách tại điểm hẹn khởi hành đi Cambodia. Ăn sáng tại Trảng Bàng với đặc sản bánh canh nổi tiếng. Qua cửa khẩu biên giới Việt Nam – Cambodia làm thủ tục nhập cảnh 9h00: Sau đó tiếp tục men theo quốc lộ 8 qua tỉnh Prey Veng. Đến tỉnh Kompong Cham qua cầu Japanese – Cambodia bắc ngang sông Tonle Bat. Dùng cơm trưa tại nhà hàng địa phương sau đó tiếp tục khởi hành đi Siem Riep
Chiều: Về khách sạn nhận phòng nghỉ ngơi. Dùng cơm tối ở nhà hàng tại Siem Riep

Ngày 2: SIÊM RIỆP
Sáng: Ăn sáng buffet tại khách sạn. Sau đó xe đưa đoàn đi tham quan cổng nam Angkor Thom, một ngôi đền cổ rộng lớn với những điêu khắc và hoa văn độc đáo trên từng cm2 gắn liền với sự tích văn hoá và phát triển của dân tộc Khmer. Đền Bayon 4 mặt với nụ cười bí ẩn, Quảng Trường Đấu Voi, cung điện của Đức Vua từ thế kỉ thứ 12….
Ta Pruhm – một phế tích kinh thành Khmer cổ với những cây đại thụ hình thù kì quái là nơi được Hollywood chọn làm phim trường khởi quay bộ phim Bí Mật Ngôi Mộ Cổ, và một số đền đài khác trong khu vực… Mua quà lưu niệm mang dấu ấn đặc trưng Angkor.
Trưa: Dùng cơm trưa và nghỉ ngơi.
Chiều: Tiếp tục tham quan:
Đền Angkor Wat, một trong những kì quan của thế giới.
Tiếp tục về trung tâm thành phố siemreap tham quan Quãng Trường Hoàng Cung tại Siemreap, thắp hương cầu xin những điều tốt đẹp nhất tại ngôi miếu linh thiên nhất, ngắm nhìn đàn dơi quạ trên những cây cổ thụ.
19:00: Ăn tối tại nhà hàng xem múa vũ điệu hoàng gia Apsara show

Ngày 3: SIÊM RIỆP  PHNOM PÊNH
Sáng: Ăn sáng tại nhà hàng, sau đó khởi hành về Phnom Penh. Trên đường đoàn dừng tại chợ Côn trùng, thưởng thức nhện, dán, châu chấu..chiên, nướng, ngâm rượu. tới thủ đô dùng cơm trưa với nhà hàng lẩu băng chuyền SOU SOU .Tham quan:
Hoàng Cung nơi ở của hoàng gia đương đại
Chùa Vàng chùa Bạc rực rỡ với Ngọc Lục Bảo nổi tiếng của Cambodia và Thái Lan( tham quan chùa núi wat phnum nếu cung điện đóng cửa).
Đài tưởng niệm Việt Nam – Cambodia. Về khách sạn nhận phòng nghĩ ngơi .
Sau đó đi tham quan và thử vận may tại sòng bài Nagar Resort đẹp và sang trọng nhất Cambodia.
Về khách sạn nghỉ ngơi, tự do khám phá phnompenh về đêm

Ngày 4: PHNOM PENH  TP.HCM
Sáng: Ăn sáng tại khách sạn, làm thủ tục trả phòng. Sau đó, tham quan và chụp ảnh
Đài độc lập Campuchia sau khi được Pháp trả tự do
Tham quan trung tâm đá phong thủy Campuchia.
Trưa: Dùng cơm trưa .sau đó đoàn khởi hành về Việt Nam. Đến cửa khẩu , HDV sẽ giúp khách làm thủ tục về lại Việt Nam. Khởi hành về lại Tp. Hồ Chí Minh.
Chiều: Đưa khách về điểm khởi hành ban đầu. Kết thúc tour, chia tay và hẹn gặp lại quý khách.
Chia tay Quý khách. Hẹn gặp lại quý khách!
Lưu ý: Các điểm tham quan trong chương trình sẽ linh động sao cho phù hợp với tình hình thực tế.
Chia tay Quý khách. Hẹn gặp lại quý khách!',
    'Giá tour bao gồm
Chi Phí xuất nhập cảnh Cam
Khách sạn 4 – 3 sao: Tiêu chuẩn 2 – 3 khách /phòng
Ăn uống theo chương trình: các buổi sáng dùng Buffet tại khách sạn.
Xe đời mới, máy lạnh đưa đón theo chương trình.
Hướng dẫn viên tiếng việt phục vụ suốt chương trình.
Phí tham quan theo chương trình.
Ăn Sáng tại VN
Chi phí thủ tục cửa khẩu Việt – Cam
Quà tặng: nón du lịch.
Nước uống : số lượng 01/khách/ngày.
Quý khách được hưởng chế độ Bảo Hiểm Du Lịch với mức 10.000 usd/khách

Giá tour không bao gồm
Các chi phí cá nhân: ăn uống ngoài chương trình, điện thoại, giặt ủi…
Visa Campuchia cho khách có hộ chiếu nước ngoài, kể cả Việt Kiều, phí 35$
Visa tái nhập Việt Nam cho khách có hộ chiếu nước ngoài, kể cả Việt Kiều (những khch có visa 1 lần), phí 85$/khách.
Tiền tip cho hướng dẫn viên và tài xế địa phương: 3 USD/khách/ngày.

Huỷ tour
Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 07 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 20 ngày phí phạt = 50% tổng giá tour chương trình (Tính theo ngày làm việc).
Hủy tour trước 15 ngày phí phạt = 75% tổng giá tour chương trình (Tính theo ngày làm việc).
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình (Tính theo ngày làm việc).
Đối với tour Lễ/ Tết: Ngay sau khi đăng kí tour, cọc 50% tổng giá tour, Phần còn lại Vui lòng thanh toán trước 15 ngày khởi hành.
Hủy tour sau khi đăng ký phí phạt 50% tiền cọc.
Hủy tour trước 45 ngày phí phạt = 50% tổng giá tour chương trình. (Tính theo ngày làm việc)
Hủy tour trước 30 ngày phí phạt = 75% tổng giá tour chương trình. (Tính theo ngày làm việc)
Sau thời gian trên phí phạt = 100% tổng giá trị chương trình. (Tính theo ngày làm việc)
Việc huỷ bỏ chuyến đi phải được thông báo trực tiếp với Công ty bằng văn bản hoặc qua email, tin nhắn điện thoại và phải được Công ty xác nhận. Việc huỷ bỏ bằng điện thoại không được chấp nhận.

Lưu ý
– Trước khi đăng ký tour xin quý khách vui lòng đọc kỹ chương trình tour, giá tour, các khoản bao gồm và không bao gồm trong chương trình và đặt cọc 50% tổng số tiền tour ngay khi đăng kí tour.
– Giá tour không áp dụng vào các dịp Lễ, Tết của Việt Nam & Singapore.
– Giá thuế hàng không là giá tạm tính , giá có thể tăng hoặc giảm vào thời điểm quý khách đăng ký.
– Trong trường hợp quý khách không trực tiếp đến đăng ký vui lòng liên hệ tìm hiểu kỹ thông tin từ người đến đăng ký thế…
– Do tính chất là đoàn ghép khách lẻ, công ty sẽ nhận đủ số lượng khách tối thiểu 10 khách người lớn và đảm bảo đoàn sẽ khởi hành đúng lịch trình. Trong trường hợp đoàn không đủ khách, công ty có trách nhiệm thông báo cho Quý khách trước ngày khởi hành 04 ngày và sẽ thỏa thuận lại ngày khởi hành khác, hoặc hoàn trả toàn bộ số tiền mà Qúy khách đã thanh toán.
– Các chuyến bay phụ thuộc vào hãng hàng không nên một số trường hợp giờ bay sẽ thay đổi mà không được báo trước. Thứ tự các điểm tham quan trong chương trình có thể thay đổi tùy tình hình thực tế nhưng vẫn bảo đảm tham quan đầy đủ như trong chương trình. Tên khách sạn sẽ được xác nhận chính thức vào ngày họp đoàn, trước ngày khởi hành 01 ngày.
– Quý khách từ 70 tuổi trở lên yêu cầu phải có giấy xác nhận đầy đủ sức khỏe để đi du lịch nước ngoài của Bác sĩ và phải có người thân dưới 60 tuổi (đầy đủ sức khỏe) đi theo.
– Trẻ em dưới 16 tuổi phải có bố mẹ đi cùng hoặc người được uỷ quyền phải có giấy uỷ quyền từ bố mẹ.
– Quý khách có yêu cầu ở phòng đơn, vui lòng thanh toán thêm tiền phụ thu.
– Công ty du lịch không nhận khách có thai từ 30 tuần trở lên tham gia các tour du lịch nước ngoài.
– Quý khách có nhu cầu tách đoàn vui lòng thông báo cho nhân viên khi đăng kí, đóng phí 1.400.000/khách
– Trong trường hợp Quý khách không được xuất cảnh hoặc bị từ chối nhập cảnh tại nước sở tại thì trách nhiệm không thuộc về phía công ty du lịch.
– Trong những trường hợp khách quan như : khủng bố, thiên tai…hoặc do có sự cố, có sự thay đổi lịch trình của các phương tiện vận chuyển công cộng như : máy bay, tàu hỏa…thì Công Ty sẽ giữ quyền thay đổi lộ trình bất cứ lúc nào vì sự thuận tiện, an toàn cho khách hàng và sẽ không chịu trách nhiệm bồi thường những thiệt hại phát sinh.
Kính chúc Quý khách một chuyến đi bổ ích và thú vị!',
    'https://fiditour.com/wp-content/uploads/2023/12/1.png
https://fiditour.com/wp-content/uploads/2023/12/2.png',
    'ACTIVE', 'INTERNATIONAL')
ON DUPLICATE KEY UPDATE name = VALUES(name), departure_location = VALUES(departure_location), destination = VALUES(destination), duration = VALUES(duration), transport = VALUES(transport), adult_price = VALUES(adult_price), image_url = VALUES(image_url), short_description = VALUES(short_description), itinerary = VALUES(itinerary), notes = VALUES(notes), gallery_urls = VALUES(gallery_urls), region = VALUES(region);
-- nguồn: https://fiditour.com/campuchia-angkor-wat-huyen-bi-4n3d/
