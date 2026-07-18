{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  boost187,
  curl,
  fftw, # visualizer screen
  icu,
  libiconv,
  libmpdclient,
  libtool,
  ncurses,
  pkg-config,
  readline,
  taglib, # tag editor
  clockSupport ? true, # clock screen
  outputsSupport ? true, # outputs screen
  taglibSupport ? true,
  visualizerSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncmpcpp";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "ncmpcpp";
    repo = "ncmpcpp";
    tag = finalAttrs.version;
    hash = "sha256-w3deSy71SWWD2kZKREowZh3KMNCBfBJbrjM0vW4/GrI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  buildInputs = [
    boost187
    libmpdclient
    ncurses
    readline
    libiconv
    icu
    curl
  ]
  ++ lib.optional visualizerSupport fftw
  ++ lib.optional taglibSupport taglib;

  configureFlags = [
    "BOOST_LIB_SUFFIX="
    (lib.enableFeature outputsSupport "outputs")
    (lib.enableFeature visualizerSupport "visualizer")
    (lib.withFeature visualizerSupport "fftw")
    (lib.enableFeature clockSupport "clock")
    (lib.withFeature taglibSupport "taglib")
    (lib.withFeatureAs true "boost" boost187.dev)
  ];

  preConfigure = ''
    autoreconf -fiv
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # std::result_of was removed in c++20 and unusable for clang16
    substituteInPlace ./configure \
      --replace-fail "std=c++20" "std=c++17"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Featureful ncurses based MPD client inspired by ncmpc";
    homepage = "https://rybczak.net/ncmpcpp/";
    changelog = "https://github.com/ncmpcpp/ncmpcpp/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      koral
    ];

    platforms = lib.platforms.all;
    mainProgram = "ncmpcpp";
  };
})
