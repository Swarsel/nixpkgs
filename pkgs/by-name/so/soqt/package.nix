{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  coin3d,
  nix-update-script,
  qt6,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "soqt";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "coin3d";
    repo = "soqt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H904mFfrELjB6ZVhypaKJd+pu5y+aVV4foryrsN7IqE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  propagatedBuildInputs = [
    coin3d
    qt6.qtbase
  ];

  dontWrapQtApps = true;

  passthru = {
    tests = {
      cmake-config = testers.hasCmakeConfigModules {
        nativeBuildInputs = [ qt6.wrapQtAppsHook ];
        moduleNames = [ "soqt" ];
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Glue between Coin high-level 3D visualization library and Qt";
    homepage = "https://github.com/coin3d/soqt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
