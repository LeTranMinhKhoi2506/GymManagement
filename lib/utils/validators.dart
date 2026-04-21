class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập họ tên";
    }
    if (value.trim().length < 2) {
      return "Họ tên quá ngắn";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Vui lòng nhập email";
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return "Email không đúng định dạng";
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Không bắt buộc
    }
    final phoneRegExp = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    if (!phoneRegExp.hasMatch(value.trim())) {
      return "Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0)";
    }
    return null;
  }

  static String? validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Không bắt buộc
    }
    final salary = double.tryParse(value);
    if (salary == null || salary < 0) {
      return "Mức lương không hợp lệ";
    }
    return null;
  }
}
