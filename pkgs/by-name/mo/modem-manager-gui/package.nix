{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  gdbm,
  glib,
  gtk3,
  gtkspell3,
  itstool,
  libayatana-appindicator,
  meson,
  ninja,
  ofono,
  perlPackages,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "modem-manager-gui";
  version = "0.0.20";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "modem-manager-gui";
    rev = "upstream/${finalAttrs.version}";
    hash = "sha256-+VXqfA7TUUemY+DWeRHupWb8weJTeiSMZu+orlcmXd4=";
    domain = "salsa.debian.org";
  };

  patches = [
    # Fix missing tray icon
    (fetchpatch {
      hash = "sha256-9LjCEQl8YfraVlO1W7+Yy7egLAPu5YfnvGvCI3uGFh8=";
      url = "https://salsa.debian.org/debian/modem-manager-gui/-/raw/7c3e67a1cf7788d7a4b86be12803870d79aa27f2/debian/patches/fix-tray-icon.patch";
    })
    # Fix build with meson 0.61
    # appdata/meson.build:3:5: ERROR: Function does not take positional arguments.
    (fetchpatch {
      hash = "sha256-B+tBPIz5RxOwZWYEWttqSKGw2Wbfk0mnBY0Zy0evvAQ=";
      url = "https://salsa.debian.org/debian/modem-manager-gui/-/raw/7c3e67a1cf7788d7a4b86be12803870d79aa27f2/debian/patches/meson0.61.patch";
    })
    # Fix segfault on launch: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1004258
    # Segmentation fault at address: 0x20
    (fetchpatch {
      hash = "sha256-q+B+Bcm3uitJ2IfkCiMo3reFV1C06ekmy1vXWC0oHnw=";
      url = "https://salsa.debian.org/debian/modem-manager-gui/-/commit/8ccffd6dd6b42625d09d5408f37f155d91411116.patch";
    })
  ];

  postPatch = ''
    patchShebangs man/manhelper.py
  '';

  nativeBuildInputs = [
    pkg-config
    python3
    perlPackages.Po4a
    itstool
    meson
    ninja
  ];

  buildInputs = [
    gtk3
    glib
    gdbm
    gtkspell3
    ofono
    libayatana-appindicator
  ];

  meta = {
    description = "App to send/receive SMS, make USSD requests, control mobile data usage and more";

    longDescription = ''
      A simple GTK based GUI compatible with Modem manager, Wader and oFono
      system services able to control EDGE/3G/4G broadband modem specific
      functions. You can check balance of your SIM card, send or receive SMS
      messages, control mobile traffic consumption and more.
    '';

    homepage = "https://linuxonly.ru/page/modem-manager-gui";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      ahuzik
      galagora
    ];

    platforms = lib.platforms.linux;
    mainProgram = "modem-manager-gui";
  };
})
