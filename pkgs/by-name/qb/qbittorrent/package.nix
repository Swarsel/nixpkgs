{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  dbus,
  libtorrent-rasterbar,
  llvmPackages,
  nix-update-script,
  nixosTests,
  openssl,
  pkg-config,
  python3,
  qt6,
  wrapGAppsHook3,
  zlib,
  guiSupport ? true,
  trackerSearch ? true,
  webuiSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qbittorrent" + lib.optionalString (!guiSupport) "-nox";
  version = "5.2.2";

  src = fetchFromGitHub {
    owner = "qbittorrent";
    repo = "qBittorrent";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-5lGv1ajuDE/DTqUbnVeRRBcXntrzn6bs72mZbQMf7Fc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    qt6.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # TODO: Remove once #536365 reaches this branch
    llvmPackages.lld
  ];

  buildInputs = [
    boost
    libtorrent-rasterbar
    openssl
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    zlib
  ]
  ++ lib.optionals guiSupport [ dbus ]
  ++ lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [ qt6.qtwayland ]
  ++ lib.optionals trackerSearch [ python3 ];

  cmakeFlags = [
    "-DVERBOSE_CONFIGURE=ON"
  ]
  ++ lib.optionals (!guiSupport) [
    "-DGUI=OFF"
    "-DSYSTEMD=ON"
    "-DSYSTEMD_SERVICES_INSTALL_DIR=${placeholder "out"}/lib/systemd/system"
  ]
  ++ lib.optionals (!webuiSupport) [ "-DWEBUI=OFF" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # TODO: Remove once #536365 reaches this branch
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    APP_NAME=qbittorrent${lib.optionalString (!guiSupport) "-nox"}
    mkdir -p $out/{Applications,bin}
    mv $out/$APP_NAME.app $out/Applications
    makeWrapper $out/{Applications/$APP_NAME.app/Contents/MacOS,bin}/$APP_NAME
  '';

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  qtWrapperArgs = lib.optionals trackerSearch [ "--prefix PATH : ${lib.makeBinPath [ python3 ]}" ];

  passthru = {
    tests.testService = nixosTests.qbittorrent;
    updateScript = nix-update-script { extraArgs = [ "--version-regex=release-(.*)" ]; };
  };

  meta = {
    description = "Featureful free software BitTorrent client";
    homepage = "https://www.qbittorrent.org";
    changelog = "https://github.com/qbittorrent/qBittorrent/blob/release-${finalAttrs.version}/Changelog";

    license =
      with lib.licenses;
      AND [
        gpl2Plus # code
        gpl3Plus # assets
      ];

    maintainers = with lib.maintainers; [
      Anton-Latukha
      kashw2
    ];

    platforms = lib.platforms.unix;
    mainProgram = "qbittorrent" + lib.optionalString (!guiSupport) "-nox";
  };
})
