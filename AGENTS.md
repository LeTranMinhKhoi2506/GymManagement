# Project Context: Flutter Clean Architecture

## 1. Project Type & Goal
Dự án Mobile Flutter (Android/iOS) tập trung vào hiệu năng cao, bảo mật và khả năng mở rộng lâu dài.

## 2. Tech Stack Standard
- **Language**: Dart (Stable version).
- **State Management**: Ưu tiên Riverpod hoặc Provider.
- **Optimization**: Bắt buộc sử dụng `Selector` hoặc `context.select` cho các Widget nằm sâu trong cây thư mục để tránh rebuild lãng phí.
- **Local Storage**: SQLite (cho dữ liệu lớn), SharedPreferences (cho settings) và sau khi hoàn thành project hãy kêt nối tới firebase để có thể lưu dữ liệu trên cloud.
- **Networking**: Sử dụng Dio thông qua lớp Repository.

## 3. Implementation Standards (Quy tắc bắt buộc)
- **Separation of Concerns**: Tuyệt đối không viết Business Logic bên trong Widget. Logic phải nằm ở Controller/Provider.
- **Async Handling**: Mọi tác vụ bất đồng bộ phải bọc trong khối `try-catch` và có thông báo lỗi cho người dùng.
- **Resource Management**: Luôn giải phóng (dispose) các Controller, Stream, hoặc Listeners khi Widget bị hủy.
- **Clean Code**: Ưu tiên sử dụng `const` Widgets và đặt tên file theo `snake_case`.

## 4. Required Folder Structure (Feature-based)
Nếu là dự án mới, hãy tuân thủ cấu trúc thư mục sau:

lib/
├── app/                  # Các cấu hình chung: Route, Theme, Database
├── features/             # (Nâng cấp) Chia theo tính năng (Expense, Auth, Charity...)
│   ├── [feature_name]/
│   │   ├── data/         # Models, Repositories, DTOs
│   │   ├── domain/       # Entities, Usecases
│   │   └── presentation/ # Screens, Widgets, Providers/Controllers
├── common/               # Widget dùng chung, Styles, Utils
├── services/             # Firebase, Cloud, API Services
└── main.dart             # Điểm khởi đầu ứng dụng

*Lưu ý: Nếu dự án hiện tại đã có cấu trúc khác, hãy duy trì tính đồng bộ với cấu trúc đó.*