{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  nix-update-script,
  pkg-config,
  python3,
  rocksdb_9_10,
  testers,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fulcrum";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "cculianu";
    repo = "Fulcrum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ygUzDhqUDeoNgNNXjuIfcy1b5B1KxDGBV4dMdn83GR8=";
  };

  nativeBuildInputs = [
    pkg-config
    libsForQt5.qmake
  ];

  buildInputs = [
    python3
    libsForQt5.qtbase
    rocksdb_9_10
    zeromq
  ];

  dontWrapQtApps = true; # no GUI

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast & nimble SPV server for Bitcoin Cash & Bitcoin BTC";
    homepage = "https://github.com/cculianu/Fulcrum";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prusnak ];
    platforms = lib.platforms.unix;
    mainProgram = "Fulcrum";
  };
})
