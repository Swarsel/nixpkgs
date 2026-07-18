{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  cmake,
  lapack,
  nix-update-script,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtklib-ex";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "rtklibexplorer";
    repo = "RTKLIB";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j00VEQvxOiAc3EQX3x2b3RxYkbtvCZ17ugnW6b6ChWU=";
  };

  nativeBuildInputs = [
    cmake
    blas
    lapack
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialport
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_DATAROOTDIR" "${placeholder "out"}/share")
  ];

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open Source Program Package for GNSS Positioning";
    homepage = "https://rtkexplorer.com";
    changelog = "https://github.com/rtklibexplorer/RTKLIB/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.skaphi ];
    platforms = lib.platforms.linux;
  };
})
