{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gst_all_1,
  html-tidy,
  http-parser,
  hunspell,
  kdePackages,
  libgcrypt,
  libgpg-error,
  libomemo-c,
  libotr,
  libxscrnsaver,
  pkg-config,
  # For tests
  psi-plus,
  qt6,
  usrsctp,
  chatType ? "basic", # See the assertion below for available options
  enablePlugins ? true,
  enablePsiMedia ? false,
  # Voice messages
  voiceMessagesSupport ? true,
}:

assert lib.assertMsg (lib.toLower chatType != "webkit")
  "psi-plus: chatType = \"webkit\" was removed because qtwebkit had known vulns and has no Qt6 equivalent. Use chatType = \"webengine\" instead.";

assert builtins.elem (lib.toLower chatType) [
  "basic" # Basic implementation, no web stuff involved
  "webengine"
];

assert enablePsiMedia -> enablePlugins;

stdenv.mkDerivation rec {
  pname = "psi-plus";
  version = "1.5.2140";

  src = fetchFromGitHub {
    owner = "psi-plus";
    repo = "psi-plus-snapshots";
    tag = version;
    hash = "sha256-cXgjskHb7Rx4FB+DW/cTlsNtdyWgXN3sBh9WBBCgliA=";
  };

  nativeBuildInputs = [
    cmake
    qt6.qttools
    qt6.wrapQtAppsHook
  ]
  ++ lib.optionals enablePsiMedia [
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    kdePackages.qca
    libxscrnsaver
    hunspell
    libgcrypt
    libgpg-error
    usrsctp
    kdePackages.qtkeychain
  ]
  ++ lib.optionals voiceMessagesSupport [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ]
  ++ lib.optionals enablePlugins [
    html-tidy
    http-parser
    libotr
    libomemo-c
  ]
  ++ lib.optionals (chatType == "webengine") [
    qt6.qtwebengine
  ];

  cmakeFlags = [
    "-DCHAT_TYPE=${chatType}"
    "-DENABLE_PLUGINS=${if enablePlugins then "ON" else "OFF"}"
    "-DBUILD_PSIMEDIA=${if enablePsiMedia then "ON" else "OFF"}"
    "-DUSE_QT6=ON"
  ];

  preFixup = lib.optionalString voiceMessagesSupport ''
    qtWrapperArgs+=(
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
    )
  '';

  passthru.tests = {
    webengine = psi-plus.override { chatType = "webengine"; };
  };

  meta = {
    description = "XMPP (Jabber) client based on Qt5";
    homepage = "https://psi-plus.com";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      unclechu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "psi-plus";
  };
}
