import 'package:food_xyz_project/repositories.dart';

class DaftarViewModel extends ViewModel {
  final formKey = GlobalKey<FormState>();
  late ApiProvider apiCall;
  final formNamaLengkap = CustomTextFormField(
    displayText: 'Nama lengkap',
    errorMessage: 'Nama lengkap harus diisi',
    controller: TextEditingController(),
  );

  final formUsername = CustomTextFormField(
    displayText: 'Username',
    errorMessage: 'Username harus diisi',
    controller: TextEditingController(),
  );

  final formAlamat = CustomTextFormField(
    displayText: 'Alamat',
    errorMessage: 'Alamat harus diisi',
    controller: TextEditingController(),
  );

  final formNoTelepon = CustomTextFormField(
    displayText: 'No Telepon',
    errorMessage: 'No.Telepon harus diisi',
    inputType: TextInputType.phone,
    controller: TextEditingController(),
  );

  final formPassword = CustomPasswordFormField(
    displayText: 'Password',
    errorMessage: 'Password harus diisi',
    controller: TextEditingController(),
  );

  late CustomPasswordFormField formPasswordConfirmation;

  @override
  void init() {
    super.init();
    apiCall = Get.find<ApiProvider>();
    formPasswordConfirmation = CustomPasswordFormField(
      displayText: 'Konfirmasi password',
      errorMessage: 'Konfirmasi password harus diisi',
      passwordToCheck: formPassword,
      controller: TextEditingController(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    formNamaLengkap.controller!.dispose();
    formUsername.controller!.dispose();
    formAlamat.controller!.dispose();
    formNoTelepon.controller!.dispose();
    formPassword.controller!.dispose();
    formPasswordConfirmation.controller!.dispose();
  }

  void registration() async {
    if (formKey.currentState!.validate()) {
      EasyLoading.show(dismissOnTap: false, status: "Daftar ...",maskType: EasyLoadingMaskType.black);
      try {
        await apiCall.addAccount(
          namaLengkap: formNamaLengkap.controller!.text,
          username: formUsername.controller!.text,
          alamat: formAlamat.controller!.text,
          noTelepon: formNoTelepon.controller!.text,
          password: formPassword.controller!.text,
          passwordConfirm: formPasswordConfirmation.controller!.text,
        );

        await showWarningDialog(
          title: 'Registrasi berhasil',
          icon: Image.asset('assets/images/check.png'),
          texts: ['Akun berhasil dibuat'],
        );

        goToLogin();
      } catch (e) {
        errorHandler(e, warningText: {400: getBadRequest(e)});
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  //kemungkinan akan dipisah --perlu di revisi kembali
  List<String>? getBadRequest(dynamic e) {
    Map<String, dynamic>? rawWarningTexts;
    if (e is Map<String, dynamic> && e['statusCode'] == 400) {
      rawWarningTexts = e['messages'] as Map<String, dynamic>;
    }

    return rawWarningTexts?.entries.map((entry) => '${entry.value}').toList();
  }

  void goToLogin() => Get.back();
}
