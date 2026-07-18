{
  lib,
  fetchFromGitHub,
  ffmpeg,
  meson,
  ninja,
  pkg-config,
  python3,
  qt6,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "persepolis";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "persepolisdm";
    repo = "persepolis";
    tag = finalAttrs.version;
    hash = "sha256-E295Y76EmG6H1nwu7d4+OVPRtoCthROqYY5sIsBvUPI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    qt6.qtbase
  ];

  propagatedBuildInputs = (
    with python3.pkgs;
    [
      psutil
      pyside6
      pysocks
      urllib3
      dasbus
      requests
      setproctitle
      setuptools
      yt-dlp
    ]
  );

  # prevent double wrapping
  dontWrapQtApps = true;

  # feed args to wrapPythonApp
  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
      ]
    }"
    "\${qtWrapperArgs[@]}"
  ];

  pyproject = false;

  meta = {
    description = "Download manager GUI written in Python";
    homepage = "https://persepolisdm.github.io/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      iFreilicht
      L0L1P0P
    ];

    mainProgram = "persepolis";
  };
})
