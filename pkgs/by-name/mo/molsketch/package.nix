{
  lib,
  stdenv,
  fetchurl,
  cmake,
  desktop-file-utils,
  hicolor-icon-theme,
  libsForQt5,
  openbabel,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "molsketch";
  version = "0.8.1";

  src = fetchurl {
    url = "mirror://sourceforge/molsketch/Molsketch-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-6wFvl3Aktv8RgEdI2ENsKallKlYy/f8Tsm5C0FB/igI=";
  };

  patches = [
    ./openbabel.patch
  ];

  # uses C++17 APIs like std::transform_reduce
  postPatch = ''
    substituteInPlace molsketch/CMakeLists.txt \
      --replace "CXX_STANDARD 14" "CXX_STANDARD 17"
    substituteInPlace libmolsketch/CMakeLists.txt \
      --replace "CXX_STANDARD 14" "CXX_STANDARD 17"
    substituteInPlace obabeliface/CMakeLists.txt \
      --replace "CXX_STANDARD 14" "CXX_STANDARD 17"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    hicolor-icon-theme
    openbabel
    desktop-file-utils
  ];

  cmakeFlags = [
    "-DMSK_PREFIX=${placeholder "out"}"
  ];

  postFixup = ''
    ln -s $out/lib/molsketch/* $out/lib/.
  '';

  meta = {
    description = "2D molecule editor";
    homepage = "https://sourceforge.net/projects/molsketch/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.moni ];
    platforms = lib.platforms.unix;
    mainProgram = "molsketch";
  };
})
