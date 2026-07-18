{
  lib,
  stdenv,
  fetchurl,
  cmake,
  cryptopp,
  libusb1,
  makeWrapper,
  pkg-config,
  qt5,
  espeak ? null,
  withEspeak ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rockbox-utility";
  version = "1.5.1";

  src = fetchurl {
    url = "https://download.rockbox.org/rbutil/source/RockboxUtility-v${finalAttrs.version}-src.tar.bz2";
    hash = "sha256-guNO11a0d30RexPEAAQGIgV9W17zgTjZ/LNz/oUn4HM=";
  };

  patches = [
    ./rockbox-utility-fix-cmake.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    cryptopp
    libusb1
    qt5.qtbase
    qt5.qtmultimedia
    qt5.qttools
  ]
  ++ lib.optional withEspeak espeak;

  installPhase = ''
    runHook preInstall

    install -Dm755 rbutilqt/RockboxUtility $out/bin/rockboxutility
    ln -s $out/bin/rockboxutility $out/bin/RockboxUtility
    wrapProgram $out/bin/rockboxutility \
    ${lib.optionalString withEspeak ''
      --prefix PATH : ${espeak}/bin
    ''}

    runHook postInstall
  '';

  cmakeDir = "../utils";

  meta = {
    description = "Open source firmware for digital music players";
    homepage = "https://www.rockbox.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ozkutuk ];
    platforms = lib.platforms.linux;
    mainProgram = "RockboxUtility";
  };
})
