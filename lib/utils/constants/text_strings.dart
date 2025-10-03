class FTexts {
  // -- OnBoarding Texts
  static const String onBoardingTitle1 = "Listen Anywhere, Anytime";
  static const String onBoardingTitle2 = "Discover New Sounds";
  static const String onBoardingTitle3 = "Create Your Vibe";

  // OnBoarding SubTitles
  static const String onBoardingSubTitle1 =
      "Enjoy your favorite tracks wherever you go. Music without limits, always with you.";
  static const String onBoardingSubTitle2 =
      "Find trending hits, hidden gems, and personalized playlists tailored just for you.";
  static const String onBoardingSubTitle3 =
      "Build playlists, set the mood, and let your music define every moment.";

  // -- Authentication Form Text
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String email = "E-Mail";
  static const String password = "Password";
  static const String newPassword = "New Password";
  static const String username = "Username";
  static const String phoneNo = "Phone Number";
  static const String forgotPassword = "Forget Password?";
  static const String signIn = "Sign In";
  static const String createAccount = "Create Account";
  static const String orSignInWith = "or sign in with";
  static const String orSignUpWith = "or sign up with";
  static const String iAgreeTo = "I agree to";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsOfUse = "Terms of use";
  static const String verificationCode = "verificationCode";
  static const String resendEmail = "Resend Email";
  static const String resendEmailIn = "Resend email in";

  // -- Login Screen Text
  static const String loginTitle = "Welcome Back,";
  static const String loginSubTitle =
      "Make it work, make it right, make it fast.";
  static const String rememberMe = "Remember Me?";
  static const String dontHaveAnAccount = "Don't have an Account";
  static const String enterYour = "Enter your";
  static const String resetPassword = "Reset Password";
  static const String or = "OR";
  static const String connectWith = "Connect With";
  static const String facebook = "Facebook";
  static const String phoneNumber = "Phone Number";
  static const String google = "Google";

  // Validation
  static const String dateOfBirthError = "You must be at least 18 years old.";
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
}
