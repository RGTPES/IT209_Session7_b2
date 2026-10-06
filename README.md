# Báo Cáo Bài Tập 2: Quản trị Tường lửa UFW cho Cụm Dịch vụ Multi-port

## 1. Thông Tin & Mục Tiêu
- **Môn học / Session**: Session 07 - Bài 2
- **Mục tiêu**:
  - Thiết lập tường lửa UFW (Uncomplicated Firewall) bảo mật hệ thống máy chủ chạy nhiều cổng dịch vụ đồng thời.
  - Cấu hình mở cổng có chọn lọc cho các dịch vụ quản trị và dịch vụ web (SSH, Nginx, Spring Boot).
  - Cô lập cổng dịch vụ cơ sở dữ liệu MySQL (port 3306) trước các cuộc tấn công quét cổng từ Internet.

---

## 2. Bối Cảnh & Phân Bổ Cổng Dịch Vụ

| Dịch vụ | Cổng (Port) | Giao thức | Chính sách tường lửa | Ghi chú |
| :--- | :--- | :--- | :--- | :--- |
| **SSH** | `22` | TCP | `ALLOW IN` | Dành cho quản trị viên truy cập từ xa |
| **Nginx Web** | `80` | TCP | `ALLOW IN` | Phục vụ người dùng truy cập Web HTTP |
| **Spring Boot App** | `8082` | TCP | `ALLOW IN` | Kiểm tra ứng dụng backend từ xa |
| **MySQL Database** | `3306` | TCP | `DENY` (Mặc định) | Cô lập hoàn toàn khỏi Internet, chỉ giao tiếp nội bộ |

---

## 3. Các Bước Thực Hiện Cấu Hình

### Bước 1: Khai báo chính sách mặc định (Default Policies)
Thiết lập chặn toàn bộ lưu lượng vào máy chủ và cho phép máy chủ tạo kết nối ra ngoài:
```bash
# Chặn toàn bộ lưu lượng đi vào theo mặc định
sudo ufw default deny incoming

# Cho phép tất cả lưu lượng đi ra ngoài
sudo ufw default allow outgoing
```

### Bước 2: Cho phép các cổng dịch vụ được chỉ định
Thêm luật cho phép truy cập từ mọi nơi (Anywhere) tới các cổng dịch vụ cần công khai:
```bash
# 1. Cho phép kết nối SSH (Port 22/tcp)
sudo ufw allow 22/tcp

# 2. Cho phép kết nối Web HTTP (Port 80/tcp)
sudo ufw allow 80/tcp

# 3. Cho phép kết nối Spring Boot (Port 8082/tcp)
sudo ufw allow 8082/tcp
```

### Bước 3: Đảm bảo cô lập cổng MySQL (Port 3306)
- **Cơ chế**: Do chính sách mặc định `default deny incoming` đã được thiết lập ở Bước 1, bất kỳ cổng nào **không** được thêm luật `allow` sẽ tự động bị từ chối/chặn mọi gói tin từ Internet gửi đến.
- Do đó, không cần (và không được) thêm luật cho phép cổng `3306/tcp`, đảm bảo MySQL hoàn toàn an toàn và chỉ có thể truy cập qua localhost hoặc mạng nội bộ được cấu hình riêng.

### Bước 4: Kích hoạt tường lửa UFW
Kích hoạt UFW và cho phép tự động khởi động cùng hệ thống:
```bash
sudo ufw enable
```
*Nhấn `y` và `Enter` khi hệ thống cảnh báo về việc kích hoạt có thể làm gián đoạn các kết nối SSH hiện tại.*

---

## 4. Kiểm Tra & Kết Quả Đầu Ra

### Lệnh thực hiện:
```bash
sudo ufw status verbose
```

### Đầu ra (Output) thực tế từ hệ thống:
```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  
80/tcp                     ALLOW IN    Anywhere                  
8082/tcp                   ALLOW IN    Anywhere                  
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
80/tcp (v6)                ALLOW IN    Anywhere (v6)             
8082/tcp (v6)              ALLOW IN    Anywhere (v6)             
```

---

## 5. Đánh Giá & Kết Luận
1. **Trạng thái hoạt động**: UFW đang ở trạng thái `Status: active`.
2. **Chính sách mặc định**: `Default: deny (incoming), allow (outgoing)` - Đảm bảo nguyên tắc bảo mật tối thiểu (least privilege).
3. **Mở cổng dịch vụ công khai**:
   - `22/tcp`: Đã cho phép kết nối SSH quản trị.
   - `80/tcp`: Đã cho phép kết nối Web HTTP.
   - `8082/tcp`: Đã cho phép kết nối Spring Boot.
4. **Cô lập cơ sở dữ liệu**:
   - Cổng `3306` (MySQL) hoàn toàn không xuất hiện trong danh sách `ALLOW IN`.
   - Kết hợp với chính sách `deny incoming`, cổng 3306 bị khóa đối với mọi kết nối từ bên ngoài Internet, thỏa mãn hoàn toàn yêu cầu bài tập.
