{
  lib,
  stdenv,
  fetchFromGitHub,
  corrscope,
  ffmpeg,
  gitUpdater,
  python3Packages,
  qt6Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "corrscope";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "corrscope";
    repo = "corrscope";
    tag = finalAttrs.version;
    hash = "sha256-76qa4jOSncK1eDly/uXJzpWWdsEz7Hg3DyFb7rmrQBc=";
  };

  nativeBuildInputs = with qt6Packages; [
    wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg
  ]
  ++ (
    with qt6Packages;
    [
      qtbase
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      qtwayland
    ]
  );

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
      "''${qtWrapperArgs[@]}"
    )
  '';

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = (
    with python3Packages;
    [
      appdirs
      atomicwrites
      attrs
      click
      colorspacious
      matplotlib
      numpy
      qtpy
      pyqt6
      ruamel-yaml
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      appnope
    ]
  );

  dontWrapQtApps = true;
  pyproject = true;

  pythonRelaxDeps = [
    "ruamel-yaml"
  ];

  passthru = {
    tests.version = testers.testVersion {
      # Tries writing to
      # - $HOME/.local/share/corrscope on Linux
      # - $HOME/Library/Application Support/corrscope on Darwin
      command = "env HOME=$TMPDIR ${lib.getExe corrscope} --version";
      package = corrscope;
    };

    updateScript = gitUpdater {
      allowedVersions = "^[0-9.]+$";
    };
  };

  meta = {
    description = "Render wave files into oscilloscope views, featuring advanced correlation-based triggering algorithm";

    longDescription = ''
      Corrscope renders oscilloscope views of WAV files recorded from chiptune (game music from
      retro sound chips).

      Corrscope uses "waveform correlation" to track complex waves (including SNES and Sega
      Genesis/FM synthesis) which jump around on other oscilloscope programs.
    '';

    homepage = "https://github.com/corrscope/corrscope";
    changelog = "https://github.com/corrscope/corrscope/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.all;
    mainProgram = "corr";
  };
})
