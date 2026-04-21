// ═══════════════════════════════════════════════════════════════
// NexVolt — App Strings (3 languages)
// NO code generation needed. Works immediately.
// Usage in any screen:
//   final s = AppStrings.of(context);
//   Text(s.loginTitle)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppStrings {
  final String languageCode;
  const AppStrings(this.languageCode);

  // ── Get strings for current locale ───────────────────────
  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AppStrings(code);
  }

  // ── Helper ────────────────────────────────────────────────
  String _t(String en, String si, String ta) {
    if (languageCode == 'si') return si;
    if (languageCode == 'ta') return ta;
    return en;
  }

  // ══════════════════════════════════════════════════════════
  // APP
  // ══════════════════════════════════════════════════════════
  String get appName => 'NexVolt';

  String get appTagline => _t(
    'EV Charging · Booking · Navigation',
    'EV චාර්ජිං · වෙන්කරවීම · නාවිගේෂන්',
    'EV சார்ஜிங் · முன்பதிவு · வழிசெலுத்தல்',
  );

  // ══════════════════════════════════════════════════════════
  // LANGUAGE SELECTION
  // ══════════════════════════════════════════════════════════
  String get langSelectTitle =>
      _t('Select Language', 'භාෂාව තෝරන්න', 'மொழியை தேர்ந்தெடுக்கவும்');

  String get langSelectSubtitle => _t(
    'Choose your preferred language to continue',
    'ඔබේ කැමති භාෂාව තෝරන්න',
    'தொடர உங்கள் விருப்பமான மொழியை தேர்ந்தெடுக்கவும்',
  );

  String get langContinue => _t('Continue', 'ඉදිරියට', 'தொடர்க');

  String get langErrorSelect => _t(
    'Please select a language',
    'භාෂාවක් තෝරන්න',
    'ஒரு மொழியை தேர்ந்தெடுக்கவும்',
  );

  // ══════════════════════════════════════════════════════════
  // WELCOME
  // ══════════════════════════════════════════════════════════
  String get welcomeGetStarted => _t('Get Started', 'ආරම්භ කරන්න', 'தொடங்குக');

  String get welcomeSkip => _t('Skip', 'මඟ හරින්න', 'தவிர்');

  String get welcomeNext => _t('Next', 'ඊළඟ', 'அடுத்து');

  String get welcome1Title => _t(
    'Find Charging Spots',
    'චාර්ජිං ස්ථාන සොයන්න',
    'சார்ஜிங் இடங்களை கண்டறியுங்கள்',
  );

  String get welcome1Subtitle => _t(
    'Discover EV charging stations near you on an interactive map.',
    'අන්තර්ක්‍රියාකාරී සිතියමෙන් ආසන්නතම EV චාර්ජිං ස්ථාන සොයන්න.',
    'ஊடாடும் வரைபடத்தில் அருகிலுள்ள EV சார்ஜிங் நிலையங்களை கண்டறியுங்கள்.',
  );

  String get welcome2Title =>
      _t('Book Instantly', 'ක්ෂණිකව වෙන්කරවන්න', 'உடனே முன்பதிவு செய்க');

  String get welcome2Subtitle => _t(
    'Reserve your charging slot in advance — skip the wait.',
    'කලින් ඔබේ චාර්ජිං තව් ස්ථානය රක්ෂා කරන්න.',
    'முன்கூட்டியே உங்கள் சார்ஜிங் இடத்தை முன்பதிவு செய்யுங்கள்.',
  );

  String get welcome3Title =>
      _t('Charge & Go', 'චාර්ජ් කර යන්න', 'சார்ஜ் செய்து செல்லுங்கள்');

  String get welcome3Subtitle => _t(
    'Track your session live and pay seamlessly in-app.',
    'සජීවීව ඔබේ සැසිය නිරීක්ෂණය කර යෙදුම තුළ ගෙවන්න.',
    'நேரடியாக உங்கள் அமர்வை கண்காணித்து பயன்பாட்டிலேயே பணம் செலுத்துங்கள்.',
  );

  // ══════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════
  String get loginTitle => _t('Login', 'පිවිසෙන්න', 'உள்நுழைக');

  String get loginEmail => _t('Email', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல்');

  String get loginPassword => _t('Password', 'මුරපදය', 'கடவுச்சொல்');

  String get loginButton => _t('Login', 'පිවිසෙන්න', 'உள்நுழைக');

  String get loginForgotPassword =>
      _t('Forgot Password?', 'මුරපදය අමතකද?', 'கடவுச்சொல் மறந்தீர்களா?');

  String get loginNewUser =>
      _t("Don't have an account? ", 'ගිණුමක් නැද්ද? ', 'கணக்கு இல்லையா? ');

  String get loginRegisterLink =>
      _t('Register', 'ලියාපදිංචි වන්න', 'பதிவு செய்க');

  String get loginResetTitle =>
      _t('Reset Password', 'මුරපදය යළි සකසන්න', 'கடவுச்சொல் மீட்டமைக்க');

  String get loginResetHint => _t(
    'Enter your email',
    'ඔබේ විද්‍යුත් තැපෑල ඇතුළත් කරන්න',
    'உங்கள் மின்னஞ்சலை உள்ளிடுக',
  );

  String get loginResetSend => _t('Send', 'යවන්න', 'அனுப்பு');

  String get loginResetCancel => _t('Cancel', 'අවලංගු කරන්න', 'ரத்து செய்');

  String get loginResetSuccess => _t(
    'Password reset email sent!',
    'මුරපද යළි සැකසීමේ ඊමේල් එව්වා!',
    'கடவுச்சொல் மீட்டமைப்பு மின்னஞ்சல் அனுப்பப்பட்டது!',
  );

  String get loginErrorEmpty => _t(
    'Please enter email and password',
    'විද්‍යුත් තැපෑල සහ මුරපදය ඇතුළත් කරන්න',
    'மின்னஞ்சல் மற்றும் கடவுச்சொல்லை உள்ளிடுக',
  );

  String get loginErrorInvalid => _t(
    'Email or password is incorrect.',
    'විද්‍යුත් තැපෑල හෝ මුරපදය වැරදිය.',
    'மின்னஞ்சல் அல்லது கடவுச்சொல் தவறானது.',
  );

  String get loginErrorNoUser => _t(
    'No account found with this email.',
    'මෙම විද්‍යුත් තැපෑලෙන් ගිණුමක් හමු නොවීය.',
    'இந்த மின்னஞ்சலில் கணக்கு எதுவும் இல்லை.',
  );

  String get loginErrorDisabled => _t(
    'This account has been disabled.',
    'මෙම ගිණුම අක්‍රිය කර ඇත.',
    'இந்த கணக்கு முடக்கப்பட்டுள்ளது.',
  );

  String get loginErrorTooMany => _t(
    'Too many attempts. Try again later.',
    'උත්සාහයන් ගොඩක්. පසුව නැවත උත්සාහ කරන්න.',
    'அதிக முயற்சிகள். பிறகு முயற்சிக்கவும்.',
  );

  String get loginErrorNetwork => _t(
    'No internet connection.',
    'අන්තර්ජාල සම්බන්ධතාවක් නැත.',
    'இணைய இணைப்பு இல்லை.',
  );

  // ══════════════════════════════════════════════════════════
  // REGISTER
  // ══════════════════════════════════════════════════════════
  String get registerTitle =>
      _t('Create Account', 'ගිණුමක් සාදන්න', 'கணக்கு உருவாக்கு');

  String get registerSubtitle => _t(
    'Fill your details to get started',
    'ඔබේ විස්තර පුරවන්න',
    'உங்கள் விவரங்களை நிரப்பவும்',
  );

  String get registerFirstName => _t('First Name', 'මුල් නම', 'முதல் பெயர்');

  String get registerLastName => _t('Last Name', 'අවසන් නම', 'கடைசி பெயர்');

  String get registerEmail =>
      _t('Email Address', 'විද්‍යුත් තැපෑල', 'மின்னஞ்சல் முகவரி');

  String get registerPhone => _t('Phone Number', 'දුරකථන අංකය', 'தொலைபேசி எண்');

  String get registerPassword => _t('Password', 'මුරපදය', 'கடவுச்சொல்');

  String get registerConfirmPassword => _t(
    'Confirm Password',
    'මුරපදය තහවුරු කරන්න',
    'கடவுச்சொல்லை உறுதிப்படுத்துக',
  );

  String get registerButton =>
      _t('Create Account', 'ගිණුම සාදන්න', 'கணக்கு உருவாக்கு');

  String get registerAlreadyHave => _t(
    'Already have an account? ',
    'දැනටමත් ගිණුමක් තිබේද? ',
    'ஏற்கனவே கணக்கு உள்ளதா? ',
  );

  String get registerLoginLink => _t('Login', 'පිවිසෙන්න', 'உள்நுழைக');

  String get registerRequired => _t('Required', 'අවශ්‍යයි', 'தேவை');

  String get registerEmailValid => _t(
    'Enter a valid email address',
    'වලංගු විද්‍යුත් තැපෑලක් ඇතුළත් කරන්න',
    'சரியான மின்னஞ்சலை உள்ளிடுக',
  );

  String get registerPhoneMin => _t(
    'Enter a valid 9-10 digit number',
    'වලංගු ඉලක්කම් 9-10 අංකයක් ඇතුළත් කරන්න',
    'சரியான 9-10 இலக்க எண்ணை உள்ளிடுக',
  );

  String get registerPassMin => _t(
    'Minimum 6 characters required',
    'අවම අකුරු 6ක් අවශ්‍යයි',
    'குறைந்தது 6 எழுத்துகள் தேவை',
  );

  String get registerPassMatch => _t(
    'Passwords do not match',
    'මුරපද නොගැළපේ',
    'கடவுச்சொற்கள் பொருந்தவில்லை',
  );

  String get registerErrorEmailUsed => _t(
    'This email is already registered. Please login.',
    'මෙම විද්‍යුත් තැපෑල දැනටමත් ලියාපදිංචි වී ඇත.',
    'இந்த மின்னஞ்சல் ஏற்கனவே பதிவு செய்யப்பட்டுள்ளது.',
  );

  String get registerErrorWeakPass => _t(
    'Password too weak. Use at least 6 characters.',
    'මුරපදය දුර්වලය. අඩුම අකුරු 6ක් භාවිතා කරන්න.',
    'கடவுச்சொல் வலுவற்றது. குறைந்தது 6 எழுத்துகள் பயன்படுத்துக.',
  );

  String get registerErrorInvalidEmail => _t(
    'Please enter a valid email address.',
    'වලංගු විද්‍යුත් තැපෑල ලිපිනයක් ඇතුළත් කරන්න.',
    'சரியான மின்னஞ்சல் முகவரியை உள்ளிடுக.',
  );

  // ══════════════════════════════════════════════════════════
  // VERIFICATION / OTP
  // ══════════════════════════════════════════════════════════
  String get verifyTitle => _t(
    'Verify Your Number',
    'ඔබේ අංකය තහවුරු කරන්න',
    'உங்கள் எண்ணை சரிபார்க்கவும்',
  );

  String get verifySubtitle => _t(
    'We will send you a verification code',
    'අපි ඔබට සත්‍යාපන කේතයක් යවන්නෙමු',
    'நாங்கள் உங்களுக்கு சரிபார்ப்பு குறியீடு அனுப்புவோம்',
  );

  String get verifyMobileLabel =>
      _t('Mobile Number', 'ජංගම දුරකථන අංකය', 'மொபைல் எண்');

  String get verifySendButton => _t('Send OTP', 'OTP යවන්න', 'OTP அனுப்பு');

  String get otpTitle => _t('Enter OTP', 'OTP ඇතුළත් කරන්න', 'OTP உள்ளிடுக');

  String get otpSubtitle => _t(
    'A 6-digit code was sent to',
    'ඉලක්කම් 6 කේතය යවා ඇත',
    '6 இலக்க குறியீடு அனுப்பப்பட்டது',
  );

  String get otpDidntReceive => _t(
    "Didn't receive code? ",
    'කේතය ලැබුණේ නැද්ද? ',
    'குறியீடு வரவில்லையா? ',
  );

  String get otpResend => _t('Resend', 'නැවත යවන්න', 'மீண்டும் அனுப்பு');

  String otpResendIn(int seconds) => _t(
    'Resend in ${seconds}s',
    'තත්පර $secondsකින් නැවත යවන්න',
    '$seconds வினாடிகளில் மீண்டும் அனுப்பு',
  );

  String get otpVerifyButton =>
      _t('Verify OTP', 'OTP තහවුරු කරන්න', 'OTP சரிபார்க்கவும்');

  String get otpSuccess => _t(
    'Phone verified successfully!',
    'දුරකථනය සාර්ථකව සත්‍යාපනය විය!',
    'தொலைபேசி வெற்றிகரமாக சரிபார்க்கப்பட்டது!',
  );

  String get otpErrorInvalid => _t(
    'Incorrect OTP. Please check and try again.',
    'වැරදි OTP. නැවත පරීක්ෂා කරන්න.',
    'தவறான OTP. மீண்டும் சரிபார்க்கவும்.',
  );

  String get otpErrorExpired => _t(
    'OTP expired. Go back and resend.',
    'OTP කල් ඉකුත් විය. ආපසු ගොස් නැවත යවන්න.',
    'OTP காலாவதியானது. திரும்பி மீண்டும் அனுப்பவும்.',
  );

  String get otpErrorIncomplete => _t(
    'Please enter the complete 6-digit OTP',
    'සම්පූර්ණ ඉලක්කම් 6 OTP ඇතුළත් කරන්න',
    'முழுமையான 6 இலக்க OTP உள்ளிடுக',
  );

  // ══════════════════════════════════════════════════════════
  // VEHICLE
  // ══════════════════════════════════════════════════════════
  String get vehicleTitle =>
      _t('Vehicle Details', 'වාහන විස්තර', 'வாகன விவரங்கள்');

  String get vehicleType => _t('Vehicle Type', 'වාහන වර්ගය', 'வாகன வகை');

  String get vehicleCompany => _t('Company', 'සමාගම', 'நிறுவனம்');

  String get vehicleModel => _t('Model', 'ආකෘතිය', 'மாடல்');

  String get vehicleBattery =>
      _t('Battery Capacity', 'බැටරි ධාරිතාව', 'பேட்டரி திறன்');

  String get vehicleConnector =>
      _t('Connector Type', 'සම්බන්ධකයේ වර්ගය', 'இணைப்பியின் வகை');

  String get vehicleNext => _t('Next →', 'ඊළඟ →', 'அடுத்து →');

  String get vehicleSave =>
      _t('Save Vehicle ✓', 'වාහනය සුරකින්න ✓', 'வாகனத்தை சேமி ✓');

  String get vehicleReview => _t(
    'Review Your Vehicle',
    'ඔබේ වාහනය සමාලෝචනය කරන්න',
    'உங்கள் வாகனத்தை மதிப்பாய்வு செய்க',
  );

  String get vehicleSuccess => _t(
    'Vehicle saved successfully!',
    'වාහනය සාර්ථකව සුරකිනා ලදී!',
    'வாகனம் வெற்றிகரமாக சேமிக்கப்பட்டது!',
  );

  String get vehicleErrorType => _t(
    'Please select Vehicle Type, Company and Model',
    'වාහන වර්ගය, සමාගම සහ ආකෘතිය තෝරන්න',
    'வாகன வகை, நிறுவனம் மற்றும் மாடலை தேர்ந்தெடுக்கவும்',
  );

  String get vehicleErrorBattery => _t(
    'Please select Battery and Connector type',
    'බැටරිය සහ සම්බන්ධකය තෝරන්න',
    'பேட்டரி மற்றும் இணைப்பியை தேர்ந்தெடுக்கவும்',
  );

  String get vehicleErrorSave => _t(
    'Failed to save vehicle. Try again.',
    'වාහනය සුරැකීම අසාර්ථකයි. නැවත උත්සාහ කරන්න.',
    'வாகனத்தை சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
  );

  // ══════════════════════════════════════════════════════════
  // HOME
  // ══════════════════════════════════════════════════════════
  String get homeLogout => _t('Logout', 'පිටවෙන්න', 'வெளியேறு');

  String get homeSignOut => _t('Sign Out', 'පිටවෙන්න', 'வெளியேறு');

  String get homeSignOutConfirm => _t(
    'Are you sure you want to sign out?',
    'ඔබට නිසැකවම පිටවීමට අවශ්‍යද?',
    'நீங்கள் வெளியேற விரும்புகிறீர்களா?',
  );

  String get homeCancel => _t('Cancel', 'අවලංගු කරන්න', 'ரத்து செய்');

  String get homeNavMap => _t('Map', 'සිතියම', 'வரைபடம்');

  String get homeNavBookings => _t('Bookings', 'වෙන්කිරීම්', 'முன்பதிவுகள்');

  String get homeNavProfile => _t('Profile', 'පැතිකඩ', 'சுயவிவரம்');

  String get homeNavSettings => _t('Settings', 'සැකසුම්', 'அமைப்புகள்');

  String get homeNoVehicle =>
      _t('No vehicles found', 'වාහන හමු නොවීය', 'வாகனங்கள் இல்லை');

  // ══════════════════════════════════════════════════════════
  // AUTH CHECK
  // ══════════════════════════════════════════════════════════
  String get authPleaseWait => _t(
    'Please wait...',
    'කරුණාකර රැඳෙන්න...',
    'தயவுசெய்து காத்திருக்கவும்...',
  );

  // ══════════════════════════════════════════════════════════
  // GENERAL
  // ══════════════════════════════════════════════════════════
  String get errorUnexpected => _t(
    'Unexpected error. Try again.',
    'අනපේක්ෂිත දෝෂයක්. නැවත උත්සාහ කරන්න.',
    'எதிர்பாராத பிழை. மீண்டும் முயற்சிக்கவும்.',
  );

  String get comingSoon =>
      _t('Coming soon!', 'ඉක්මනින් එනවා!', 'விரைவில் வருகிறது!');
}
