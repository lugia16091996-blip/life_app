import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_app/core/services/google_sheets_service.dart';

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  final List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  bool _isLoggedIn = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  List<String> _categories = [
    'Ăn uống',
    'Học phí',
    'Lương',
    'Di chuyển',
    'Nhà cửa',
    'Khác',
  ];

  final Map<String, int> _categoryFrequency = {};

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromPrefs();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signInSilently();
      if (_googleSignIn.currentUser != null) {
        setState(() {
          _isLoggedIn = true;
        });
        await _fetchTransactions();
      }
    } catch (e) {
      // Bỏ qua lỗi silent sign-in nếu chưa từng đăng nhập
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final spreadsheetId = prefs.getString('spreadsheet_id');
      print('DEBUG: spreadsheetId = $spreadsheetId');
      if (spreadsheetId == null) return;

      var httpClient = await _googleSignIn.authenticatedClient();
      print('DEBUG: httpClient = $httpClient');
      if (httpClient == null) return;

      // Gọi hàm service lấy dữ liệu từ Google Sheets về
      final fetchedList = await GoogleSheetsService.getFinanceTransactions(
        httpClient: httpClient,
        spreadsheetId: spreadsheetId,
      );
      print('DEBUG: Tổng số dòng thô lấy về từ Sheets = ${fetchedList.length}');
      if (fetchedList.isNotEmpty) {
        print('DEBUG: Mẫu dữ liệu dòng đầu tiên: ${fetchedList.first}');
      }

      // 🟢 Lọc chỉ lấy những dòng có ID_Taichinh khác null và khác chuỗi rỗng
      final validTransactions = fetchedList
          .where((item) {
            final idVal = item['idTaichinh'];
            if (idVal == null) return false;
            if (idVal.toString().trim().isEmpty) return false;
            return true;
          })
          .map((item) {
            final rawAmount =
                double.tryParse(item['thanhTien']?.toString() ?? '0') ?? 0;

            return {
              'idTaichinh': item['idTaichinh']?.toString() ?? '',
              'category': item['loaiChiPhi']?.toString() ?? 'Khác',
              'type': item['thuChi']?.toString() ?? 'Chi',
              'amount': rawAmount,
              'note': item['ghiChu']?.toString() ?? '',
              'date': item['ngayNhap']?.toString() ?? '',
            };
          })
          .toList();
      print(
        'DEBUG: Số dòng sau khi lọc idTaichinh hợp lệ = ${validTransactions.length}',
      );
      setState(() {
        _transactions.clear();
        _transactions.addAll(validTransactions); // Dùng danh sách đã lọc sạch
      });
    } catch (e, stackTrace) {
      print('DEBUG ERROR khi fetch: $e');
      print('DEBUG STACKTRACE: $stackTrace');
      // Xử lý lỗi nếu có
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        setState(() {
          _isLoggedIn = true;
        });
        await _fetchTransactions();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công: ${user.email}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCategoriesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList('custom_categories');
    if (savedCategories != null && savedCategories.isNotEmpty) {
      setState(() {
        _categories = savedCategories;
      });
    }

    for (var cat in _categories) {
      int count = prefs.getInt('freq_$cat') ?? 0;
      _categoryFrequency[cat] = count;
    }
    _sortCategoriesByFrequency();
  }

  void _sortCategoriesByFrequency() {
    _categories.sort((a, b) {
      int freqA = _categoryFrequency[a] ?? 0;
      int freqB = _categoryFrequency[b] ?? 0;
      return freqB.compareTo(freqA);
    });
  }

  Future<void> _saveCategoriesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_categories', _categories);
    for (var cat in _categories) {
      await prefs.setInt('freq_$cat', _categoryFrequency[cat] ?? 0);
    }
  }

  void _incrementCategoryFrequency(String category) {
    setState(() {
      _categoryFrequency[category] = (_categoryFrequency[category] ?? 0) + 1;
      _sortCategoriesByFrequency();
    });
    _saveCategoriesToPrefs();
  }

  String _formatCurrency(double amount) {
    String s = amount.abs().toInt().toString();
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      count++;
      result = s[i] + result;
      if (count % 3 == 0 && i > 0) {
        result = ',$result';
      }
    }
    return result;
  }

  void _showAddTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    String type = 'Chi';
    String selectedCategory = _categories.isNotEmpty ? _categories[0] : 'Khác';
    String selectedPurpose = 'Cá nhân';
    String selectedHangMuc = 'Cần thiết';
    String selectedAccount = '1. Chi tiêu thiết yếu';

    final DateTime selectedDate = DateTime.now();
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    final List<String> purposes = ['Dùng chung', 'Cá nhân'];
    final List<String> hangMucs = ['Linh hoạt', 'Cần thiết', 'Tiết kiệm'];
    final List<String> accounts = [
      '1. Chi tiêu thiết yếu',
      '2. Hưởng thụ',
      '3. Từ thiện',
      '4. Đầu tư',
      '5. Giáo dục',
      '6. Tiết kiệm dài hạn',
      '7. Khẩn cấp',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm Giao Dịch Mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      items: ['Chi', 'Thu']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) => setDialogState(() => type = val!),
                      decoration: const InputDecoration(labelText: 'Thu Chi'),
                    ),
                    const SizedBox(height: 12),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return _categories;
                        return _categories.where(
                          (c) => c.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        );
                      },
                      onSelected: (selection) => selectedCategory = selection,
                      fieldViewBuilder:
                          (
                            context,
                            textController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            textController.addListener(() {
                              selectedCategory = textController.text.trim();
                            });
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Loại chi phí',
                              ),
                            );
                          },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPurpose,
                      items: purposes
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedPurpose = val!),
                      decoration: const InputDecoration(
                        labelText: 'Mục đích sử dụng',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedHangMuc,
                      items: hangMucs
                          .map(
                            (h) => DropdownMenuItem(value: h, child: Text(h)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedHangMuc = val!),
                      decoration: const InputDecoration(labelText: 'Hạng mục'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAccount,
                      items: accounts
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedAccount = val!),
                      decoration: const InputDecoration(labelText: 'Tài khoản'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Thành Tiền (VNĐ)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hình ảnh minh họa:'),
                        IconButton(
                          onPressed: () async {
                            final image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setDialogState(() => selectedImage = image);
                            }
                          },
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (selectedImage != null)
                      Text(
                        selectedImage!.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final rawAmount =
                        double.tryParse(
                          amountController.text.replaceAll(',', ''),
                        ) ??
                        0;
                    if (rawAmount <= 0 || selectedCategory.isEmpty) return;

                    final double finalAmount = (type == 'Chi')
                        ? -rawAmount
                        : rawAmount;
                    final String idTaichinh =
                        'TX_${DateTime.now().millisecondsSinceEpoch}';
                    final String dateStr =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                    final int month = selectedDate.month;
                    final int year = selectedDate.year;
                    final String gmail =
                        _googleSignIn.currentUser?.email ?? 'unknown@gmail.com';
                    final String imagePath = selectedImage?.name ?? '';

                    _incrementCategoryFrequency(selectedCategory);
                    Navigator.pop(dialogContext);

                    await _saveToSheetsComplete(
                      idTaichinh: idTaichinh,
                      type: type,
                      category: selectedCategory,
                      purpose: selectedPurpose,
                      hangMuc: selectedHangMuc,
                      account: selectedAccount,
                      amount: finalAmount,
                      note: noteController.text,
                      imagePath: imagePath,
                      date: dateStr,
                      month: month,
                      year: year,
                      gmail: gmail,
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveToSheetsComplete({
    required String idTaichinh,
    required String type,
    required String category,
    required String purpose,
    required String hangMuc,
    required String account,
    required double amount,
    required String note,
    required String imagePath,
    required String date,
    required int month,
    required int year,
    required String gmail,
  }) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final spreadsheetId = prefs.getString('spreadsheet_id');

      if (spreadsheetId == null || spreadsheetId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa tìm thấy Spreadsheet ID!')),
        );
        return;
      }

      var httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại!'),
          ),
        );
        setState(() => _isLoggedIn = false);
        return;
      }

      final success = await GoogleSheetsService.addFinanceTransaction(
        httpClient: httpClient,
        spreadsheetId: spreadsheetId,
        idTaichinh: idTaichinh,
        loaiChiPhi: category,
        mucDichSuDung: purpose,
        hangMuc: hangMuc,
        taiKhoan: account,
        thanhTien: amount,
        ghiChu: note,
        ngayNhap: date,
        thang: month.toString(),
        nam: year.toString(),
        gmail: gmail,
        thuChi: type,
        hinhAnh: imagePath,
      );

      if (success) {
        setState(() {
          _transactions.insert(0, {
            'idTaichinh': idTaichinh,
            'date': date,
            'type': type,
            'category': category,
            'amount': amount,
            'note': note,
          });
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu giao dịch lên Google Sheets thành công!'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu giao dịch lên Sheets thất bại!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_sync, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Kết nối tài khoản Google',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mày cần đăng nhập Google một lần để app có quyền đồng bộ dữ liệu vào Google Sheets của mày.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _handleLogin,
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập với Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã kết nối tài khoản: ${_googleSignIn.currentUser?.email ?? ""}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có giao dịch mới trong phiên này.\nBấm nút + bên dưới để thêm mới!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                final isThu = tx['type'] == 'Thu';
                final double amt = tx['amount'] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isThu
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        isThu ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isThu ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      '${tx['category']} : ${_formatCurrency(amt)} VNĐ',
                    ),
                    subtitle: Text('${tx['note']} (${tx['date']})'),
                    trailing: Text(
                      tx['type'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isThu ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
