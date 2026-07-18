{
  lib,
  stdenv,
  fetchFromGitHub,
  boost186,
  cmake,
  hidapi,
  libgcrypt,
  libgpg-error,
  libsodium,
  libusb1,
  makeDesktopItem,
  monero-cli,
  pkg-config,
  protobuf_21,
  python3,
  qt5,
  quirc,
  randomx,
  rapidjson,
  udev,
  unbound,
  zeromq,
  trezorSupport ? true,
}:

stdenv.mkDerivation rec {
  pname = "monero-gui";
  version = "0.18.5.0";

  src = fetchFromGitHub {
    owner = "monero-project";
    repo = "monero-gui";
    rev = "v${version}";
    hash = "sha256-uBZMBQ6Co1+H8DsyeL1vbjtVlKyIkJopKxHxr24BZv0=";
  };

  patches = [
    ./move-log-file.patch
    ./use-system-libquirc.patch
  ];

  postPatch = ''
    # set monero-gui version
    substituteInPlace src/version.js.in \
       --replace '@VERSION_TAG_GUI@' '${version}'

    # use monerod from the monero package
    substituteInPlace src/daemon/DaemonManager.cpp \
      --replace 'QApplication::applicationDirPath() + "' '"${monero-cli}/bin'

    # 1: only build external deps, *not* the full monero
    # 2: use nixpkgs libraries
    substituteInPlace CMakeLists.txt \
      --replace 'add_subdirectory(monero)' \
                'add_subdirectory(monero EXCLUDE_FROM_ALL)' \
      --replace 'add_subdirectory(external)' ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt5.wrapQtAppsHook
    (lib.getDev qt5.qttools)
  ];

  buildInputs = [
    boost186 # uses boost/asio/io_service.hpp
    libgcrypt
    libgpg-error
    libsodium
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtgraphicaleffects
    qt5.qtmultimedia
    qt5.qtquickcontrols
    qt5.qtquickcontrols2
    qt5.qtxmlpatterns
    quirc
    randomx
    rapidjson
    unbound
    zeromq
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ qt5.qtmacextras ]
  ++ lib.optionals trezorSupport [
    hidapi
    libusb1
    protobuf_21
    python3
  ]
  ++ lib.optionals (trezorSupport && stdenv.hostPlatform.isLinux) [
    udev
  ];

  cmakeFlags = [
    "-DARCH=default"
  ]
  ++ lib.optional trezorSupport [
    # fix build on recent gcc versions
    "-DCMAKE_CXX_FLAGS=-fpermissive"
  ];

  postInstall = ''
    # install desktop entry
    install -Dm644 -t $out/share/applications \
      ${desktopItem}/share/applications/*

    # install icons
    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      install -Dm644 \
        $src/images/appicons/$size.png \
        $out/share/icons/hicolor/$size/apps/monero.png
    done;
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Network"
      "Utility"
    ];

    desktopName = "Monero";
    exec = "monero-wallet-gui";
    genericName = "Wallet";
    icon = "monero";
    name = "monero-wallet-gui";
  };

  postUnpack = ''
    # copy monero sources here
    # (needs to be writable)
    cp -r ${monero-cli.source}/* source/monero
    chmod -R +w source/monero
  '';

  meta = {
    description = "Private, secure, untraceable currency";
    homepage = "https://getmonero.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.all;
    mainProgram = "monero-wallet-gui";
  };
}
