{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cpp-utilities,
  qtbase,
  qttools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtutilities";
  version = "6.21.2";

  src = fetchFromGitHub {
    owner = "Martchus";
    repo = "qtutilities";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pPCXhk6ujIu+TmxeLP8FPkHopjhy0dVUj/kR9yXxmrc=";
  };

  nativeBuildInputs = [
    cmake
    qttools
  ];

  buildInputs = [
    qtbase
    cpp-utilities
  ];

  cmakeFlags = [
    "-DQT_PACKAGE_PREFIX=Qt${lib.versions.major qtbase.version}"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Common Qt related C++ classes and routines used by @Martchus' applications such as dialogs, widgets and models Topics";
    homepage = "https://github.com/Martchus/qtutilities";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
