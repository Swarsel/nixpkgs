{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  desktopToDarwinBundle,
  fontconfig,
  freetype,
  libiconv,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  libx11,
  libxcursor,
  libxext,
  libxi,
  ninja,
  pkg-config,
  shared-mime-info,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "azpainter";
  version = "3.0.12";

  src = fetchFromGitLab {
    owner = "azelpg";
    repo = "azpainter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cUq1UmS0k5eib0aJI1zOJbJRzErezfAAXOOIFrgUS6E=";
  };

  nativeBuildInputs = [
    desktop-file-utils # for update-desktop-database
    shared-mime-info # for update-mime-info
    ninja
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    libx11
    libxcursor
    libxext
    libxi
    freetype
    fontconfig
    libjpeg
    libpng
    libtiff
    libwebp
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];

  preBuild = ''
    cd build
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Full color painting software for illustration drawing";
    homepage = "http://azsky2.html.xdomain.jp/soft/azpainter.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "azpainter";
  };
})
