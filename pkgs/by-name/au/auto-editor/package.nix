{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNimPackage,
  config,
  dav1d,
  ffmpeg-full,
  lame,
  libopus,
  libvpx,
  python3,
  python3Packages,
  x264,
  yt-dlp,
}:

buildNimPackage rec {
  pname = "auto-editor";
  version = "30.4.0";

  src = fetchFromGitHub {
    owner = "WyattBlue";
    repo = "auto-editor";
    tag = version;
    hash = "sha256-AzUTDOWzyhZLrwqO9HfZ/Ke72LElJAMzVoDydBfYKwg=";
  };

  postPatch = ''
    substituteInPlace src/log.nim \
      --replace-fail '"yt-dlp"' '"${lib.getExe yt-dlp}"'

    # buildNimPackage hack
    substituteInPlace ae.nimble \
      --replace-fail '"main=auto-editor"' '"main"'

    mv tests/unit.nim tests/tunit.nim # buildNimPackage expects tests to start with t
  '';

  buildInputs = [
    ffmpeg-full
    lame
    libopus
    x264
    dav1d
  ];

  env = {
    # Nothing should be dynamically linked, as ffmpeg should already link it.
    DISABLE_HEVC = "1";
    DISABLE_SVTAV1 = "1";
    DISABLE_VPL = "1";
    DISABLE_VPX = "1";
    DISABLE_WHISPER = "1";
  };

  nativeCheckInputs = [
    python3
    python3Packages.av
  ];

  checkPhase = ''
    runHook preCheck

    nim_builder --phase:check

    substituteInPlace tests/test.py \
      --replace-fail '"./auto-editor"' "\"$out/bin/main\""

    python3 tests/test.py

    runHook postCheck
  '';

  postInstall = ''
    mv $out/bin/main $out/bin/auto-editor
  '';

  lockFile = ./lock.json;

  meta = {
    description = "Command line application for automatically editing video and audio by analyzing a variety of methods, most notably audio loudness";
    homepage = "https://auto-editor.com/";
    changelog = "https://github.com/WyattBlue/auto-editor/releases/tag/${src.tag}";
    license = lib.licenses.unlicense;

    maintainers = with lib.maintainers; [
      tomasajt
      utopiatopia
    ];

    platforms = lib.platforms.unix;
    mainProgram = "auto-editor";
  };
}
