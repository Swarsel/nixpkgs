{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  qtlocation,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maplibre-native-qt";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "maplibre";
    repo = "maplibre-native-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h7PFoGJ5P+k5AEv+y0XReYnPdP/bD4nr/uW9jZ5DCy4=";
    fetchSubmodules = true;
  };

  patches = [
    # fix build with gcc15
    (fetchpatch {
      extraPrefix = "vendor/maplibre-native/";
      hash = "sha256-UQ4Y2aoBsHQHEqlrwn4OUzICeT3MNVZlHFK/KphvV/c=";
      stripLen = 1;
      url = "https://github.com/maplibre/maplibre-native/commit/dde3fdd398a5f7b49300b1a761057bdd3286ae24.patch";
    })
  ];

  postPatch = lib.optionals (lib.versionAtLeast qtlocation.version "6.10") ''
    # fix build with Qt 6.10
    # included in https://github.com/maplibre/maplibre-native-qt/pull/216
    substituteInPlace CMakeLists.txt \
      --replace-fail 'find_package(Qt''${QT_VERSION_MAJOR} COMPONENTS Location REQUIRED)' \
                     'find_package(Qt''${QT_VERSION_MAJOR} COMPONENTS Location LocationPrivate REQUIRED)'
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtlocation
  ];

  env.CXXFLAGS = toString [
    "-DQT_NO_USE_NODISCARD_FILE_OPEN"
  ];

  dontWrapQtApps = true; # library only

  meta = {
    description = "MapLibre Native Qt Bindings and Qt Location Plugin";
    homepage = "https://github.com/maplibre/maplibre-native-qt";
    changelog = "https://github.com/maplibre/maplibre-native-qt/blob/${finalAttrs.src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      bsd2
      gpl3
      lgpl3
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.all;
  };
})
