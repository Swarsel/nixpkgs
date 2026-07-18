{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  autoreconfHook,
  boost,
  cairo,
  fftw,
  freetype,
  fribidi,
  gettext,
  glibmm,
  gtk3,
  gtkmm3,
  harfbuzz,
  imagemagick,
  intltool,
  libjack2,
  libsigcxx,
  libxmlxx,
  mlt,
  openexr,
  pango,
  pkg-config,
  wrapGAppsHook3,
}:

let
  version = "1.5.3";
  src = fetchFromGitHub {
    owner = "synfig";
    repo = "synfig";
    rev = "v${version}";
    hash = "sha256-D+FUEyzJ74l0USq3V9HIRAfgyJfRP372aEKDqF8+hsQ=";
  };

  ETL = stdenv.mkDerivation {
    inherit version src;
    pname = "ETL";

    nativeBuildInputs = [
      pkg-config
      autoreconfHook
    ];

    buildInputs = [
      glibmm
    ];

    sourceRoot = "${src.name}/ETL";
  };

  synfig = stdenv.mkDerivation {
    inherit version src;
    pname = "synfig";

    nativeBuildInputs = [
      pkg-config
      autoreconfHook
      gettext
      intltool
    ];

    buildInputs = [
      ETL
      boost
      cairo
      glibmm
      mlt
      libsigcxx
      libxmlxx
      pango
      imagemagick
      harfbuzz
      freetype
      fribidi
      openexr
      fftw
    ];

    configureFlags = [
      "--with-boost=${boost.dev}"
      "--with-boost-libdir=${boost.out}/lib"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      # Newer versions of clang default to C++17, but synfig and some of its dependencies use deprecated APIs that
      # are removed in C++17. Setting the language version to C++14 allows it to build.
      "CXXFLAGS=-std=c++14"
    ];

    enableParallelBuilding = true;
    sourceRoot = "${src.name}/synfig-core";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = "synfigstudio";

  postPatch = ''
    patchShebangs images/splash_screen_development.sh
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    gettext
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    ETL
    synfig
    boost
    cairo
    glibmm
    gtk3
    gtkmm3
    imagemagick
    libjack2
    libsigcxx
    libxmlxx
    mlt
    adwaita-icon-theme
    openexr
    fftw
  ];

  configureFlags = lib.optionals stdenv.cc.isClang [
    # Newer versions of clang default to C++17, but synfig and some of its dependencies use deprecated APIs that
    # are removed in C++17. Setting the language version to C++14 allows it to build.
    "CXXFLAGS=-std=c++14"
  ];

  preConfigure = ''
    ./bootstrap.sh
  '';

  enableParallelBuilding = true;
  sourceRoot = "${src.name}/synfig-studio";

  passthru = {
    # Expose libraries and cli tools
    inherit ETL synfig;
  };

  meta = {
    description = "2D animation program";
    homepage = "https://www.synfig.org";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
