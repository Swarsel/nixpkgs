{
  lib,
  stdenv,
  fetchFromGitHub,
  avahi-compat,
  buildGoModule,
  cargo,
  cmake,
  copyDesktopItems,
  corrosion,
  fetchpatch,
  ffmpeg,
  go,
  libheif,
  libimobiledevice,
  libimobiledevice-glue,
  libplist,
  libssh,
  libtatsu,
  libusb1,
  libusbmuxd,
  libzip,
  lxqt,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  pugixml,
  qrencode,
  qt6,
  rustPlatform,
  rustc,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "idescriptor";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "iDescriptor";
    repo = "iDescriptor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AN3CVR9WWa9cG6C6q+hiDyTomT+RebHC1ghr6XyEtAo=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-WqEpSY/fhbsMv0bgU2Ak5japUdohaN7zsNG1BbxJnKs=";
      url = "https://github.com/iDescriptor/iDescriptor/commit/fc73e3146dc4884cf9bc1f7879574ac832cc21e6.patch";
    })
  ];

  nativeBuildInputs = [
    cargo
    cmake
    copyDesktopItems
    pkg-config
    go
    qt6.wrapQtAppsHook
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [
    avahi-compat
    corrosion
    ffmpeg
    libheif
    libimobiledevice
    libimobiledevice-glue
    libplist
    qrencode
    libssh
    libtatsu
    libusbmuxd
    libusb1
    libzip
    openssl
    pugixml
    qt6.qtbase
    qt6.qtlocation
    qt6.qtmultimedia
    qt6.qtpositioning
    qt6.qtserialport
    qt6.qtsvg
    qt6.qttools
    qt6.qtwayland
    lxqt.qtermwidget
  ];

  cmakeFlags = [
    "-DPACKAGE_MANAGER_MANAGED=ON"
    "-DPACKAGE_MANAGER_HINT=nixpkgs"
    "-DFETCHCONTENT_SOURCE_DIR_CXXQT=${finalAttrs.cxx-qt-cmake}"
  ];

  preConfigure = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go
    export GOPROXY=file://${finalAttrs.ipatool-go-modules}
    export GOSUMDB=off
  '';

  postInstall = ''
    install -Dm644 -t $out/lib/udev/rules.d ${./99-idevice.rules}

    install -Dm644 $src/resources/icons/app-icon/icon.png \
      $out/share/icons/hicolor/256x256/apps/idescriptor.png
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src cargoRoot;
    hash = "sha256-PJhMb+lMiu8ubOYVX8YVkQzeQMbBO+i6NQhvuyrCujk=";
  };

  cargoRoot = "src/rust";

  cxx-qt-cmake = fetchFromGitHub {
    hash = "sha256-kXSIU71iHn+SSGikGoNeMbBpSrDJ6hwhnHslmskm8nY=";
    owner = "kdab";
    repo = "cxx-qt-cmake";
    tag = "0.8.1";
  };

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "System"
        "Utility"
      ];

      comment = "Cross-platform iDevice management tool";
      desktopName = "iDescriptor";
      exec = "iDescriptor";
      icon = "idescriptor";
      name = "iDescriptor";
    })
  ];

  ipatool-go-modules =
    (buildGoModule {
      inherit (finalAttrs) version src;
      pname = "ipatool-go";
      vendorHash = "sha256-SGdyyZU8Ze/1lJS4tKbHyfCv2yYleGcqoyA9Uzb8r/k=";
      env.GOWORK = "off";
      doCheck = false;
      modRoot = "lib/ipatool-go";
      proxyVendor = true;
    }).goModules;

  passthru = {
    goModules = finalAttrs.ipatool-go-modules;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A cross-platform iDevice management tool";
    homepage = "https://github.com/iDescriptor/iDescriptor";
    changelog = "https://github.com/iDescriptor/iDescriptor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ amadejkastelic ];
    platforms = lib.platforms.linux;
    mainProgram = "iDescriptor";
  };
})
