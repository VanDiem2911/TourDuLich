-- =====================================================================
-- Dữ liệu mẫu cho website đặt tour du lịch (Nhóm 22 - DHKTPM19B)
-- Gồm 5 danh mục và 36 tour (trong nước, quốc tế, biển đảo, trekking, văn hóa).
-- Giá, hành trình, phương tiện được tham khảo từ các trang của công ty lữ hành
-- (iVIVU, Vietnambooking...) rồi viết lại theo cách diễn đạt riêng, chỉ mang tính minh họa.
-- Ngày khởi hành tính theo CURDATE() nên luôn nằm trong tương lai.
-- Ảnh nằm ở frontend/public/img/tours/<mã tour viết thường>.jpg (xem img/CREDITS.md).
-- Tài khoản Admin do backend tự tạo ở lần chạy đầu. File được backend nạp tự động khi bảng categories còn trống.
-- Chạy tay sau schema.sql:  mariadb -u root -p tourdulich < database/seed.sql
-- =====================================================================
USE tourdulich;

INSERT INTO categories (name, description, status) VALUES
    ('Tour trong nước', 'Khám phá các điểm đến đẹp khắp ba miền Bắc - Trung - Nam với lịch trình trọn gói.', 'ACTIVE'),
    ('Tour quốc tế', 'Hành trình đến Đông Nam Á, Đông Á và nhiều quốc gia khác, có hướng dẫn viên tiếng Việt.', 'ACTIVE'),
    ('Nghỉ dưỡng biển đảo', 'Nghỉ dưỡng thư giãn tại các bãi biển và hòn đảo nổi tiếng trong nước.', 'ACTIVE'),
    ('Khám phá & Trekking', 'Hành trình vùng cao, đi bộ đường dài và trải nghiệm thiên nhiên nguyên sơ.', 'ACTIVE'),
    ('Văn hóa - Lịch sử', 'Tìm hiểu di sản, di tích lịch sử, làng nghề và văn hóa địa phương.', 'ACTIVE');

INSERT INTO tours
    (category_id, tour_code, name, departure_location, destination, duration, transport, departure_date,
     adult_price, child_price, total_seats, available_seats, image_url, short_description, itinerary, status)
VALUES
    (1, 'TOUR-HL-001', 'Du thuyền Vịnh Hạ Long - Lan Hạ 3N2Đ', 'Hà Nội', 'Hạ Long', '3N2Đ', 'Xe limousine + Du thuyền',
     DATE_ADD(CURDATE(), INTERVAL 12 DAY) + INTERVAL 7 HOUR,
     5490000, 3990000, 30, 22, '/img/tours/tour-hl-001.jpg',
     'Một đêm ngủ trên du thuyền giữa vịnh, chèo kayak ở Lan Hạ, ghé hang Sửng Sốt và đảo Ti Tốp, đêm còn lại nghỉ khách sạn 4 sao ở Bãi Cháy.',
     'Ngày 1: Hà Nội - Hạ Long - Lên du thuyền
Xe đón khách tại Phố cổ lúc 7h30 và đi theo cao tốc Hà Nội - Hải Phòng - Hạ Long, khoảng hai tiếng rưỡi. Đoàn lên du thuyền ở bến Tuần Châu, dùng bữa trưa hải sản rồi tham quan hang Sửng Sốt, đảo Ti Tốp để leo bậc thang ngắm toàn cảnh vịnh. Chiều chèo kayak quanh các đảo đá vôi, tối ăn tối trên tàu, câu mực và ngủ đêm trên vịnh.

Ngày 2: Lan Hạ - Làng chài - Bãi Cháy
Sáng sớm có lớp Thái Cực Quyền trên boong và bữa sáng nhẹ trước khi tàu đi qua vùng vịnh Lan Hạ yên tĩnh. Đoàn đi thuyền nan thăm làng chài Cửa Vạn, ăn trưa trên tàu rồi trả phòng, cập bến lúc đầu giờ chiều. Buổi chiều nhận phòng khách sạn 4 sao ở Bãi Cháy, tối tự do dạo chợ đêm hoặc ngắm vịnh từ cầu Bãi Cháy.

Ngày 3: Hạ Long - Hà Nội
Sau bữa sáng, đoàn có thời gian đi dạo bãi biển Bãi Cháy hoặc ghé chợ Hạ Long mua mực khô, chả mực làm quà. Bữa trưa dùng tại nhà hàng địa phương trước khi lên xe về Hà Nội. Dự kiến về tới điểm đón ban đầu vào khoảng 17h.', 'ACTIVE'),
    (1, 'TOUR-SP-001', 'Hà Nội - Sa Pa - Bản Cát Cát - Fansipan 3N2Đ', 'Hà Nội', 'Sa Pa', '3N2Đ', 'Xe giường nằm',
     DATE_ADD(CURDATE(), INTERVAL 8 DAY) + INTERVAL 21 HOUR,
     4590000, 3290000, 35, 29, '/img/tours/tour-sp-001.jpg',
     'Đi xe giường nằm lên Sa Pa, thăm bản Cát Cát, thung lũng Mường Hoa và lên đỉnh Fansipan bằng cáp treo, nghỉ khách sạn 3 sao trung tâm thị trấn.',
     'Ngày 1: Hà Nội - Lào Cai - Sa Pa
Xe khởi hành từ Hà Nội lúc 21h30 theo cao tốc Nội Bài - Lào Cai và đoàn ngủ trên xe giường nằm. Sáng hôm sau đến Sa Pa, ăn sáng rồi nhận phòng gửi hành lý. Buổi sáng đi xuống bản Cát Cát của người H''Mông, xem thác Tiên Sa và chợ thủ công nhỏ.

Ngày 2: Fansipan - Thung lũng Mường Hoa
Sáng dậy sớm để đi cáp treo lên đỉnh Fansipan, nơi được gọi là nóc nhà Đông Dương, cao 3.143 m. Phần còn lại của buổi sáng dành để leo thêm các bậc đá lên cột mốc và tham quan khu tâm linh trên đỉnh. Chiều đoàn đi tàu hỏa leo núi Mường Hoa dọc thung lũng ruộng bậc thang, tối tự do ăn thắng cố hoặc lẩu cá hồi.

Ngày 3: Sa Pa - Hà Nội
Sau bữa sáng, đoàn ghé nhà thờ đá Sa Pa và chợ trung tâm để mua măng, thảo quả, hạt dẻ. Xe rời Sa Pa vào khoảng 10h30, dừng ăn trưa ở Lào Cai và về Hà Nội lúc chiều tối.', 'ACTIVE'),
    (1, 'TOUR-NB-001', 'Ninh Bình - Tràng An - Hang Múa - Bái Đính 2N1Đ', 'Hà Nội', 'Ninh Bình', '2N1Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 6 DAY) + INTERVAL 7 HOUR,
     2590000, 1890000, 40, 34, '/img/tours/tour-nb-001.jpg',
     'Ngồi thuyền xuyên hang Tràng An, leo 500 bậc lên đỉnh Lèn ở Hang Múa, thăm cố đô Hoa Lư và chùa Bái Đính, nghỉ khách sạn 3 sao tại thành phố Ninh Bình.',
     'Ngày 1: Hà Nội - Bái Đính - Tràng An
Xe rời Hà Nội lúc 7h, đến Ninh Bình sau khoảng hai tiếng và đi thẳng tới quần thể chùa Bái Đính với tượng Phật Di Lặc và hành lang La Hán dài. Trưa dùng cơm với dê núi, cơm cháy. Chiều đoàn đi thuyền khoảng ba tiếng qua các hang xuyên thủy của Tràng An, ghé đền Trình và phim trường đảo Kong cũ.

Ngày 2: Hang Múa - Hoa Lư - Hà Nội
Sáng đoàn leo gần 500 bậc đá lên đỉnh núi Ngọa Long ở Hang Múa để nhìn xuống cánh đồng Tam Cốc và dòng sông Ngô Đồng uốn lượn. Sau bữa trưa, xe đi đền vua Đinh và vua Lê ở cố đô Hoa Lư, nơi có kiến trúc đình đá cổ. Đoàn về Hà Nội vào buổi tối.', 'ACTIVE'),
    (1, 'TOUR-DN-001', 'Đà Nẵng - Hội An - Bà Nà Hills 4N3Đ', 'TP.HCM', 'Đà Nẵng', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 21 DAY) + INTERVAL 7 HOUR,
     6990000, 5090000, 36, 28, '/img/tours/tour-dn-001.jpg',
     'Bay thẳng Đà Nẵng, lên Cầu Vàng ở Bà Nà Hills, thăm bán đảo Sơn Trà, phố cổ Hội An và ngồi thuyền thúng ở rừng dừa Bảy Mẫu, nghỉ khách sạn 4 sao gần biển Mỹ Khê.',
     'Ngày 1: TP.HCM - Đà Nẵng - Sơn Trà
Chuyến bay buổi sáng đưa đoàn ra Đà Nẵng. Sau khi gửi hành lý ở khách sạn gần biển Mỹ Khê, xe đi lên bán đảo Sơn Trà để ghé chùa Linh Ứng với tượng Quan Âm cao 67 m. Chiều tắm biển Mỹ Khê, tối ăn mì Quảng và bánh xèo rồi ngắm cầu Rồng.

Ngày 2: Bà Nà Hills - Cầu Vàng
Đoàn đi cáp treo lên Bà Nà Hills, đứng trên Cầu Vàng do hai bàn tay đá khổng lồ nâng đỡ và dạo Vườn hoa Le Jardin d''Amour. Trưa ăn buffet trên đỉnh núi, sau đó khách tự chọn tham quan hầm rượu Debay hoặc làng Pháp. Chiều xuống núi, tối tự do đi chợ đêm Sơn Trà.

Ngày 3: Rừng dừa Bảy Mẫu - Hội An
Buổi sáng đoàn đi thuyền thúng ở rừng dừa Bảy Mẫu, xem trình diễn quay thuyền thúng và câu cua. Chiều tham quan phố cổ Hội An gồm chùa Cầu, nhà cổ Tấn Ký, hội quán Phúc Kiến, rồi thả đèn hoa đăng trên sông Hoài. Bữa tối có cao lầu và cơm gà Hội An.

Ngày 4: Ngũ Hành Sơn - Đà Nẵng - TP.HCM
Sáng đoàn tham quan Ngũ Hành Sơn, vào động Huyền Không và nhìn làng đá mỹ nghệ Non Nước phía dưới. Sau bữa trưa, đoàn mua đặc sản như bánh khô mè, nem lụi tại chợ Hàn trước khi ra sân bay bay về TP.HCM vào buổi chiều.', 'ACTIVE'),
    (1, 'TOUR-DL-001', 'Đà Lạt - Thung lũng Tình Yêu - Langbiang 3N2Đ', 'TP.HCM', 'Đà Lạt', '3N2Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 9 DAY) + INTERVAL 21 HOUR,
     3690000, 2690000, 35, 28, '/img/tours/tour-dl-001.jpg',
     'Xe giường nằm lên Đà Lạt, săn mây đồi chè Cầu Đất, thăm ga Đà Lạt, Dinh Bảo Đại, Thiền viện Trúc Lâm và lên Langbiang, nghỉ khách sạn 3 sao gần hồ Xuân Hương.',
     'Ngày 1: TP.HCM - Đà Lạt
Xe khởi hành từ TP.HCM lúc 21h và đoàn nghỉ đêm trên xe qua đèo Bảo Lộc. Sáng sớm đến Đà Lạt, ăn sáng bánh căn, gửi hành lý rồi ghé ga Đà Lạt cổ và chùa Linh Phước với những bức tranh khảm sành sứ. Chiều đi dạo hồ Xuân Hương, thăm Dinh Bảo Đại.

Ngày 2: Cầu Đất - Thiền viện Trúc Lâm - Langbiang
Dậy sớm đi đồi chè Cầu Đất săn mây và chụp ảnh ở đồi cỏ. Sau đó đoàn đến Thiền viện Trúc Lâm bên hồ Tuyền Lâm, đi cáp treo qua đồi thông. Chiều lên núi Langbiang bằng xe jeep, tối ăn lẩu gà lá é và uống sữa đậu nành nóng ở chợ đêm.

Ngày 3: Thung lũng Tình Yêu - TP.HCM
Sáng thăm thung lũng Tình Yêu và vườn dâu tây công nghệ cao, mua mứt, atiso và trà làm quà. Đoàn ăn trưa rồi lên xe về lại TP.HCM, dự kiến đến nơi lúc 20h.', 'ACTIVE'),
    (1, 'TOUR-CT-001', 'Mỹ Tho - Bến Tre - Cần Thơ - Châu Đốc 3N2Đ', 'TP.HCM', 'Cần Thơ', '3N2Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 15 DAY) + INTERVAL 6 HOUR,
     3190000, 2290000, 40, 31, '/img/tours/tour-ct-001.jpg',
     'Đi xuồng qua rạch dừa Bến Tre, ghé chợ nổi Cái Răng lúc sáng sớm, thăm miếu Bà Chúa Xứ núi Sam và rừng tràm Trà Sư, nghỉ khách sạn 3 sao ở Cần Thơ.',
     'Ngày 1: TP.HCM - Mỹ Tho - Bến Tre - Cần Thơ
Đoàn khởi hành lúc 6h theo cao tốc Trung Lương đến Mỹ Tho, đi thuyền qua cù lao Thới Sơn và nghe đờn ca tài tử. Tiếp tục sang Bến Tre, ngồi xuồng ba lá trong rạch dừa, xem lò kẹo dừa và ăn trưa cá tai tượng chiên xù. Chiều đến Cần Thơ nhận phòng, tối dạo bến Ninh Kiều.

Ngày 2: Chợ nổi Cái Răng - Châu Đốc
Sáng sớm đi thuyền ra chợ nổi Cái Răng để ăn sáng ngay trên ghe, xem dân miền Tây bán trái cây bằng cây bẹo. Sau đó thăm nhà cổ Bình Thủy, rồi xe đi Châu Đốc. Chiều đoàn lên núi Sam viếng miếu Bà Chúa Xứ, tối ăn lẩu mắm.

Ngày 3: Rừng tràm Trà Sư - TP.HCM
Sáng đoàn đến rừng tràm Trà Sư ở An Giang, đi xuồng giữa thảm bèo xanh phủ kín mặt nước và lên tháp ngắm chim. Sau bữa trưa, xe quay về TP.HCM, dự kiến đến nơi vào khoảng 19h.', 'ACTIVE'),
    (1, 'TOUR-QB-001', 'Quảng Bình - Phong Nha - Động Thiên Đường - Biển Nhật Lệ 3N2Đ', 'Hà Nội', 'Quảng Bình', '3N2Đ', 'Máy bay + Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 33 DAY) + INTERVAL 6 HOUR,
     5690000, 4090000, 32, 25, '/img/tours/tour-qb-001.jpg',
     'Đi thuyền vào động Phong Nha, đi bộ trong Động Thiên Đường dài hàng km, tắm suối Moọc và dạo biển Nhật Lệ, nghỉ khách sạn 3 sao ở Đồng Hới.',
     'Ngày 1: Hà Nội - Đồng Hới - Biển Nhật Lệ
Chuyến bay sáng từ Hà Nội xuống sân bay Đồng Hới, xe đón đoàn dạo cầu Nhật Lệ và thăm Quảng Bình Quan, cổng thành cổ của xứ Đàng Trong. Trưa ăn cháo canh và bánh bột lọc. Chiều nhận phòng, tắm biển Nhật Lệ rồi ăn tối hải sản.

Ngày 2: Động Phong Nha - Động Thiên Đường
Đoàn đến Vườn quốc gia Phong Nha - Kẻ Bàng, đi thuyền trên sông Son vào động Phong Nha với hệ thống thạch nhũ lớn. Sau bữa trưa, đoàn đi bộ trong Động Thiên Đường khoảng 1 km trên đường gỗ để xem các khối măng đá rộng và cao. Chiều về lại Đồng Hới.

Ngày 3: Suối Moọc - Hà Nội
Sáng xe đưa khách đến suối Moọc, nơi nước xanh trong chảy qua rừng nguyên sinh, có thể bơi và đi xích đu trên suối. Sau bữa trưa, xe ra sân bay Đồng Hới để bay về Hà Nội vào buổi chiều.', 'ACTIVE'),
    (1, 'TOUR-MC-001', 'Mộc Châu - Thung lũng mận - Đồi chè trái tim 2N1Đ', 'Hà Nội', 'Mộc Châu', '2N1Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 5 DAY) + INTERVAL 6 HOUR,
     2550000, 1850000, 35, 35, '/img/tours/tour-mc-001.jpg',
     'Cao nguyên Mộc Châu với đồi chè trái tim, rừng thông bản Áng, thác Dải Yếm và nông trại bò sữa, nghỉ khách sạn 3 sao trung tâm thị trấn.',
     'Ngày 1: Hà Nội - Mộc Châu
Xe rời Hà Nội lúc 6h, đi quốc lộ 6 qua đèo Thung Khe và dừng ăn sáng ở Hòa Bình. Đến Mộc Châu, đoàn tham quan đồi chè trái tim, rừng thông bản Áng và nông trại bò sữa. Chiều đi thác Dải Yếm, tối ăn thịt bò, rau cải mèo.

Ngày 2: Thung lũng mận - Hà Nội
Sáng thăm thung lũng mận Nà Ka hoặc vườn rau Vân Hồ tùy mùa, đi cầu kính Bạch Long nếu khách có nhu cầu. Đoàn ăn trưa, mua sữa chua, bánh dày, thịt trâu gác bếp làm quà. Xe về Hà Nội, đến nơi trước 19h.', 'ACTIVE'),
    (3, 'TOUR-NT-001', 'Nha Trang - VinWonders - Đảo Hòn Mun 4N3Đ', 'Hà Nội', 'Nha Trang', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 27 DAY) + INTERVAL 6 HOUR,
     6290000, 4590000, 36, 30, '/img/tours/tour-nt-001.jpg',
     'Bay Hà Nội - Cam Ranh, đi cano ra vịnh Nha Trang lặn ngắm san hô ở Hòn Mun, vui chơi cả ngày ở VinWonders, nghỉ khách sạn 4 sao mặt đường Trần Phú.',
     'Ngày 1: Hà Nội - Nha Trang - Tháp Bà Ponagar
Chuyến bay sáng đến Cam Ranh, xe đón đoàn về trung tâm Nha Trang. Buổi chiều tham quan tháp Bà Ponagar của người Chăm và chùa Long Sơn với tượng Phật trắng nhìn ra thành phố. Tối ăn bún sứa và nem nướng Ninh Hòa, tự do đi dạo biển.

Ngày 2: Vịnh Nha Trang - Hòn Mun
Đoàn xuống cano ra vịnh, lặn ngắm san hô ở khu bảo tồn biển Hòn Mun, ghé bãi Tranh, làng Bè nuôi cá. Ăn trưa trên đảo với hải sản, chiều tắm biển hoặc đi dù lượn tùy chọn. Tối tự do thưởng thức hải sản ở khu Tháp Bà.

Ngày 3: VinWonders Nha Trang
Cả ngày đoàn vui chơi ở VinWonders trên đảo Hòn Tre, đi cáp treo vượt biển, xem công viên nước, thủy cung và show nhạc nước. Bữa trưa tự túc trong khu vui chơi. Tối về lại khách sạn nghỉ ngơi.

Ngày 4: Nha Trang - Hà Nội
Sáng đoàn thăm viện Hải dương học hoặc chợ Đầm mua yến sào, cá khô, mực một nắng. Trả phòng sau bữa trưa rồi ra sân bay Cam Ranh bay về Hà Nội vào buổi chiều.', 'ACTIVE'),
    (3, 'TOUR-PQ-001', 'Phú Quốc - Nam đảo - Bắc đảo - VinWonders 4N3Đ', 'TP.HCM', 'Phú Quốc', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 38 DAY) + INTERVAL 7 HOUR,
     8990000, 6490000, 30, 24, '/img/tours/tour-pq-001.jpg',
     'Khám phá Phú Quốc trọn vẹn: cáp treo vượt biển Hòn Thơm, tour 4 đảo lặn ngắm san hô, VinWonders và Safari, nghỉ resort 4 sao có hồ bơi.',
     'Ngày 1: TP.HCM - Phú Quốc - Dinh Cậu - Chợ đêm
Chuyến bay buổi sáng đưa đoàn tới Phú Quốc, ăn trưa món gỏi cá trích và bún quậy. Chiều tham quan Dinh Cậu, nhà thùng nước mắm và cơ sở nuôi cấy ngọc trai. Nhận phòng resort, tối dạo chợ đêm Dinh Cậu ăn hải sản nướng.

Ngày 2: Nam đảo - Cáp treo Hòn Thơm
Sáng đoàn đi tuyến cáp treo vượt biển dài 7.900 m từ An Thới sang Hòn Thơm, ngắm các đảo nhỏ phía dưới. Tại Hòn Thơm có công viên nước Aquatopia và bãi biển cát trắng. Buổi tối trở lại resort, tự do thư giãn.

Ngày 3: Tour 4 đảo - Lặn ngắm san hô
Đoàn đi cano thăm các đảo Hòn Móng Tay, Hòn Mây Rút, Hòn Gầm Ghì, dừng lặn ngắm san hô và tắm biển. Ăn trưa trên tàu, chiều câu cá hoặc đi bộ trên bãi cát trắng. Tối ngắm hoàng hôn ở bãi Sao rồi về ăn tối.

Ngày 4: Bắc đảo - Safari - Phú Quốc - TP.HCM
Sáng thăm Vinpearl Safari hoặc VinWonders nếu đoàn đăng ký tuỳ chọn, mua nước mắm, hồ tiêu và rượu sim làm quà. Trả phòng, ăn trưa và ra sân bay Phú Quốc bay về TP.HCM vào buổi chiều.', 'ACTIVE'),
    (3, 'TOUR-MN-001', 'Phan Thiết - Mũi Né - Đồi Cát Bay 3N2Đ', 'TP.HCM', 'Mũi Né', '3N2Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 7 DAY) + INTERVAL 6 HOUR,
     2890000, 2090000, 40, 34, '/img/tours/tour-mn-001.jpg',
     'Đi xe du lịch ra Mũi Né, ngắm bình minh trên đồi cát đỏ, trượt cát đồi cát trắng, thăm suối Tiên và làng chài, nghỉ resort 3 sao sát biển.',
     'Ngày 1: TP.HCM - Phan Thiết - Mũi Né
Xe khởi hành lúc 6h theo cao tốc TP.HCM - Dầu Giây - Phan Thiết, ăn trưa bánh canh chả cá. Chiều thăm tháp Chàm Po Sah Inu, bãi biển Rạng và bãi đá ông Địa. Đoàn nhận phòng resort, tối ăn hải sản.

Ngày 2: Đồi cát - Suối Tiên - Làng chài
Sáng sớm lên đồi cát đỏ ngắm bình minh, sau đó trượt cát trên đồi cát trắng Bàu Trắng. Buổi chiều đi bộ trên suối Tiên theo dòng nước màu đỏ cam. Hoàng hôn ghé làng chài Mũi Né, xem ghe thúng cập bến.

Ngày 3: Tắm biển - Phan Thiết - TP.HCM
Sáng tự do tắm biển và dùng hồ bơi resort. Sau bữa trưa, đoàn ghé nhà máy nước mắm hoặc chợ Phan Thiết mua đặc sản, về TP.HCM đến nơi khoảng 19h.', 'ACTIVE'),
    (3, 'TOUR-QN-001', 'Quy Nhơn - Phú Yên - Kỳ Co - Gành Đá Đĩa 4N3Đ', 'TP.HCM', 'Quy Nhơn', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 41 DAY) + INTERVAL 7 HOUR,
     6390000, 4590000, 32, 27, '/img/tours/tour-qn-001.jpg',
     'Biển Kỳ Co nước xanh, Eo Gió cao hơn 60 m, tháp Đôi Chăm, Gành Đá Đĩa ở Phú Yên và bãi Xép, nghỉ khách sạn 3 sao ở Quy Nhơn.',
     'Ngày 1: TP.HCM - Quy Nhơn - Tháp Đôi
Chuyến bay sáng đến Phù Cát, xe đón khách về thành phố Quy Nhơn. Chiều đoàn ghé tháp Đôi của người Chăm, đi dọc biển Quy Hòa và tắm biển. Tối ăn bánh xèo tôm nhảy và bún chả cá.

Ngày 2: Kỳ Co - Eo Gió
Sáng đi cano ra bãi Kỳ Co, tắm biển và lặn ngắm san hô, nghỉ ăn trưa ngay trên bãi. Chiều thăm Eo Gió, nơi vách đá ôm lấy vịnh nhỏ và đi bộ trên con đường nhỏ ven vách. Tối thưởng thức hải sản ở khu Nhơn Lý.

Ngày 3: Phú Yên - Gành Đá Đĩa - Bãi Xép
Đoàn đi xe qua đèo Cù Mông sang Phú Yên, thăm Gành Đá Đĩa với những cột đá bazan xếp tầng. Tiếp tục đến nhà thờ Mằng Lăng, bãi Xép nổi tiếng nhờ cảnh trong phim. Chiều quay về Quy Nhơn nghỉ đêm.

Ngày 4: Quy Nhơn - TP.HCM
Sáng thăm chùa Thiên Hưng và mộ thi sĩ Hàn Mặc Tử nằm trên đồi cao ven biển. Mua nem chợ Huyện, bánh ít lá gai làm quà trước khi ra sân bay Phù Cát về TP.HCM.', 'ACTIVE'),
    (3, 'TOUR-LS-001', 'Đảo Lý Sơn - Hang Câu - Cổng Tò Vò 3N2Đ', 'Đà Nẵng', 'Lý Sơn', '3N2Đ', 'Xe du lịch + Tàu cao tốc',
     DATE_ADD(CURDATE(), INTERVAL 24 DAY) + INTERVAL 6 HOUR,
     4190000, 3090000, 28, 23, '/img/tours/tour-ls-001.jpg',
     'Ra đảo bằng tàu cao tốc, thăm Cổng Tò Vò, hang Câu, chùa Hang, cánh đồng tỏi và đỉnh Thới Lới, nghỉ homestay đạt chuẩn ở Lý Sơn.',
     'Ngày 1: Đà Nẵng - Sa Kỳ - Lý Sơn
Xe đưa đoàn từ Đà Nẵng đến cảng Sa Kỳ, Quảng Ngãi, lên tàu cao tốc ra đảo mất khoảng 40 phút. Đến đảo, đoàn nhận phòng homestay rồi ăn trưa với cá và rong biển. Chiều đi Cổng Tò Vò và hang Câu để ngắm biển chiều.

Ngày 2: Đảo Bé - Chùa Hang - Đỉnh Thới Lới
Đoàn đi ghe sang đảo Bé, ngâm mình trong nước biển xanh và ngắm san hô. Chiều thăm chùa Hang trong hang đá, miếu âm linh và nhìn cánh đồng tỏi. Buổi tối ngắm hoàng hôn trên đỉnh Thới Lới.

Ngày 3: Lý Sơn - Đà Nẵng
Sáng ăn sáng với bánh xèo hoặc bún cá, mua tỏi Lý Sơn và rong biển làm quà. Sau đó đoàn lên tàu cao tốc về đất liền và lên xe về lại Đà Nẵng.', 'ACTIVE'),
    (3, 'TOUR-CL-001', 'Cát Bà - Vịnh Lan Hạ - Làng chài Việt Hải 3N2Đ', 'Hà Nội', 'Cát Bà', '3N2Đ', 'Xe du lịch + Tàu cao tốc',
     DATE_ADD(CURDATE(), INTERVAL 11 DAY) + INTERVAL 7 HOUR,
     3990000, 2890000, 36, 30, '/img/tours/tour-cl-001.jpg',
     'Nghỉ khách sạn 3 sao bên bãi Cát Cò, đi thuyền chèo kayak qua vịnh Lan Hạ, leo pháo đài Thần Công và thăm làng chài Việt Hải.',
     'Ngày 1: Hà Nội - Hải Phòng - Cát Bà
Xe đi cao tốc Hà Nội - Hải Phòng, ăn trưa bánh đa cua, sau đó lên tàu cao tốc từ bến Bính ra Cát Bà. Đến nơi, đoàn nhận phòng khách sạn và leo pháo đài Thần Công ngắm toàn cảnh quần đảo. Tối tự do dạo phố biển, ăn hải sản.

Ngày 2: Vịnh Lan Hạ - Việt Hải
Đoàn xuống tàu du ngoạn vịnh Lan Hạ, chèo kayak quanh bãi Ba Trái Đào và dừng bơi ở một bãi nhỏ. Ăn trưa trên tàu, chiều đi bộ trong làng chài Việt Hải giữa vườn quốc gia Cát Bà. Tối đi dạo bãi Cát Cò.

Ngày 3: Cát Bà - Hà Nội
Sáng đoàn thăm hang Quân Y rồi trả phòng, ăn trưa món cá thu nướng. Xuống tàu về Hải Phòng và đi xe về Hà Nội, đến nơi khoảng 18h.', 'ACTIVE'),
    (4, 'TOUR-HG-001', 'Hà Giang - Cao nguyên đá Đồng Văn - Mã Pí Lèng 4N3Đ', 'Hà Nội', 'Hà Giang', '4N3Đ', 'Xe limousine',
     DATE_ADD(CURDATE(), INTERVAL 14 DAY) + INTERVAL 7 HOUR,
     5290000, 3790000, 25, 19, '/img/tours/tour-hg-001.jpg',
     'Vòng cao nguyên đá Đồng Văn: cột cờ Lũng Cú, đèo Mã Pí Lèng, sông Nho Quế, phố cổ Đồng Văn và dinh họ Vương, nghỉ homestay và khách sạn 2-3 sao.',
     'Ngày 1: Hà Nội - Hà Giang - Quản Bạ
Xe đón đoàn lúc 7h, theo cao tốc Tuyên Quang - Hà Giang rồi qua cổng trời Quản Bạ. Đoàn dừng chụp hình ở núi đôi Cô Tiên, ăn trưa tại thành phố Hà Giang. Chiều tới Yên Minh, nghỉ đêm ở nhà dân của người Tày.

Ngày 2: Dinh họ Vương - Lũng Cú - Đồng Văn
Sáng đi thăm dinh thự họ Vương ở Sà Phìn với kiến trúc kết hợp Hoa - Mông. Tiếp đó đoàn lên cột cờ Lũng Cú ở cực Bắc, leo hơn 300 bậc để nhìn ra những ngọn núi đá. Chiều đến phố cổ Đồng Văn, tối thưởng thức thắng cố và rượu ngô.

Ngày 3: Mã Pí Lèng - Sông Nho Quế - Mèo Vạc
Đoàn đi qua đèo Mã Pí Lèng, một trong tứ đại đỉnh đèo Việt Nam, dừng ở điểm nhìn xuống vực Tu Sản. Đoàn đi thuyền trên sông Nho Quế giữa hẻm vực sâu 800 m. Chiều tới Mèo Vạc nghỉ ngơi và đi dạo chợ phiên nếu trùng ngày.

Ngày 4: Hà Giang - Hà Nội
Sau bữa sáng, xe quay lại thành phố Hà Giang qua đoạn đường quốc lộ 4C, dừng vườn cam sành mua quà. Ăn trưa tại thành phố Tuyên Quang rồi về Hà Nội lúc 19h.', 'ACTIVE'),
    (4, 'TOUR-CB-001', 'Cao Bằng - Thác Bản Giốc - Động Ngườm Ngao - Hồ Ba Bể 4N3Đ', 'Hà Nội', 'Cao Bằng', '4N3Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 19 DAY) + INTERVAL 6 HOUR,
     4990000, 3590000, 28, 24, '/img/tours/tour-cb-001.jpg',
     'Hành trình Đông Bắc qua hồ Ba Bể, thác Bản Giốc, động Ngườm Ngao, khu di tích Pác Bó và Phja Oắc, nghỉ khách sạn 3 sao ở thành phố Cao Bằng.',
     'Ngày 1: Hà Nội - Bắc Kạn - Hồ Ba Bể
Xe rời Hà Nội lúc 6h, ăn trưa ở Thái Nguyên rồi tới vườn quốc gia Ba Bể. Đoàn đi thuyền trên hồ, ghé ao Tiên, thác Đầu Đẳng và động Puông. Tối nghỉ homestay nhà sàn người Tày.

Ngày 2: Hồ Ba Bể - Pác Bó
Sáng tiếp tục lên đường tới Cao Bằng, ghé khu di tích Pác Bó nơi Bác Hồ từng sống và làm việc. Đoàn đi bộ vào hang Cốc Bó, suối Lê-nin và núi Các Mác. Chiều về thành phố Cao Bằng nhận phòng.

Ngày 3: Thác Bản Giốc - Động Ngườm Ngao
Cả ngày dành cho thác Bản Giốc, nơi dòng nước chia nhiều tầng chảy xuống biên giới, đi bè tre trên sông Quây Sơn. Đoàn vào động Ngườm Ngao, hang dài khoảng 2 km với nhiều nhũ đá. Đêm nghỉ tại Cao Bằng.

Ngày 4: Cao Bằng - Hà Nội
Sáng thăm đèo Mã Phục hoặc phố cổ Cao Bằng, thưởng thức bánh cuốn canh gà. Xe về Hà Nội, dừng nghỉ ở Thái Nguyên. Đoàn về tới Hà Nội vào buổi tối.', 'ACTIVE'),
    (4, 'TOUR-TD-001', 'Trekking Tà Năng - Phan Dũng 2N1Đ', 'TP.HCM', 'Lâm Đồng', '2N1Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 10 DAY) + INTERVAL 20 HOUR,
     2650000, 2050000, 20, 16, '/img/tours/tour-td-001.jpg',
     'Cung đường trekking dài khoảng 55 km nối Lâm Đồng và Bình Thuận, đi qua đồi cỏ, suối và thung lũng, có porter mang đồ cá nhân, cắm trại đêm giữa đồi.',
     'Ngày 1: TP.HCM - Tà Năng - Cắm trại
Xe khởi hành tối hôm trước, đến Đức Trọng vào sáng sớm, ăn sáng rồi bắt đầu đi bộ từ xã Tà Năng. Đoàn đi qua những đồi cỏ lau và suối nhỏ, nghỉ trưa bên suối. Chiều tối cắm trại giữa đồi, nấu ăn cùng nhau và ngắm sao.

Ngày 2: Phan Dũng - TP.HCM
Ngắm bình minh trên đồi rồi ăn sáng. Đoàn tiếp tục đi xuống thôn Phan Dũng, đi qua vài đoạn dốc và suối, kết thúc ở đường lớn sau 6-7 tiếng. Xe đón đoàn ăn trưa, tắm rửa rồi về TP.HCM vào chiều tối.', 'ACTIVE'),
    (4, 'TOUR-FS-001', 'Trekking chinh phục Fansipan 3N2Đ', 'Hà Nội', 'Sa Pa', '3N2Đ', 'Xe giường nằm',
     DATE_ADD(CURDATE(), INTERVAL 16 DAY) + INTERVAL 21 HOUR,
     4890000, 4090000, 18, 14, '/img/tours/tour-fs-001.jpg',
     'Leo bộ đỉnh Fansipan 3.143 m qua đường Trạm Tôn, ngủ lán giữa rừng, đi cùng porter và hướng dẫn viên địa phương, ngày cuối nghỉ khách sạn ở Sa Pa.',
     'Ngày 1: Hà Nội - Sa Pa
Xe đưa đoàn từ Hà Nội theo cao tốc lên Sa Pa, đến nơi vào sáng sớm. Sau bữa sáng, hướng dẫn viên phát đồ bảo hộ và kiểm tra giày, gậy leo núi. Cả ngày nghỉ ngơi, tham quan nhà thờ đá để lấy sức.

Ngày 2: Trạm Tôn - Lán 2.800 m - Đỉnh Fansipan
Đoàn đi bộ qua rừng trúc, rừng đỗ quyên trên đường mòn từ trạm Tôn, nghỉ ở lán khoảng 2.800 m rồi đi tiếp lên đỉnh. Chiều đến cột mốc Fansipan, chụp ảnh biển mây. Đoàn ăn tối và ngủ đêm tại lán.

Ngày 3: Fansipan - Sa Pa - Hà Nội
Sáng sớm xuống núi theo cùng đường mòn, đến trạm Tôn khoảng 11h. Xe đón về khách sạn tắm nghỉ, ăn trưa rồi trở về Hà Nội vào buổi tối.', 'ACTIVE'),
    (4, 'TOUR-PL-001', 'Pù Luông - Ruộng bậc thang - Homestay nhà sàn 3N2Đ', 'Hà Nội', 'Thanh Hóa', '3N2Đ', 'Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 23 DAY) + INTERVAL 6 HOUR,
     3590000, 2590000, 24, 20, '/img/tours/tour-pl-001.jpg',
     'Đi bộ giữa ruộng bậc thang Pù Luông, thăm thác Hiêu, bản Đôn, bản Hiêu và đạp xe quanh làng Thái, nghỉ homestay nhà sàn có bể bơi nhìn ra thung lũng.',
     'Ngày 1: Hà Nội - Pù Luông - Bản Đôn
Xe rời Hà Nội lúc 6h, theo quốc lộ qua Hòa Bình và Hồi Xuân, đến Pù Luông khoảng 11h. Ăn trưa cơm lam, thịt lợn mán. Chiều đi bộ trong bản Đôn, ngắm ruộng bậc thang và guồng nước.

Ngày 2: Thác Hiêu - Bản Hiêu - Đạp xe
Đoàn trekking nhẹ tới thác Hiêu, đi qua những cánh rừng và tắm suối. Chiều đạp xe hoặc đi bộ qua bản Hiêu, xem phụ nữ Thái dệt thổ cẩm. Tối ăn cơm cùng gia đình chủ nhà và nghe hát giao duyên.

Ngày 3: Pù Luông - Hà Nội
Sáng ngắm sương trên ruộng bậc thang, đi chợ phiên bản Kho Mường nếu trùng ngày. Đoàn ăn trưa và về Hà Nội, đến nơi lúc chiều tối.', 'ACTIVE'),
    (4, 'TOUR-YB-001', 'Mù Cang Chải - Tú Lệ - Đèo Khau Phạ 3N2Đ', 'Hà Nội', 'Yên Bái', '3N2Đ', 'Xe limousine',
     DATE_ADD(CURDATE(), INTERVAL 17 DAY) + INTERVAL 6 HOUR,
     3890000, 2790000, 26, 22, '/img/tours/tour-yb-001.jpg',
     'Chiêm ngưỡng ruộng bậc thang Mù Cang Chải, lên đèo Khau Phạ, ghé bản Lìm Mông, bản Cát Cát và thung lũng Tú Lệ, nghỉ homestay người Thái.',
     'Ngày 1: Hà Nội - Nghĩa Lộ - Tú Lệ
Xe rời Hà Nội lúc 6h, ăn trưa ở Nghĩa Lộ với xôi ngũ sắc và cá suối. Chiều đoàn qua cánh đồng Mường Lò, thăm thung lũng Tú Lệ rồi nhận phòng homestay. Tối ăn cơm với gà nướng và xem múa xòe.

Ngày 2: Đèo Khau Phạ - Mù Cang Chải
Sáng lên đèo Khau Phạ, dừng ở điểm ngắm mây và ruộng bậc thang trải dài ở La Pán Tẩn. Đoàn đi bộ ngắn trong bản Lìm Mông, ăn trưa nhà dân. Chiều thăm bản Dế Xu Phình và ngắm hoàng hôn trên đồi.

Ngày 3: Mù Cang Chải - Hà Nội
Sáng đoàn đi chợ phiên nếu có, hoặc đi bộ trong bản. Sau bữa trưa, đoàn quay về Hà Nội, dừng ở Nghĩa Lộ mua nếp và chè Shan tuyết. Đến Hà Nội khoảng 19h.', 'ACTIVE'),
    (5, 'TOUR-HUE-001', 'Cố đô Huế - Đại Nội - Lăng Khải Định - Sông Hương 3N2Đ', 'TP.HCM', 'Huế', '3N2Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 31 DAY) + INTERVAL 6 HOUR,
     6490000, 4690000, 30, 26, '/img/tours/tour-hue-001.jpg',
     'Tìm hiểu kinh thành Huế: Đại Nội, chùa Thiên Mụ, lăng Khải Định, lăng Tự Đức, nhã nhạc cung đình và bữa cơm cung đình, nghỉ khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Huế - Chùa Thiên Mụ
Chuyến bay buổi sáng đến Phú Bài, xe đưa đoàn vào thành phố Huế. Đoàn thăm chùa Thiên Mụ bên bờ sông Hương và đi thuyền rồng trên sông. Tối nghe ca Huế, thưởng thức cơm hến, bánh bèo và nậm lọc.

Ngày 2: Đại Nội - Lăng Tự Đức - Lăng Khải Định
Sáng tham quan Đại Nội qua Ngọ Môn, điện Thái Hòa, Tử Cấm Thành, hồ Tịnh Tâm. Chiều đoàn đi lăng Tự Đức giữa rừng thông và lăng Khải Định với nội thất khảm sành sứ độc đáo. Tối dùng bữa cơm theo kiểu cung đình.

Ngày 3: Làng Thanh Toàn - Huế - TP.HCM
Sáng đi xe đạp qua làng hương Thủy Xuân hoặc cầu ngói Thanh Toàn nằm giữa đồng, mua nón lá bài thơ. Sau bữa trưa, đoàn mua mè xửng, trà cung đình làm quà rồi ra sân bay về TP.HCM.', 'ACTIVE'),
    (5, 'TOUR-HN-001', 'Hà Nội - Văn Miếu - Bát Tràng - Đường Lâm 3N2Đ', 'TP.HCM', 'Hà Nội', '3N2Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 28 DAY) + INTERVAL 6 HOUR,
     5490000, 3990000, 32, 26, '/img/tours/tour-hn-001.jpg',
     'Tìm hiểu Hà Nội xưa: Văn Miếu, Hoàng thành Thăng Long, phố cổ 36 phố phường, làng gốm Bát Tràng và làng cổ Đường Lâm, nghỉ khách sạn 3 sao khu Phố cổ.',
     'Ngày 1: TP.HCM - Hà Nội - Phố cổ
Chuyến bay sáng đến Nội Bài, ăn trưa bún chả và nem rán. Buổi chiều đi cyclo quanh Phố cổ, đến đền Ngọc Sơn cạnh hồ Hoàn Kiếm. Tối xem múa rối nước ở nhà hát Thăng Long.

Ngày 2: Văn Miếu - Hoàng thành - Lăng Bác
Đoàn thăm khu di tích Chủ tịch Hồ Chí Minh, Chùa Một Cột rồi Văn Miếu - Quốc Tử Giám. Chiều tham quan khu Hoàng thành Thăng Long, di sản UNESCO. Tối ăn chả cá Lã Vọng.

Ngày 3: Bát Tràng - Đường Lâm - Hà Nội
Sáng đi làng gốm Bát Tràng để xem công đoạn nặn gốm và tự làm một sản phẩm nhỏ. Chiều thăm Đường Lâm, làng cổ nhà đá ong với cổng làng và đình Mông Phụ. Đoàn ăn tối chè lam, kẹo dồi và ra sân bay về TP.HCM.', 'ACTIVE'),
    (5, 'TOUR-TN-001', 'Tây Nguyên - Buôn Ma Thuột - Pleiku - Kon Tum 4N3Đ', 'TP.HCM', 'Tây Nguyên', '4N3Đ', 'Máy bay + Xe du lịch',
     DATE_ADD(CURDATE(), INTERVAL 36 DAY) + INTERVAL 6 HOUR,
     6490000, 4690000, 28, 23, '/img/tours/tour-tn-001.jpg',
     'Hành trình văn hóa Tây Nguyên: cà phê Buôn Ma Thuột, buôn Akô Dhông, hồ Lắk, Biển Hồ, nhà thờ gỗ Kon Tum, nghe cồng chiêng và nhà rông, nghỉ khách sạn 3 sao.',
     'Ngày 1: TP.HCM - Buôn Ma Thuột
Chuyến bay sáng đưa đoàn tới Buôn Ma Thuột, xe thăm Bảo tàng Thế giới Cà phê và nghe giới thiệu cách rang xay. Chiều đoàn tới buôn Akô Dhông của người Ê Đê, xem nhà dài và dệt thổ cẩm. Tối thưởng thức cơm lam, gà nướng và cà phê.

Ngày 2: Hồ Lắk - Thác Drây Nur
Đoàn đi xe đến hồ Lắk ngắm hoàng hôn và ăn trưa cá hồ. Buổi chiều đi thác Drây Nur - Drây Sáp, nghe truyền thuyết về đôi tình nhân thủy chung. Tối nghỉ lại buôn Jun, tham dự đêm giao lưu cồng chiêng.

Ngày 3: Pleiku - Biển Hồ - Kon Tum
Sáng đoàn đi Pleiku, ghé Biển Hồ T''Nưng, đồi chè Biển Hồ. Chiều đến Kon Tum thăm nhà thờ gỗ Kon Tum và làng Kon K''Tu. Tối ăn gà nướng cơm lam và dùng rượu cần.

Ngày 4: Kon Tum - Pleiku - TP.HCM
Sáng tham quan nhà rông Kon Klor, cầu treo bên sông Đăk Bla. Đoàn mua cà phê, mật ong và thổ cẩm làm quà trước khi về sân bay Pleiku bay về TP.HCM.', 'ACTIVE'),
    (5, 'TOUR-CD-001', 'Côn Đảo - Nhà tù Côn Đảo - Nghĩa trang Hàng Dương 3N2Đ', 'TP.HCM', 'Côn Đảo', '3N2Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 6 DAY) + INTERVAL 6 HOUR,
     8490000, 6090000, 20, 3, '/img/tours/tour-cd-001.jpg',
     'Về nguồn tại Côn Đảo: nhà tù Phú Hải, chuồng cọp, nghĩa trang Hàng Dương, cầu tàu 914, kết hợp tắm biển Đầm Trầu và đi bộ rừng quốc gia.',
     'Ngày 1: TP.HCM - Côn Đảo - Dinh Chúa Đảo
Chuyến bay buổi sáng đến sân bay Cỏ Ống, xe đưa đoàn về khách sạn 3 sao. Chiều tham quan Dinh Chúa Đảo, trại Phú Hải và chuồng cọp để hiểu lịch sử nhà tù thời Pháp. Tối thắp hương ở nghĩa trang Hàng Dương, viếng mộ chị Võ Thị Sáu.

Ngày 2: Rừng quốc gia - Bãi Đầm Trầu
Sáng đoàn đi bộ trong rừng Côn Đảo, ghé bãi Nhát, cầu tàu 914 và chùa Núi Một. Buổi chiều tắm biển ở bãi Đầm Trầu, ngắm cát vàng và nước trong. Tối tự do dạo chợ Côn Đảo thưởng thức ghẹ, ốc.

Ngày 3: Côn Đảo - TP.HCM
Sáng ghé miếu Bà Phi Yến và Bảo tàng Bà Rịa - Vũng Tàu tại Côn Đảo, mua đồ lưu niệm bằng vỏ ốc. Đoàn ăn trưa, trả phòng và bay về TP.HCM chuyến chiều.', 'ACTIVE'),
    (2, 'TOUR-TH-001', 'Thái Lan - Bangkok - Pattaya - Đảo San Hô 5N4Đ', 'TP.HCM', 'Thái Lan', '5N4Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 25 DAY) + INTERVAL 6 HOUR,
     8990000, 6990000, 40, 33, '/img/tours/tour-th-001.jpg',
     'Bay thẳng Bangkok, ra đảo San Hô Koh Larn bằng cano, thăm Chùa Vàng, Phật Sơn, vườn Nong Nooch hoặc Suanthai, đi thuyền sông Chao Phraya và mua sắm, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Bangkok - Pattaya
Đoàn làm thủ tục bay sang Bangkok, ăn trưa nhẹ tại sân bay. Xe đưa đoàn đến Pattaya, ăn tối buffet hải sản và xem show Alcazar nổi tiếng. Nhận phòng khách sạn 4 sao.

Ngày 2: Pattaya - Đảo San Hô
Sau bữa sáng, đoàn đi cano ra đảo San Hô Koh Larn, tắm biển và tham gia các trò chơi nước. Chiều thăm núi Phật Vàng và chùa Wat Phra Yai, trải nghiệm massage Thái. Tối tự do đi Walking Street.

Ngày 3: Pattaya - Bangkok
Sáng thăm vườn Nong Nooch hoặc khu Suanthai với nhiều tiết mục trình diễn văn hóa Thái. Sau bữa trưa, xe về Bangkok, thăm Bảo tàng Ánh sáng hoặc Vườn khinh khí cầu. Tối ăn lẩu Suki, nhận phòng và tự do.

Ngày 4: Bangkok - Sông Chao Phraya - Mua sắm
Đoàn đi thuyền trên sông Chao Phraya và ăn trưa buffet trên tầng cao của Baiyoke Sky. Buổi chiều tự do mua sắm ở Siam Paragon, Central World hoặc chợ Platinum. Tối ăn tự túc.

Ngày 5: Bangkok - TP.HCM
Sau bữa sáng, đoàn thăm chùa Phật Vàng Wat Traimit và chùa Wat Yannawa hình chiếc thuyền. Đoàn ra sân bay Suvarnabhumi và bay về TP.HCM.', 'ACTIVE'),
    (2, 'TOUR-SG-001', 'Singapore - Universal Studios - Gardens by the Bay 4N3Đ', 'TP.HCM', 'Singapore', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 34 DAY) + INTERVAL 6 HOUR,
     14990000, 11990000, 32, 26, '/img/tours/tour-sg-001.jpg',
     'Thành phố sư tử xanh: Gardens by the Bay, Marina Bay Sands, Universal Studios trên đảo Sentosa, Night Safari và khu Chinatown, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Singapore - Gardens by the Bay
Chuyến bay sáng đến Changi, xe đón đoàn thăm tượng sư tử Merlion, vịnh Marina. Chiều đoàn đến Gardens by the Bay, đi trên cầu treo OCBC Skyway giữa các Supertree. Tối xem show Spectra tại khu vực Marina Bay Sands.

Ngày 2: Sentosa - Universal Studios
Cả ngày vui chơi trong công viên Universal Studios Singapore với các khu Transformers, Jurassic Park và Far Far Away. Bữa trưa tự túc trong khu giải trí. Tối đi cáp treo Sentosa ngắm cảnh biển.

Ngày 3: Chinatown - Night Safari
Sáng đoàn thăm đền Phật Nha ở Chinatown, khu Little India và đại lộ Orchard để mua sắm. Chiều ghé tòa Quốc hội, nhà hát Esplanade. Tối đi Night Safari, xe điện ngắm thú đêm.

Ngày 4: Singapore - TP.HCM
Sáng đoàn thăm vườn lan quốc gia hoặc nhà máy sô cô la địa phương, mua socola và bánh dứa làm quà. Ăn trưa và ra sân bay Changi bay về TP.HCM vào buổi chiều.', 'ACTIVE'),
    (2, 'TOUR-MY-001', 'Malaysia - Kuala Lumpur - Genting - Putrajaya 4N3Đ', 'TP.HCM', 'Malaysia', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 43 DAY) + INTERVAL 6 HOUR,
     10990000, 8490000, 36, 30, '/img/tours/tour-my-001.jpg',
     'Tháp đôi Petronas, hang Batu, cao nguyên Genting, thành phố hành chính Putrajaya và Malacca cổ kính, khách sạn 4 sao tại Kuala Lumpur.',
     'Ngày 1: TP.HCM - Kuala Lumpur
Chuyến bay đến sân bay Kuala Lumpur, xe đón đoàn thăm tháp đôi Petronas từ bên ngoài, công viên KLCC và quảng trường Merdeka. Tối ăn tối món Malay và tự do dạo chợ Jalan Alor.

Ngày 2: Batu Caves - Genting Highlands
Đoàn thăm hang Batu với bậc thang rực rỡ dẫn lên đền Hindu trong lòng núi đá. Chiều đi cáp treo Awana Skyway lên cao nguyên Genting, vui chơi trong khu giải trí trong nhà. Tối nghỉ tại khách sạn Genting.

Ngày 3: Putrajaya - Malacca
Sáng xuống núi tham quan thành phố hành chính Putrajaya với nhà thờ Hồi giáo Hồng Putra. Tiếp tục đi Malacca, nhìn quảng trường Hà Lan, pháo đài A Famosa và phố Jonker. Tối ăn cơm gà Hải Nam.

Ngày 4: Kuala Lumpur - TP.HCM
Sáng đoàn về Kuala Lumpur, ghé nhà máy thiếc Royal Selangor và chợ trung tâm mua sô cô la, trà và đồ thiếc. Ăn trưa trước khi ra sân bay bay về TP.HCM.', 'ACTIVE'),
    (2, 'TOUR-JP-001', 'Nhật Bản - Tokyo - Núi Phú Sĩ - Kyoto - Osaka 6N5Đ', 'TP.HCM', 'Nhật Bản', '6N5Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 64 DAY) + INTERVAL 22 HOUR,
     34900000, 26900000, 25, 18, '/img/tours/tour-jp-001.jpg',
     'Bay thẳng Narita, ngắm núi Phú Sĩ, làng cổ Oshino Hakkai, đền Fushimi Inari, chùa Thanh Thủy, lâu đài Osaka và đi tàu Shinkansen, khách sạn 3-4 sao.',
     'Ngày 1: TP.HCM - Tokyo
Đoàn tập trung tại sân bay Tân Sơn Nhất vào buổi tối để làm thủ tục cho chuyến bay thẳng đến Narita. Cả đoàn nghỉ ngơi trên máy bay và hạ cánh vào sáng sớm hôm sau. Bữa ăn trong ngày do hãng hàng không phục vụ.

Ngày 2: Tokyo - Núi Phú Sĩ
Đoàn thăm chùa Asakusa Sensoji, phố Nakamise và chụp hình Tokyo Skytree từ bên ngoài. Chiều dạo đảo Odaiba, sau đó xe đưa tới vùng chân núi Phú Sĩ. Tối tắm onsen và ăn tối kiểu Nhật.

Ngày 3: Phú Sĩ - Nagoya
Đoàn lên trạm 5 núi Phú Sĩ nếu thời tiết tốt, ghé làng cổ Oshino Hakkai với tám hồ nước trong. Chiều dạo công viên Oishi ngắm hoa theo mùa, tối nghỉ ở Nagoya.

Ngày 4: Nagoya - Kyoto - Osaka
Buổi sáng trải nghiệm trà đạo, đoàn đến Kyoto thăm chùa Thanh Thủy và đền Fushimi Inari với hàng nghìn cổng torii đỏ. Chiều đi tàu Shinkansen sang Osaka, nghỉ đêm.

Ngày 5: Osaka - Mua sắm
Đoàn chụp hình lâu đài Osaka, thăm bảo tàng rượu sake và ăn trưa bò Kobe. Chiều dạo khu mua sắm Shinsaibashi, phố ẩm thực Dotonbori và cầu Ebisu.

Ngày 6: Osaka - TP.HCM
Sau bữa sáng, xe đưa đoàn ra sân bay Kansai để làm thủ tục. Chuyến bay về TP.HCM cất cánh vào buổi sáng và hạ cánh khoảng giữa trưa. Kết thúc chương trình, hẹn gặp lại quý khách.', 'ACTIVE'),
    (2, 'TOUR-JP-002', 'Nhật Bản - Hokkaido - Sapporo - Otaru - Furano 6N5Đ', 'TP.HCM', 'Nhật Bản', '6N5Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 90 DAY) + INTERVAL 22 HOUR,
     44900000, 33900000, 18, 2, '/img/tours/tour-jp-002.jpg',
     'Hành trình đảo bắc Nhật Bản với Sapporo, kênh đào Otaru, hồ Toya, cánh đồng hoa Furano - Biei, ao Xanh và onsen, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Sapporo
Đoàn tập trung ở sân bay vào buổi tối, bay đêm có quá cảnh một chặng để đến sân bay New Chitose ở Sapporo. Cả đoàn nghỉ ngơi trên máy bay trong phần lớn thời gian. Bữa ăn trong ngày do hãng hàng không phục vụ.

Ngày 2: Sapporo - Otaru
Sáng đoàn thăm tháp đồng hồ Sapporo, công viên Odori và đài quan sát. Chiều đi Otaru, dạo kênh đào, phố thủy tinh, nhà hộp nhạc. Tối ăn tối hải sản và nghỉ ở Sapporo.

Ngày 3: Hồ Toya - Noboribetsu
Đoàn đi hồ Toya ngắm núi Usu và tham quan thung lũng địa ngục Jigokudani. Chiều tắm onsen và ăn tối kiểu Nhật tại khách sạn.

Ngày 4: Furano - Biei
Đoàn đi qua vùng Furano - Biei, ghé trang trại hoa Farm Tomita và ao Xanh. Chiều thăm đồi Shikisai và đồi Patchwork. Tối nghỉ ở Asahikawa.

Ngày 5: Asahikawa - Sapporo - Mua sắm
Sáng thăm vườn thú Asahiyama nếu mùa phù hợp, chiều về Sapporo. Đoàn tự do mua sắm ở Tanukikoji và Susukino.

Ngày 6: Sapporo - TP.HCM
Sau bữa sáng, đoàn trả phòng và ra sân bay New Chitose. Chuyến bay có quá cảnh một chặng rồi về tới TP.HCM vào cuối ngày. Kết thúc chương trình, hướng dẫn viên chia tay đoàn.', 'ACTIVE'),
    (2, 'TOUR-KR-001', 'Hàn Quốc - Seoul - Đảo Nami - Everland 5N4Đ', 'TP.HCM', 'Hàn Quốc', '5N4Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 52 DAY) + INTERVAL 21 HOUR,
     17990000, 13490000, 35, 28, '/img/tours/tour-kr-001.jpg',
     'Bay thẳng Incheon, đi cung điện Gyeongbokgung, đảo Nami, công viên Everland, tháp Namsan và phố mua sắm Myeongdong, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Seoul
Đoàn tập trung tại sân bay Tân Sơn Nhất vào buổi tối để làm thủ tục bay đến Incheon. Cả đoàn nghỉ trên máy bay và hạ cánh vào sáng sớm hôm sau. Xe đón đoàn về trung tâm Seoul để bắt đầu chương trình.

Ngày 2: Seoul - Cung Gyeongbokgung - Làng Bukchon
Sáng thăm cung Gyeongbokgung và xem lễ đổi gác nếu đúng giờ. Chiều dạo làng Hanok Bukchon và đi chợ Insadong. Tối ăn thịt nướng Hàn Quốc.

Ngày 3: Đảo Nami - Everland
Đoàn đi đảo Nami, dạo con đường ngân hạnh, chụp ảnh với hàng cây hai bên đường. Chiều đến công viên Everland, thử các trò chơi và vườn thú Safari. Tối ăn tối gà hầm sâm.

Ngày 4: Namsan - Myeongdong
Sáng đoàn thăm xưởng làm kim chi và mặc thử hanbok. Chiều lên tháp Namsan, mua nhân sâm, mỹ phẩm ở cửa hàng miễn thuế. Tối tự do ở Myeongdong.

Ngày 5: Seoul - TP.HCM
Sau bữa sáng, đoàn trả phòng và có thời gian ghé cửa hàng miễn thuế để mua quà. Xe đưa đoàn ra sân bay Incheon, làm thủ tục cho chuyến bay về TP.HCM. Chuyến bay hạ cánh vào buổi chiều.', 'ACTIVE'),
    (2, 'TOUR-KR-002', 'Hàn Quốc - Seoul - Đảo Jeju - Núi Hallasan 5N4Đ', 'TP.HCM', 'Hàn Quốc', '5N4Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 75 DAY) + INTERVAL 21 HOUR,
     21490000, 16490000, 30, 25, '/img/tours/tour-kr-002.jpg',
     'Kết hợp thủ đô Seoul và đảo Jeju: đỉnh bình minh Seongsan Ilchulbong, thác Jeongbang, cánh đồng canola và công viên quốc gia Hallasan, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Seoul
Đoàn tập trung tại sân bay Tân Sơn Nhất vào buổi tối để làm thủ tục bay đến Incheon. Cả đoàn nghỉ ngơi trên máy bay. Hạ cánh vào sáng sớm hôm sau, xe đón về trung tâm Seoul.

Ngày 2: Seoul - Jeju
Sáng thăm cung Changdeokgung và phố Insadong. Chiều bay nội địa sang đảo Jeju, nhận phòng và ăn tối món hải sản địa phương.

Ngày 3: Seongsan - Thác Jeongbang
Đoàn leo đỉnh Seongsan Ilchulbong, miệng núi lửa nhìn ra biển. Chiều thăm thác Jeongbang đổ thẳng ra biển và làng dân tục Seongeup. Tối tự do ở trung tâm Jeju.

Ngày 4: Hallasan - Jeju - Seoul
Sáng đoàn đi bộ nhẹ trong công viên quốc gia Hallasan và thăm hang dung nham Manjanggul. Chiều bay về Seoul, ăn tối và mua sắm.

Ngày 5: Seoul - TP.HCM
Sáng đoàn ăn sáng, trả phòng và mua thêm quà ở khu phố gần khách sạn. Xe đưa đoàn ra sân bay Incheon để làm thủ tục. Chuyến bay hạ cánh tại TP.HCM vào buổi chiều.', 'ACTIVE'),
    (2, 'TOUR-CN-001', 'Trung Quốc - Bắc Kinh - Vạn Lý Trường Thành - Thượng Hải 6N5Đ', 'TP.HCM', 'Trung Quốc', '6N5Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 100 DAY) + INTERVAL 7 HOUR,
     25900000, 19900000, 30, 24, '/img/tours/tour-cn-001.jpg',
     'Từ Tử Cấm Thành và Vạn Lý Trường Thành đến Bến Thượng Hải về đêm, đi tàu cao tốc Bắc Kinh - Thượng Hải, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Bắc Kinh
Đoàn tập trung ở sân bay Tân Sơn Nhất từ sáng sớm để làm thủ tục bay đến Bắc Kinh. Xe đón đoàn tại sân bay Thủ Đô và đưa về khách sạn 4 sao. Buổi tối đoàn thưởng thức vịt quay Bắc Kinh trong bữa tối đặc trưng.

Ngày 2: Quảng trường Thiên An Môn - Tử Cấm Thành
Đoàn thăm quảng trường Thiên An Môn, Tử Cấm Thành, Cố Cung. Chiều đến Thiên Đàn xem người dân tập thái cực quyền. Tối xem xiếc Bắc Kinh.

Ngày 3: Vạn Lý Trường Thành - Cung điện Mùa Hè
Sáng đoàn lên Vạn Lý Trường Thành tại Mutianyu. Chiều thăm Di Hòa Viên, hồ Côn Minh. Tối tự do mua sắm ở Vương Phủ Tỉnh.

Ngày 4: Bắc Kinh - Thượng Hải
Đoàn đi tàu cao tốc đến Thượng Hải, mất khoảng 4,5 giờ. Chiều dạo vườn Dự Viên và phố cổ Thành Hoàng Miếu.

Ngày 5: Thượng Hải - Bến Thượng Hải
Đoàn đi dọc Bến Thượng Hải ngắm các tòa nhà cổ, đi phố Nam Kinh và lên tháp truyền hình Minh Châu. Tối đi thuyền trên sông Hoàng Phố ngắm cảnh đêm.

Ngày 6: Thượng Hải - TP.HCM
Sáng thăm Xưởng tơ lụa hoặc Hiệu thuốc cổ truyền, ăn trưa dimsum. Ra sân bay Phố Đông, bay về TP.HCM.', 'ACTIVE'),
    (2, 'TOUR-CN-002', 'Trung Quốc - Trương Gia Giới - Phượng Hoàng Cổ Trấn 5N4Đ', 'TP.HCM', 'Trung Quốc', '5N4Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 80 DAY) + INTERVAL 7 HOUR,
     16900000, 12900000, 30, 25, '/img/tours/tour-cn-002.jpg',
     'Rừng đá Trương Gia Giới, cầu kính, núi Thiên Môn, cảnh quan Avatar và phố cổ Phượng Hoàng bên sông Đà, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Trường Sa - Trương Gia Giới
Đoàn bay đến Trường Sa, đi xe đến Trương Gia Giới. Ăn tối món Tương Tây cay đặc trưng.

Ngày 2: Công viên Quốc gia Trương Gia Giới
Đoàn đi cáp treo lên núi Hoàng Thạch Trại, đi bộ xem Núi Nghìn Cột nổi tiếng với cảnh phim Avatar. Chiều thăm thang máy Bách Long, Thiên Tử Sơn.

Ngày 3: Thiên Môn Sơn - Cầu kính
Đoàn lên núi Thiên Môn bằng cáp treo và đi cầu kính Đại Hạp Cốc. Chiều thăm động Thiên Môn và đi chợ.

Ngày 4: Phượng Hoàng Cổ Trấn
Đoàn đi xe đến Phượng Hoàng Cổ Trấn, dạo phố cổ ven sông Đà Giang, ngắm nhà sàn gỗ. Tối đi thuyền xem đèn lồng.

Ngày 5: Phượng Hoàng - Trường Sa - TP.HCM
Sáng đoàn trả phòng và đi xe về lại Trường Sa, mất khoảng bốn tiếng. Buổi trưa đoàn dạo phố đi bộ Hoàng Hưng và ăn trưa món Hồ Nam. Chiều ra sân bay Hoàng Hoa để bay về TP.HCM.', 'ACTIVE'),
    (2, 'TOUR-ID-001', 'Indonesia - Bali - Ubud - Tanah Lot 4N3Đ', 'TP.HCM', 'Indonesia', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 60 DAY) + INTERVAL 6 HOUR,
     12490000, 9490000, 30, 24, '/img/tours/tour-id-001.jpg',
     'Đảo Thần Bali: ruộng bậc thang Tegalalang, đền Tanah Lot, đền vách đá Uluwatu, đền Ulun Danu, làng Penglipuran, khách sạn 4 sao ở Kuta.',
     'Ngày 1: TP.HCM - Bali - Kuta
Chuyến bay sáng đến sân bay Ngurah Rai, xe đưa đoàn về khách sạn ở Kuta. Chiều dạo biển Kuta và ăn tối kiểu Bali.

Ngày 2: Ubud - Tegalalang
Đoàn đi xem điệu múa Barong, thăm làng nghệ thuật Celuk chuyên bạc, Mas chuyên điêu khắc gỗ. Chiều thăm ruộng bậc thang Tegalalang và chụp ảnh xích đu. Tối tự do.

Ngày 3: Bedugul - Tanah Lot
Sáng đoàn đi đền Ulun Danu Beratan bên hồ, làng Penglipuran. Chiều thăm đền Tanah Lot trên tảng đá ven biển và ngắm hoàng hôn.

Ngày 4: Uluwatu - TP.HCM
Sáng đoàn thăm đền Uluwatu trên vách đá ven biển, xem múa Kecak nếu thời gian cho phép. Ra sân bay, về TP.HCM.', 'ACTIVE'),
    (5, 'TOUR-KH-001', 'Campuchia - Siem Reap - Angkor Wat - Phnom Penh 4N3Đ', 'TP.HCM', 'Campuchia', '4N3Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 47 DAY) + INTERVAL 7 HOUR,
     7490000, 5490000, 36, 30, '/img/tours/tour-kh-001.jpg',
     'Quần thể đền Angkor, Angkor Thom và đền Ta Prohm, hồ Tonle Sap, Phnom Penh với Hoàng cung và chùa Bạc, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Siem Reap
Đoàn bay đến Siem Reap, xe đón thăm làng nổi trên hồ Tonle Sap. Tối ăn tối buffet và xem múa Apsara.

Ngày 2: Angkor Wat - Angkor Thom
Sáng đến Angkor Wat ngắm bình minh và tham quan đền. Chiều thăm Angkor Thom với đền Bayon có các tháp mặt người, đền Ta Prohm có rễ cây quấn đền.

Ngày 3: Siem Reap - Phnom Penh
Đoàn đi xe đến Phnom Penh. Buổi chiều thăm Hoàng cung, chùa Bạc và bảo tàng quốc gia. Tối dạo sông Tonle Sap.

Ngày 4: Phnom Penh - TP.HCM
Sáng thăm chợ Phsar Thmei, đền Wat Phnom. Ra sân bay bay về TP.HCM.', 'ACTIVE'),
    (2, 'TOUR-TW-001', 'Đài Loan - Đài Bắc - Đài Trung - Cao Hùng 5N4Đ', 'TP.HCM', 'Đài Loan', '5N4Đ', 'Máy bay',
     DATE_ADD(CURDATE(), INTERVAL 70 DAY) + INTERVAL 6 HOUR,
     17490000, 13490000, 30, 25, '/img/tours/tour-tw-001.jpg',
     'Hành trình quanh đảo từ Đài Bắc đến Cao Hùng: tháp Taipei 101, hồ Nhật Nguyệt, phố cổ Cửu Phần, chợ đêm và đi tàu cao tốc, khách sạn 4 sao.',
     'Ngày 1: TP.HCM - Đài Bắc
Đoàn bay đến sân bay Đào Viên, xe đón về khách sạn. Tối dạo chợ đêm Shilin và nếm trà sữa trân châu.

Ngày 2: Đài Bắc - Cửu Phần - Thập Phần
Đoàn đi phố cổ Cửu Phần với những con ngõ treo đèn lồng đỏ, thả đèn trời ở Thập Phần. Chiều thăm đài tưởng niệm Tưởng Giới Thạch.

Ngày 3: Đài Bắc - Đài Trung - Hồ Nhật Nguyệt
Sáng lên đài quan sát Taipei 101, đi tàu cao tốc xuống Đài Trung. Chiều đi thuyền trên hồ Nhật Nguyệt và thăm chùa Văn Võ.

Ngày 4: Đài Trung - Cao Hùng
Đoàn đi đến làng cầu vồng Đài Trung, sau đó xuống Cao Hùng thăm hồ Liên Trì với Long Hổ Tháp. Tối ăn tối ở chợ đêm Lục Hợp.

Ngày 5: Cao Hùng - TP.HCM
Sáng đoàn thăm khu nghệ thuật Pier-2, mua bánh dứa. Bay từ Cao Hùng về TP.HCM.', 'ACTIVE');
