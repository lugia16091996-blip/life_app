# 🚀 HỆ THỐNG QUẢN LÝ CÁ NHÂN TOÀN DIỆN (ALL-IN-ONE LIFE APP)
>
> **Mục tiêu:** Quản lý Tài chính cá nhân & nhóm (vợ chồng/bạn bè), Theo dõi Cảm xúc và Quản lý Tủ sách.
> **Triết lý kỹ thuật:** Chi phí 0 Đồng vĩnh viễn (Zero-Cost), Hoạt động Offline-First, Đơn giản, Mở rộng linh hoạt.
>
cd D:\MinhDao\CaNhan\app_temp\life_app\life_app
>> flutter run -d chrome --web-port=8080

---

## 🛠️ 1. TỔNG QUAN CÔNG NGHỆ (TECH STACK 0 ĐỒNG)

| Thành Phần | Công Nghệ Sử Dụng | Mục Đích / Ghi Chú |
| :--- | :--- | :--- |
| **Ngôn ngữ / Framework** | **Flutter (Dart)** | Code 1 lần chạy trên Android, iOS và Web. |
| **Database Chính (Đám mây)** | **Google Sheets API** | Lưu trữ dữ liệu chung, dễ chia sẻ cho 2-5+ người dùng, 0đ vĩnh viễn. |
| **Database Phụ (Cục bộ)** | **SQLite / Hive** | Lưu tạm dữ liệu trên điện thoại khi KHÔNG CÓ MẠNG (Offline). |
| **Xác thực & Chia sẻ** | **Google OAuth2 / Drive API** | Đăng nhập tài khoản Google & Phân quyền truy cập file Sheets. |
| **Lưu trữ Hình ảnh** | **Cloudinary (Free Tier)** | Lưu ảnh hóa đơn, chứng từ và bìa sách (dung lượng 25GB free). |

---

## 📂 2. CẤU TRÚC THƯ MỤC DỰ ÁN (PROJECT STRUCTURE)

Cấu trúc dự án Flutter theo mô hình **Clean Architecture / Feature-First**:

```text
my_life_app/
├── assets/                         # Hình ảnh, Biểu tượng (Icons), Phông chữ
│   ├── icons/
│   └── images/
│
├── lib/                            # Mã nguồn Dart chính
│   ├── main.dart                   # Điểm khởi chạy ứng dụng (Entrypoint)
│   │
│   ├── core/                       # Cấu hình hệ thống dùng chung
│   │   ├── constants/              # Hằng số, Tên cột, App Colors
│   │   ├── network/                # Kiểm tra kết nối mạng (Network Listener)
│   │   ├── services/               # Google Sheets API Service, Cloudinary Service
│   │   └── database/               # Local DB Helper (SQLite/Hive) cho Offline
│   │
│   ├── features/                   # Tách module theo từng chức năng nghiệp vụ
│   │   ├── auth/                   # 🔑 Đăng nhập Google & Kết nối Sổ chung
│   │   │   ├── presentation/       # Màn hình Login, Màn hình Nhập Mã Sổ
│   │   │   └── data/               # Google Sign-In Controller
│   │   │
│   │   ├── finance/                # 💰 MODULE CHÍNH: QUẢN LÝ TÀI CHÍNH
│   │   │   ├── models/             # FinanceTransaction Model (Chuyển đổi Data <-> Sheets)
│   │   │   ├── repositories/       # Xử lý Logic: Lưu Offline -> Đẩy Online
│   │   │   └── presentation/       # UI: Form Nhập Thu-Chi, Bảng Data Table, Biểu đồ
│   │   │
│   │   ├── mood/                   # 🎭 MODULE CẢM XÚC (Mood Tracker)
│   │   │   ├── models/
│   │   │   └── presentation/       # UI: Nhật ký Cảm xúc, Biểu đồ tâm trạng
│   │   │
│   │   └── books/                  # 📚 MODULE QUẢN LÝ SÁCH (Book Tracker)
│   │       ├── models/
│   │       └── presentation/       # UI: Tủ sách, Tiến độ đọc, Trích dẫn hay
│   │
│   └── shared/                     # Widgets dùng chung (Buttons, Input Fields, Loading)
│
├── pubspec.yaml                    # Quản lý thư viện bổ sung (Dependencies)
└── README.md


lib/features/home/presentation/
├── tabs/
│   ├── finance_tab.dart        <-- File chính hiện tại (nhạc trưởng)
│   └── ...
└── widgets/                    <-- Tạo folder widgets mới ở đây
    ├── add_transaction_dialog.dart   <-- File chứa form nhập/thêm giao dịch
    └── transaction_list_view.dart    <-- File chứa danh sách hiển thị giao dịch

# 1726 việc cần làm 

Tuyệt vời! Chúc mừng bạn đã vượt qua phần khó nhất (xác thực OAuth và tự động hóa Google Sheets). Việc tự tay làm được đến đây chứng tỏ code và luồng xử lý của bạn đã cực kỳ cứng tay rồi! 🎉

Bây giờ file `Sổ Quản Lý Life App` đã nằm gọn trên Google Drive cá nhân với đầy đủ 4 tab tiêu đề (`taichinh`, `book`, `EQ`, `Quotes`). Bước tiếp theo, chúng ta sẽ bắt tay vào xây dựng các tính năng cốt lõi để ứng dụng thực sự có "hồn" và phục vụ cuộc sống hằng ngày của bạn.

---

### 🗺️ LỘ TRÌNH CÁC BƯỚC TIẾP THEO

#### **Bước 1: Lưu trữ và Tái sử dụng `spreadsheetId` (QUAN TRỌNG NHẤT)**

* **Vấn đề:** Hiện tại mỗi lần mở app hay restart, nếu bạn không lưu lại `spreadsheetId`, app sẽ không biết file nào để ghi dữ liệu, dẫn đến việc mỗi lần bấm lại tưởng phải tạo file mới.
* **Giải pháp:** Trong màn hình `WelcomeScreen` (đoạn code bạn gửi ở trên), chúng ta đã có sẵn đoạn code lưu vào `SharedPreferences`:
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('spreadsheet_id', sheetId);

```

* **Việc cần làm:** Tạo một hàm kiểm tra khởi đầu (ở file `main.dart` hoặc màn hình Splash): Nếu `spreadsheet_id` đã tồn tại trong bộ nhớ máy $\rightarrow$ tự động bỏ qua màn hình chào mừng và **đi thẳng vào màn hình chính (HomeScreen)**. Nếu chưa có mới hiện màn hình tạo sổ.

### **Bước 2: Xây dựng Giao diện Trang chủ (HomeScreen) & Điều hướng 4 Tab**

* Tạo một giao diện chính (có thể dùng `BottomNavigationBar` hoặc `Drawer`) gồm 4 tab tương ứng với 4 trang nghiệp vụ của bạn:

1. **Tab Tài Chính:** Màn hình nhập liệu thu/chi (chọn loại chi phí, số tiền, ghi chú, v.v.).
2. **Tab Sách (Book):** Quản lý sách đang đọc, trạng thái, đánh giá, link PDF.
3. **Tab EQ:** Bảng nhật ký cảm xúc hằng ngày (thể dục, học tập, điều thiện, cảm xúc).
4. **Tab Quotes:** Lưu lại những câu nói hay, trích đoạn sách tâm đắc.

#### **Bước 3: Viết các Service ghi dữ liệu (Append Data) cho từng Tab**

* Sau khi đã có `spreadsheetId`, chúng ta sẽ viết các hàm bổ sung trong `GoogleSheetsService` để đẩy dữ liệu người dùng nhập từ app lên Google Sheets theo thời gian thực:
* Ví dụ: Hàm `addTaiChinhRow(...)` sẽ dùng phương thức `values.append` để tự động đẩy 1 dòng dữ liệu mới vào tab `taichinh`.

---

### 💡 BẠN MUỐN BẮT ĐẦU VỚI VIỆC NÀO TRƯỚC?

1. **Làm cấu hình kiểm tra `spreadsheetId` ở app khởi động** để không phải tạo file trùng lặp nữa?
2. **Thiết kế giao diện Trang chủ (`HomeScreen`)** và các tab chức năng?
3. **Viết Service để thêm dòng dữ liệu (ví dụ: thêm 1 khoản thu chi)** lên Google Sheets?

Bạn muốn chúng ta triển khai bước nào trước nào?

    clientId: '821319113386-bfg3ecujfk0qv4qmfnlp6b48uq3ca41d.apps.googleusercontent.com',
