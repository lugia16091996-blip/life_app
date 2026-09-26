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
        thuChi == 'Thu'
            ? thanhTien.abs()
            : thanhTien, // 🟢 Đã sửa từ 'thang' thành 'thuChi' chuẩn xác
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

  static Future<List<Map<String, dynamic>>> getFinanceTransactions({
    required http.Client httpClient,
    required String spreadsheetId,
  }) async {
    try {
      final sheetsApi = sheets.SheetsApi(httpClient);
      // Lấy từ dòng 2 trở đi để bỏ qua dòng tiêu đề (header) ở dòng 1
      const range = 'taichinh!A:M';

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
        // Đảm bảo row có đủ phần tử để tránh lỗi Out of bounds
        // Thứ tự mảng lúc ghi: [id, loaiChiPhi, mucDich, hangMuc, taiKhoan, thanhTien, ghiChu, ngayNhap, thang, nam, gmail, thuChi, hinhAnh]
        if (row.isNotEmpty) {
          loadedTransactions.add({
            'idTaichinh': row[0]?.toString() ?? '',
            'loaiChiPhi': row[1]?.toString() ?? '',
            'mucDichSuDung': row[2]?.toString() ?? '',
            'hangMuc': row[3]?.toString() ?? '',
            'taiKhoan': row[4]?.toString() ?? '',
            'thanhTien': double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
            'ghiChu': row[6]?.toString() ?? '',
            'ngayNhap': row[7]?.toString() ?? '',
            'thang': row[8]?.toString() ?? '',
            'nam': row[9]?.toString() ?? '',
            'gmail': row[10]?.toString() ?? '',
            'thuChi': row[11]?.toString() ?? '',
            'hinhAnh': row[12]?.toString() ?? '',
          });
        }
      }

      return loadedTransactions;
    } catch (e) {
      return [];
    }
  }
}
