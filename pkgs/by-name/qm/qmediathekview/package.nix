{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cargo,
  pkg-config,
  qt6Packages,
  rustPlatform,
  sqlite,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "QMediathekView";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "adamreichold";
    repo = "QMediathekView";
    tag = "v${finalAttrs.version}";
    hash = "sha256-miqCzNTqbZwPuy6P911wlf5TF1lECzNW/02/edK8XaU=";
  };

  postPatch = ''
    substituteInPlace QMediathekView.pro \
      --replace /usr ""
  '';

  nativeBuildInputs = [
    qt6Packages.qmake
    cargo
    pkg-config
    qt6Packages.wrapQtAppsHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    sqlite
    xz
    boost
  ];

  env.HOST_AR = lib.getExe' stdenv.cc.bintools.bintools "ar";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-89ogtmtJRgMoPOjyW+OGoptKE8VP9lUhbsB5vrdP7zQ=";
  };

  cargoRoot = "internals";
  installFlags = [ "INSTALL_ROOT=$(out)" ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Alternative Qt-based front-end for the database maintained by the MediathekView project";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "QMediathekView";
    broken = stdenv.hostPlatform.isAarch64;
  };
})
