import 'dart:developer';

import 'package:food_xyz_project/repositories.dart';

class InvoiceViewModel extends ViewModel {
  final List<CartModel> cart = [];
  int _totalBayar = 0;
  late ApiProvider apiCall;
  final tokenStorage = const FlutterSecureStorage();

  @override
  void init() {
    apiCall = Get.find<ApiProvider>();
    if (Get.arguments[0] is! List<CartModel>) {
      log("Get.arguments[0] : Expecting List<CartModel> but got ${Get.arguments[0].runtimeType}");
    } else {
      cart.addAll(Get.arguments[0]);
    }

    if (Get.arguments[1] is! int) {
      log("Get.arguments[1] : Expecting int but got ${Get.arguments[1].runtimeType}");
    } else {
      _totalBayar = Get.arguments[1];
    }
  }

  String getTotalBayarInRupiah() {
    return intToRupiah(_totalBayar);
  }

  //revisi nama, fungsi ini akan mengembalikan sebuah hasil boolean, di karenakan screen ini dipanggil di main_menu/browser
  void close({bool isSaved = false}) => Get.back(result: isSaved);

  //perlu revisi kembali terutama penamaan
  //intinya ambil dari var cart dan masukan kedalam barisTabelProduk
  //DataTable di view mengambil List<DataRow>
  List<DataRow> setRow() {
    List<DataRow> barisTabelProduk = [];
    for (int n = 0; n < cart.length; n++) {
      barisTabelProduk.add(
        DataRow(
          cells: <DataCell>[
            DataCell(
              Center(
                child: Text(
                  cart[n].produk.namaProduk,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  intToRupiah(cart[n].produk.hargaProduk),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  cart[n].qty.toString(),
                ),
              ),
            ),
            DataCell(
              Center(
                child: Text(
                  intToRupiah(cart[n].produk.hargaProduk * cart[n].qty),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return barisTabelProduk;
  }

  void shareInvoice() async {
    try {
      EasyLoading.show(
        dismissOnTap: false,
        status: "Making Invoice ...",
        maskType: EasyLoadingMaskType.black,
      );
      String? token = await tokenStorage.read(key: "accessToken");
      if (token == null) {
        throw AppError.tokenNotFound;
      }

      UserModel userProfile =
          UserModel.fromJson(await apiCall.getProfile(token));
      await Printing.sharePdf(
          bytes: await InvoiceToPdf.fromCart(cart, userProfile, _totalBayar),
          filename: "Foodxyz-Invoice-(${userProfile.namaLengkap}).pdf");
    } catch (e) {
      errorHandler(e);
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> saveInvoice() async {
    bool confirmed = await showConfirmDialog(texts: ["Tuntaskan Transaksi??"]);
    if (confirmed) {
      try {
        EasyLoading.show(
          dismissOnTap: false,
          status: "Saving invoice ...",
          maskType: EasyLoadingMaskType.black,
        );

        String? token = await tokenStorage.read(key: "accessToken");
        if (token == null) {
          throw AppError.tokenNotFound;
        }

        UserModel userProfile =
            UserModel.fromJson(await apiCall.getProfile(token));

        await apiCall.createLogTransaksi(cart, _totalBayar, token);
        await showWarningDialog(
          title: 'Transaksi berhasil',
          icon: Image.asset('assets/images/check.png'),
          texts: ['Transaksi anda sudah dicatat'],
        );

        bool confirmed = await showConfirmDialog(
            title: "Invoice", texts: ["Lihat Preview Catatan Pembayaran?"]);

        if (confirmed) {
          await Get.toNamed(Routes.pdfPreview, arguments: [
            await InvoiceToPdf.fromCart(cart, userProfile, _totalBayar)
          ]);
        }

        close(isSaved: true);
      } catch (e) {
        errorHandler(e);
      } finally {
        if (EasyLoading.isShow) EasyLoading.dismiss();
      }
    }
  }
}
