{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  boost,
  cmake,
  darwin,
  db53,
  installShellFiles,
  libevent,
  libsystemtap,
  pkg-config,
  python3,
  qrencode,
  qt5,
  sqlite,
  versionCheckHook,
  zeromq,
  zlib,
  withGui ? true,
  withWallet ? true,
}:

let
  desktop = fetchurl {
    sha256 = "0mxwq4jvcip44a796iwz7n1ljkhl3a4p47z7qlsxcfxw3zmm0k0k";
    # de45048 is the last commit when the debian/groestlcoin-qt.desktop file was changed
    url = "https://raw.githubusercontent.com/Groestlcoin/packaging/de4504844e47cf2c7604789650a5db4f3f7a48aa/debian/groestlcoin-qt.desktop";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = if withGui then "groestlcoin" else "groestlcoind";
  version = "29.0";

  src = fetchFromGitHub {
    owner = "Groestlcoin";
    repo = "groestlcoin";
    rev = "v${finalAttrs.version}";
    sha256 = "17b83jch717d91srw1yc93p8ndl894ld9gx916wyy6jis07px6xh";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.autoSignDarwinBinariesHook
  ]
  ++ lib.optionals withGui [ qt5.wrapQtAppsHook ];

  buildInputs = [
    boost
    libevent
    zeromq
    zlib
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux) [ libsystemtap ]
  ++ lib.optionals withWallet [
    db53
    sqlite
  ]
  ++ lib.optionals withGui [
    qrencode
    qt5.qtbase
    qt5.qttools
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_BENCH" false)
    (lib.cmakeBool "WITH_ZMQ" true)
    (lib.cmakeBool "WITH_USDT" stdenv.hostPlatform.isLinux)
  ]
  ++ lib.optionals (!withWallet) [
    (lib.cmakeBool "ENABLE_WALLET" false)
  ]
  ++ lib.optionals withGui [
    (lib.cmakeBool "BUILD_GUI" true)
    (lib.cmakeBool "WITH_QRENCODE" true) # Fixes the headless QR encode crash!
  ];

  nativeCheckInputs = [ python3 ];

  checkFlags = [
    "LC_ALL=en_US.UTF-8"
  ]
  # QT_PLUGIN_PATH needs to be set when executing QT, which is needed when testing Groestlcoin's GUI.
  # See also https://github.com/NixOS/nixpkgs/issues/24256
  ++ lib.optional withGui "QT_PLUGIN_PATH=${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}";

  postInstall = ''
      cd ..
      installShellCompletion --bash contrib/completions/bash/groestlcoin-cli.bash
      installShellCompletion --bash contrib/completions/bash/groestlcoind.bash
      installShellCompletion --bash contrib/completions/bash/groestlcoin-tx.bash

    for file in contrib/completions/fish/groestlcoin-*.fish; do
      installShellCompletion --fish $file
    done
  ''
  + lib.optionalString withGui ''
    installShellCompletion --fish contrib/completions/fish/groestlcoin-qt.fish

    install -Dm644 ${desktop} $out/share/applications/groestlcoin-qt.desktop
    substituteInPlace $out/share/applications/groestlcoin-qt.desktop --replace "Icon=groestlcoin128" "Icon=groestlcoin"
    install -Dm644 share/pixmaps/groestlcoin256.png $out/share/icons/hicolor/256x256/apps/groestlcoin.png
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;
  versionCheckProgram = "${placeholder "out"}/bin/groestlcoin-cli";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Peer-to-peer electronic cash system";

    longDescription = ''
      Groestlcoin is a free open source peer-to-peer electronic cash system that is
      completely decentralized, without the need for a central server or trusted
      parties. Users hold the crypto keys to their own money and transact directly
      with each other, with the help of a P2P network to check for double-spending.
    '';

    homepage = "https://groestlcoin.org/";
    changelog = "https://github.com/Groestlcoin/groestlcoin/blob/${finalAttrs.version}.0/doc/release-notes/release-notes-${finalAttrs.version}.0.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gruve-p ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/Groestlcoin/groestlcoin/releases/tag/v${finalAttrs.version}/";
  };
})
