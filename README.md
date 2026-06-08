# KINETIC - Hệ Thống Quản Lý Và Vận Hành Phòng Gym

Kinetic là một hệ thống quản lý phòng gym toàn diện, hỗ trợ quản trị viên quản lý tài chính, nhân sự, lịch làm việc, thiết bị và phản hồi khách hàng thông qua nền tảng Web Admin. Đồng thời cung cấp giao diện di động (Android) giúp hội viên quét mã QR check-in, quản lý lịch tập, đăng ký gói tập và tương tác với huấn luyện viên cá nhân.

---

## 1. Công nghệ sử dụng
Hệ thống được xây dựng trên các nền tảng và công nghệ hiện đại sau:
*   **Flutter** (Framework phát triển giao diện ứng dụng đa nền tảng)
*   **Dart** (Ngôn ngữ lập trình chính cho toàn bộ logic)
*   **Firebase Suite**:
    *   **Firebase Authentication**: Quản lý tài khoản, xác thực người dùng (Đăng nhập Email/Mật khẩu & Google Sign-In).
    *   **Cloud Firestore**: Cơ sở dữ liệu tài liệu NoSQL thời gian thực lưu trữ thông tin hệ thống.
    *   **Firebase Storage**: Lưu trữ tệp tin đa phương tiện, hình ảnh thiết bị, sản phẩm và bài đăng.
*   **State Management (Quản lý trạng thái)**: `Provider` giúp quản lý luồng dữ liệu sạch và hiệu quả.
*   **Navigation & Routing (Định tuyến)**: `GoRouter` quản lý định tuyến phân hệ thông minh, bảo mật trang Admin Web.
*   **Data Export (Kết xuất báo cáo)**: Thư viện `excel` hỗ trợ xuất báo cáo tài chính chi tiết và nhật ký làm việc của nhân viên sang định dạng `.xlsx`.
*   **Charts (Biểu đồ)**: `FL Chart` trực quan hóa doanh thu và chi phí dưới dạng biểu đồ đường và biểu đồ tròn.

---

## 2. Phiên bản Flutter & Dart sử dụng
*   **Dart SDK**: `^3.11.0` (Tương thích với Flutter 3.31.0 trở lên)
*   **Flutter SDK**: `3.31.x` hoặc mới hơn
*   **Thiết bị chạy khuyên dùng**: 
    *   **Web Admin**: Trình duyệt Google Chrome hoặc Microsoft Edge (chạy trên Desktop để tối ưu giao diện lớn).
    *   **Mobile Customer**: Thiết bị Android hoặc Emulator Android.

---

## 3. Các bước cài đặt và chạy project

### Bước 1: Tải mã nguồn về máy
```bash
git clone <repository_url_cua_ban>
cd GymManagament
```

### Bước 2: Cài đặt các thư viện phụ thuộc (Dependencies)
```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase
*(Xem hướng dẫn cấu hình chi tiết ở **Mục 7** bên dưới. Đảm bảo đã đặt tệp cấu hình `google-services.json` vào đúng vị trí).*

### Bước 4: Chạy dự án
*   **Chạy Web Admin (Khuyên dùng trình duyệt Google Chrome hoặc Microsoft Edge):**
    *   Chạy bằng Google Chrome:
        ```bash
        flutter run -d chrome
        ```
    *   Chạy bằng Microsoft Edge:
        ```bash
        flutter run -d edge
        ```
*   **Chạy Mobile (Giao diện khách hàng Kinetic, quét mã check-in):**
    ```bash
    flutter run -d <device_id_hoac_emulator>
    ```

---

## 4. Các Package/Dependency quan trọng cần cài
Dự án tự động cài đặt các thư viện được khai báo trong `pubspec.yaml`, bao gồm:
*   `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`: Bộ công cụ dịch vụ đám mây Backend.
*   `google_sign_in`: Tích hợp đăng nhập nhanh bằng tài khoản Google.
*   `provider`: Quản lý trạng thái và Dependency Injection.
*   `go_router`: Điều hướng phân hệ, bảo vệ phân quyền Admin.
*   `excel`: Xây dựng tệp báo cáo tài chính và bảng công nhân viên.
*   `fl_chart`: Thống kê doanh thu, chi phí, lợi nhuận trực quan.
*   `intl`: Quốc tế hóa ngôn ngữ Việt Nam, hiển thị múi giờ, định dạng tiền tệ `₫ (VND)`.
*   `share_plus`, `path_provider`: Hỗ trợ lưu và chia sẻ file báo cáo trên Mobile.

---

## 5. Danh sách tài khoản thử nghiệm (Test Accounts)
Sau khi kết nối và nạp dữ liệu mẫu vào Firebase, bạn có thể sử dụng các tài khoản sau để kiểm tra tính năng phân quyền:

| Email | Mật khẩu mẫu | Vai trò (Role) | Chức năng truy cập |
| :--- | :--- | :--- | :--- |
| **admin@kinetic.com** | `123456` | **admin** | Truy cập toàn bộ tính năng Web Admin (Quản lý thu chi, lương, lịch làm việc, thiết bị, phản hồi). |
| **receptionist.mai@kinetic.com** | `123456` | **receptionist** | Đăng nhập giao diện lễ tân (Check-in nhanh hội viên, POS bán hàng, quản lý hội viên). |
| **pt.hung@kinetic.com** | `123456` | **trainer** | Giao diện Huấn luyện viên cá nhân (Theo dõi lịch dạy, danh sách học viên phụ trách). |
| **customer.minh@gmail.com** | `123456` | **user** | Đăng nhập App di động dành cho hội viên (Đặt lịch, mua gói tập, xem tin tức). |

*Chú ý:* Khi liên kết với dự án Firebase mới hoàn toàn trống, các tài khoản trên chưa tồn tại trong Firebase Authentication của bạn. Để kích hoạt tài khoản Admin đầu tiên và gieo mầm dữ liệu hệ thống, hãy thực hiện một trong hai cách dưới đây:

#### Cách 1: Đăng ký qua ứng dụng di động và nâng quyền trong Firestore Console (Khuyên dùng)
1. **Đăng ký**: Mở ứng dụng khách hàng (Mobile) và đăng ký một tài khoản mới bằng email (ví dụ: `admin@kinetic.com`).
2. **Cấp quyền Admin**: Vào **Firebase Console** -> **Firestore Database** -> Tìm collection `users` -> Tìm document tương ứng với email vừa đăng ký -> Đổi giá trị trường `role` từ `"user"` thành `"admin"` và lưu lại.
3. **Nạp dữ liệu mẫu**: 
   * Truy cập trang Web Admin tại đường dẫn `/admin/login` và đăng nhập bằng tài khoản này.
   * Chuyển đến phần **Hệ thống** -> **Công cụ phát triển (Developer Tool)**.
   * Click chọn **"Nạp toàn bộ dữ liệu mặc định"**. Hệ thống sẽ tự động gieo mầm tất cả các dữ liệu mẫu khác (bao gồm các tài khoản Lễ tân, PT, Hội viên và lịch sử giao dịch).

#### Cách 2: Khởi tạo thủ công từ Firebase Console
1. **Tạo tài khoản Authentication**: Vào **Firebase Console -> Authentication -> Users** -> Click **Add user** -> Tạo tài khoản `admin@kinetic.com` với mật khẩu của bạn (ví dụ: `123456`). Sao chép lại mã **User UID** được tạo ra.
2. **Tạo bản ghi trong Firestore**: Vào **Firestore Database** -> Tạo collection tên `users` -> Tạo một document mới có ID trùng khớp chính xác với mã **User UID** vừa copy, sau đó thêm các trường dữ liệu:
   * `uid` (String): [Dán User UID vào đây]
   * `email` (String): `admin@kinetic.com`
   * `fullName` (String): `Lê Trần Minh Khôi` (hoặc tên tùy chọn)
   * `role` (String): `admin`
   * `status` (String): `active`
   * `createdAt` (Timestamp): [Thời gian hiện tại]
3. **Đăng nhập**: Sử dụng thông tin trên để đăng nhập trực tiếp trên Web Admin.


---

## 6. Các lưu ý cần thiết để project hoạt động tốt
1.  **Chế độ xác thực Web vs Mobile**:
    *   Hệ thống tự động phát hiện nền tảng Web để chuyển hướng người dùng chưa đăng nhập về cổng **Admin Login** (`/admin/login`). Trên Mobile, trang mặc định là **Customer Login** (`/login`).
2.  **Đăng nhập bằng Google**:
    *   Để chạy Google Sign-In trên Web, bạn phải cấu hình **Authorized redirect URIs** (ví dụ: `http://localhost:<port>`) trong Cài đặt nhà cung cấp Google của Firebase Auth.
    *   Để chạy trên Android, bạn cần lấy mã băm SHA-1 từ máy phát triển của mình và điền vào cài đặt ứng dụng Android trên Firebase Console.
3.  **Tải Excel**:
    *   Tính năng tải Excel báo cáo tài chính và công nhân viên đã được tối ưu hóa sử dụng `.encode()` kết hợp với Blob tải xuống để **chỉ tải xuống duy nhất một tệp tin** có tên cụ thể (không bị tải thừa tệp trống mặc định `FlutterExcel.xlsx` từ thư viện).
4.  **Không có cấu hình iOS**: Hệ thống chỉ tối ưu hóa chạy trên nền tảng **Android** và **Web**, bỏ qua các cấu hình Firebase và kiểm thử trên iOS theo định hướng phát triển.

---

## 7. Hướng dẫn cấu hình Firebase (Chỉ dành cho Android & Web)
Do hệ thống không sử dụng nền tảng iOS, bạn chỉ cần liên kết Firebase cho Android và Web.

### 7.1 Cung cấp tệp tin cấu hình Firebase:
*   **Android**: Đặt tệp cấu hình `google-services.json` tải về từ Firebase Console vào thư mục:
    `[Root_Project]/android/app/google-services.json`
*   **Web**: Cấu hình Firebase Web được tích hợp trực tiếp thông qua tệp `lib/firebase_options.dart` khi khởi tạo ứng dụng.

### 7.2 Hướng dẫn thiết lập Firebase từ đầu (Nếu không tải tệp cấu hình sẵn có):
1.  Truy cập [Firebase Console](https://console.firebase.google.com/), tạo một dự án mới tên `Kinetic Gym`.
2.  Bật tính năng **Authentication** (Kích hoạt phương thức đăng nhập **Email/Password** và **Google**).
3.  Bật cơ sở dữ liệu **Cloud Firestore** và dịch vụ lưu trữ **Firebase Storage**.
4.  Cài đặt FlutterFire CLI trên máy tính của bạn:
    ```bash
    dart pub global activate flutterfire_cli
    ```
5.  Thực hiện cấu hình liên kết dự án (lệnh này tự sinh file cấu hình Web và tải file cấu hình Android):
    ```bash
    flutterfire configure --project=<ten-du-an-firebase-cua-ban> --platforms=android,web
    ```

---

## 8. Thông tin cấu trúc Firestore (Collection & Document mẫu)
Hệ thống sử dụng các Collection chính sau trên Cloud Firestore:

### 8.1 Collection `users` (Thông tin người dùng và phân quyền)
*   **Document ID**: Trùng với `uid` được tạo từ Firebase Authentication.
*   **Cấu trúc dữ liệu:**
    ```json
    {
      "uid": "admin_uid_01",
      "email": "admin@kinetic.com",
      "fullName": "Lê Trần Minh Khôi",
      "role": "admin", // admin | trainer | receptionist | user
      "status": "active",
      "phoneNumber": "0901234567",
      "address": "123 Đường 3/2, Quận 10, TP.HCM",
      "gender": "Nam",
      "createdAt": "Timestamp"
    }
    ```

### 8.2 Collection `members` (Thông tin chi tiết Hội viên phòng tập)
*   **Document ID**: Trùng với `uid` của người dùng.
*   **Cấu trúc dữ liệu:**
    ```json
    {
      "fullName": "Nguyễn Hoàng Minh",
      "email": "customer.minh@gmail.com",
      "phoneNumber": "0945678901",
      "membershipType": "Standard 1 Month",
      "status": "Active", // Active | Inactive | Expired
      "isCurrentlyTraining": true,
      "nextRenewal": "Timestamp",
      "memberSince": "Timestamp",
      "ltv": 1500000.0
    }
    ```

### 8.3 Các Collection khác:
*   `membership_plans`: Danh sách các gói tập phòng gym (Tên gói, giá tiền, thời hạn).
*   `transactions`: Lịch sử giao dịch thu (doanh thu bán gói, sản phẩm) và chi (vận hành, bảo trì).
*   `payments`: Hóa đơn đóng phí hội viên.
*   `payroll`: Bảng tính lương cho nhân viên phòng tập.
*   `schedules`: Lịch phân ca và nhiệm vụ của nhân viên/huấn luyện viên.
*   `equipment`: Danh sách thiết bị tập luyện (Tên máy, khu vực, trạng thái bảo dưỡng).
*   `feedbacks`: Phản hồi, góp ý gửi từ ứng dụng khách hàng.

---

## 9. Cấu hình Quy tắc bảo mật Firebase (Firebase Rules)

### 9.1 Firestore Security Rules (`firestore.rules`)
Vui lòng sao chép và dán cấu hình này vào mục **Rules** của Cloud Firestore trên Firebase Console:
```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Đọc ghi tài khoản cá nhân
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Chỉ Admin mới có quyền cập nhật bảng giao dịch, hóa đơn và lương
    match /transactions/{txId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /payments/{payId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /payroll/{rollId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Cho phép đọc/ghi các collection khác nếu đã đăng nhập thành công
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 9.2 Firebase Storage Rules (`storage.rules`)
Vui lòng cấu hình Storage Rules trên Firebase Console như sau:
```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Yêu cầu xác thực người dùng đã đăng nhập để tải lên/đọc tệp tin hình ảnh
      allow read, write: if request.auth != null;
    }
  }
}
```
