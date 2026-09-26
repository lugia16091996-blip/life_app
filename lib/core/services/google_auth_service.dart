import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'google_sheets_service.dart';

class GoogleAuthService {
  static String _getTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";
  }

  static final _googleSignIn = GoogleSignIn(
    // ⚠️ Đảm bảo Client ID của bạn đã điền đầy đủ vào đây
    clientId: '821319113386-bfg3ecujfk0qv4qmfnlp6b48uq3ca41d.apps.googleusercontent.com',
    scopes: [drive.DriveApi.driveFileScope, sheets.SheetsApi.spreadsheetsScope],
  );

  // 1. Hàm kiểm tra đăng nhập ngầm (không hiện popup nếu đã từng đăng nhập)
  static Future<GoogleSignInAccount?> trySilentSignIn() async {
    try {
      print('[${_getTime()}] 🔄 Đang thử khôi phục phiên đăng nhập ngầm...');
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        print(
          '[${_getTime()}] ✅ Khôi phục phiên đăng nhập thành công: ${account.email}',
        );
      } else {
        print(
          '[${_getTime()}] ℹ️ Không tìm thấy phiên đăng nhập ngầm trước đó.',
        );
      }
      return account;
    } catch (e) {
      print('[${_getTime()}] ⚠️ Lỗi khi thử đăng nhập ngầm: $e');
      return null;
    }
  }

  // 2. Hàm đăng nhập và tạo Sổ Quản Lý mới trên Drive
  static Future<String?> createLifeWorkspaceInUserDrive(
    String ownerName,
  ) async {
    print(
      '\n[${_getTime()}] 🔑 [BẮT ĐẦU] Người dùng bấm tạo sổ với tên: "$ownerName"',
    );

    try {
      // Yêu cầu người dùng đăng nhập (hiện popup)
      print('[${_getTime()}] ⏳ Đang mở cửa sổ đăng nhập Google OAuth...');
      final account = await _googleSignIn.signIn();

      if (account == null) {
        print('[${_getTime()}] ⚠️ Người dùng đã hủy cửa sổ đăng nhập!');
        return null;
      }

      print('[${_getTime()}] ✅ Đã xác thực thành công Gmail: ${account.email}');

      // Tạo Authenticated HTTP Client cho Google APIs
      print('[${_getTime()}] 🔄 Đang tạo Authenticated HTTP Client...');
      final authClient = await _googleSignIn.authenticatedClient();

      if (authClient == null) {
        print('[${_getTime()}] ❌ Không thể tạo HTTP Client đã xác thực!');
        return null;
      }

      // Gọi GoogleSheetsService để tạo file & bơm tiêu đề
      final spreadsheetId = await GoogleSheetsService.createLifeWorkspace(
        authClient,
        ownerName,
      );

      return spreadsheetId;
    } catch (e, stackTrace) {
      print('[${_getTime()}] ❌ [LỖI AUTHENTICATION]: $e');
      print('📌 StackTrace: $stackTrace');
      return null;
    }
  }
}
