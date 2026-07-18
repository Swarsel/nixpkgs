{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  copyDesktopItems,
  cups,
  fetchpatch,
  fmt,
  gtest,
  libsndfile,
  libvorbis,
  makeDesktopItem,
  minizip,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lsd2dsl";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "nongeneric";
    repo = "lsd2dsl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0UsxDNpuWpBrfjh4q3JhZnOyXhHatSa3t/cApiG2JzM=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-7is83D1cMBArXVLe5TP7D7lUcwnTMeXjkJ+cbaH5JQk=";
      url = "https://github.com/nongeneric/lsd2dsl/commit/bbda5be1b76a4a44804483d00c07d79783eceb6b.patch";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "-Werror" "" \
      --replace-fail 'COMPONENTS system program_options' 'COMPONENTS program_options'
    substituteInPlace lib/common/CMakeLists.txt lib/duden/CMakeLists.txt lib/lingvo/CMakeLists.txt \
      --replace-fail 'Boost::system' ""
  '';

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux copyDesktopItems;

  buildInputs = [
    boost
    cups
    fmt
    libvorbis
    libsndfile
    minizip
    gtest
    qt6.qt5compat
    qt6.qtwebengine
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-int-conversion";

  installPhase = ''
    install -Dm755 console/lsd2dsl gui/lsd2dsl-qtgui -t $out/bin
  '';

  desktopItems = lib.singleton (makeDesktopItem {
    categories = [
      "Dictionary"
      "FileTools"
      "Qt"
    ];

    comment = finalAttrs.meta.description;
    desktopName = "lsd2dsl";
    exec = "lsd2dsl-qtgui";
    genericName = "lsd2dsl";
    name = "lsd2dsl";
  });

  meta = {
    description = "Lingvo dictionaries decompiler";

    longDescription = ''
      A decompiler for ABBYY Lingvo’s proprietary dictionaries.
    '';

    homepage = "https://rcebits.com/lsd2dsl/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
  };
})
