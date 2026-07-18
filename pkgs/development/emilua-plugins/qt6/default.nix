{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  boost,
  emilua,
  fmt,
  gawk,
  gitUpdater,
  gperf,
  liburing,
  luajit_openresty,
  meson,
  ninja,
  openssl,
  pkg-config,
  qt6, # this
  qt6Packages,
  runCommand,
  xvfb-run,
}:

stdenv.mkDerivation rec {
  pname = "emilua-qt6";
  version = "1.2.2";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "qt6";
    rev = "v${version}";
    hash = "sha256-Ch99ntLreiOjACxyJVR4174sHJT8EYXzDGPdysqmBXM=";
  };

  nativeBuildInputs = with qt6Packages; [
    qttools
    wrapQtAppsHook
    gperf
    gawk
    asciidoctor
    pkg-config
    meson
    ninja
  ];

  buildInputs = with qt6Packages; [
    qtbase
    qtdeclarative
    boost
    luajit_openresty
    emilua
    fmt
    openssl
    liburing
  ];

  passthru = {
    tests.basic =
      runCommand "test-basic-qt6"
        {
          buildInputs = [
            emilua
            qt6
            qt6Packages.wrapQtAppsHook
            qt6Packages.qtbase
            qt6Packages.qtdeclarative
            xvfb-run
          ];

          dontWrapQtApps = true;
        }
        ''
          makeWrapper ${lib.getExe emilua} payload \
            ''${qtWrapperArgs[@]} \
            --add-flags ${./basic_test.lua}
          xvfb-run ./payload
          touch $out
        '';

    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Qt6 bindings for Emilua";
    homepage = "https://emilua.org/";
    license = lib.licenses.boost;

    maintainers = with lib.maintainers; [
      manipuladordedados
      lucasew
    ];

    platforms = lib.platforms.linux;
  };
}
