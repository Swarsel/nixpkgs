{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  doxygen,
  fcgi,
  firebird,
  glew,
  graphicsmagick,
  harfbuzz,
  icu,
  libharu,
  libice,
  libmysqlclient,
  libpq,
  libsm,
  openssl,
  pango,
  pkg-config,
  qtbase,
}:

let
  generic =
    { sha256, version }:
    stdenv.mkDerivation {
      inherit version;
      pname = "wt";

      src = fetchFromGitHub {
        inherit sha256;
        owner = "emweb";
        repo = "wt";
        rev = version;
      };

      nativeBuildInputs = [
        cmake
        pkg-config
      ];

      buildInputs = [
        boost
        doxygen
        qtbase
        libharu
        pango
        fcgi
        firebird
        libmysqlclient
        libpq
        graphicsmagick
        glew
        openssl
        harfbuzz
        icu
        libice
        libsm
      ];

      cmakeFlags = [
        "-DCMAKE_INSTALL_RPATH=${
          lib.makeLibraryPath [
            libice
            libsm
          ]
        }"
        "-DWT_CPP_11_MODE=-std=c++11"
        "--no-warn-unused-cli"
      ]
      ++ lib.optionals (graphicsmagick != null) [
        "-DWT_WRASTERIMAGE_IMPLEMENTATION=GraphicsMagick"
        "-DGM_PREFIX=${graphicsmagick}"
      ]
      ++ lib.optional (libmysqlclient != null) "-DMYSQL_PREFIX=${libmysqlclient}";

      dontWrapQtApps = true;

      meta = {
        description = "C++ library for developing web applications";
        homepage = "https://www.webtoolkit.eu/wt";
        license = lib.licenses.gpl2;
        maintainers = with lib.maintainers; [ juliendehos ];
        platforms = lib.platforms.linux;
      };
    };
in
{
  wt4 = generic {
    version = "4.13.2";
    sha256 = "sha256-UK0r99f8ub7YPETiz3Ka/jCkJmF4qc7R8ZLkb/RWQCI=";
  };
}
