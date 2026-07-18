{
  lib,
  stdenv,
  autoPatchelfHook,
  boost,
  cmake,
  kdePackages,
  libavif,
  libnotify,
  libpulseaudio,
  libsecret,
  openssl,
  pkg-config,
  enableAvifSupport ? false,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs =
    (with kdePackages; [
      qtbase
      qtsvg
      qt5compat
      qtkeychain
      qtimageformats
    ])
    ++ [
      boost
      openssl
      libsecret
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      kdePackages.qtwayland
      libnotify
    ]
    ++ lib.optional enableAvifSupport libavif;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_WITH_QT6" true)
    (lib.cmakeBool "USE_SYSTEM_QTKEYCHAIN" true)
    (lib.cmakeBool "CHATTERINO_UPDATER" false)
  ];

  preConfigure = ''
    if [[ -f "$src/GIT_HASH" ]]; then
      export GIT_HASH="$(cat $src/GIT_HASH)"
    fi
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/chatterino.app $out/Applications
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -s $out/Applications/chatterino.app/Contents/MacOS/chatterino $out/bin/chatterino
  '';

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [ libpulseaudio ];
}
