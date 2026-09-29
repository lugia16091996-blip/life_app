import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;

class GoogleSheetsService {
  static Future<String?> createLifeWorkspace(
    http.Client httpClient,
    String ownerName,
  ) async {
    return null;
  }

  static Future<bool> addFinanceTransaction({
    required http.Client httpClient,
    required String spreadsheetId,
    required String idTaichinh,
    required String loaiChiPhi,
    required String mucDichSuDung,
    required String hangMuc,
    required String taiKhoan,
    required double thanhTien,
    required String ghiChu,
    required String ngayNhap,
    required String thang,
    required String nam,
    required String gmail,
    required String thuChi,
    required String hinhAnh,
  }) async {
    try {
      final sheetsApi = sheets.SheetsApi(httpClient);
      const range = 'taichinh!A:M';

      final List<dynamic> rowValues = [
        idTaichinh,
        loaiChiPhi,
        mucDichSuDung,
        hangMuc,
        taiKhoan,
        thuChi == 'Thu' ? thanhTien.abs() : thanhTien,
        ghiChu,
        ngayNhap,
        int.tryParse(thang) ?? DateTime.now().month,
        int.tryParse(nam) ?? DateTime.now().year,
        gmail,
        thuChi,
        hinhAnh,
      ];

      final valueRange = sheets.ValueRange(values: [rowValues]);

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> debugInspectSheet({
    required http.Client httpClient,
    required String spreadsheetId,
  }) async {
    try {
      final sheetsApi = sheets.SheetsApi(httpClient);
      await sheetsApi.spreadsheets.get(spreadsheetId);
      await sheetsApi.spreadsheets.values.get(spreadsheetId, 'taichinh!A1:M10');
    } catch (e) {
      // Xử lý lỗi ngầm nếu cần
    }
  }

  // 🟢 Đưa hàm safeGet ra ngoài đây để chuẩn cú pháp
  static String _safeGet(List<dynamic> row, int index) {
    if (index < row.length && row[index] != null) {
      return row[index].toString();
    }
    return '';
  }

  static Future<List<Map<String, dynamic>>> getFinanceTransactions({
    required http.Client httpClient,
    required String spreadsheetId,
  }) async {
    try {
      final sheetsApi = sheets.SheetsApi(httpClient);
      const range = 'taichinh!A2:M';

      final response = await sheetsApi.spreadsheets.values.get(
        spreadsheetId,
        range,
      );
      final rows = response.values;
      print('DEBUG: Response trả về thành công.');
      print('DEBUG: rows có bị null không? -> ${rows == null}');
      print('DEBUG: Tổng số dòng thô lấy về = ${rows?.length ?? 0}');

      if (rows == null || rows.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> loadedTransactions = [];

      for (var row in rows) {
        if (row.isNotEmpty) {
          loadedTransactions.add({
            'idTaichinh': _safeGet(row, 0),
            'loaiChiPhi': _safeGet(
              row,
              1,
            ), // 🟢 Đã thêm dấu phẩy ngăn cách chuẩn xác
            'mucDichSuDung': _safeGet(row, 2),
            'hangMuc': _safeGet(row, 3),
            'taiKhoan': _safeGet(row, 4),
            'thanhTien': double.tryParse(_safeGet(row, 5)) ?? 0.0,
            'ghiChu': _safeGet(row, 6),
            'ngayNhap': _safeGet(row, 7),
            'thang': _safeGet(row, 8),
            'nam': _safeGet(row, 9),
            'gmail': _safeGet(row, 10),
            'thuChi': _safeGet(row, 11),
            'hinhAnh': _safeGet(row, 12),
          });
        }
      }

      print(
        'DEBUG: Số lượng giao dịch map thành công = ${loadedTransactions.length}',
      );
      return loadedTransactions;
    } catch (e, stackTrace) {
      // 🟢 In log lỗi chi tiết để không bị nuốt ngầm
      print('❌ LỖI KHI ĐỌC FINANCE TRANSACTIONS: $e');
      print('❌ STACKTRACE: $stackTrace');
      return [];
    }
  }
}
