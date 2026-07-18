{
  lib,
  stdenv,
  fetchFromGitHub,
  ctags,
  gdb,
  libsForQt5,
  makeWrapper,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "gede";
  version = "2.22.1";

  src = fetchFromGitHub {
    owner = "jhn98032";
    repo = "gede";
    tag = "v${version}";
    hash = "sha256-6YSrqLDuV4G/uvtYy4vzbwqrMFftMvZdp3kr3R436rs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ctags
    makeWrapper
    python3
    libsForQt5.qmake
    libsForQt5.qtserialport
    libsForQt5.wrapQtAppsHook
  ];

  installPhase = ''
    python build.py install --verbose --prefix="$out"
    wrapProgram $out/bin/gede \
      --prefix QT_PLUGIN_PATH : ${libsForQt5.qtbase}/${libsForQt5.qtbase.qtPluginPrefix} \
      --prefix PATH : ${
        lib.makeBinPath [
          ctags
          gdb
        ]
      }
  '';

  dontBuild = true;
  dontUseQmakeConfigure = true;

  meta = {
    description = "Graphical frontend (GUI) to GDB";
    homepage = "http://gede.dexar.se";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ juliendehos ];
    platforms = lib.platforms.linux;
    mainProgram = "gede";
  };
}
