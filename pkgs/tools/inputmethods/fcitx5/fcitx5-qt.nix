{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fcitx5,
  gettext,
  kdePackages,
  qtbase,
  qtwayland,
  wayland,
  wrapQtAppsHook,
}:
let
  majorVersion = lib.versions.major qtbase.version;
in
stdenv.mkDerivation rec {
  pname = "fcitx5-qt${majorVersion}";
  version = "5.1.13";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "fcitx5-qt";
    rev = version;
    hash = "sha256-CrrQQPtWQwE6eZOJB+uLVUjPJMKW/sz/tij41dyEe0U=";
  };

  postPatch = ''
    substituteInPlace qt${majorVersion}/platforminputcontext/CMakeLists.txt \
      --replace \$"{CMAKE_INSTALL_QT${majorVersion}PLUGINDIR}" $out/${qtbase.qtPluginPrefix}
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    gettext
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtwayland
    fcitx5
    wayland
  ];

  cmakeFlags = [
    "-DENABLE_QT4=OFF"
    "-DENABLE_QT5=OFF"
    "-DENABLE_QT6=OFF"
    "-DENABLE_QT${majorVersion}=ON"
  ];

  meta = {
    description = "Fcitx5 Qt Library";
    homepage = "https://github.com/fcitx/fcitx5-qt";

    license = with lib.licenses; [
      lgpl21Plus
      bsd3
    ];

    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
}
