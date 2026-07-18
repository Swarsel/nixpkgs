{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  ffmpeg,
  ncurses,
}:

buildDotnetModule {
  pname = "bms-to-osu";
  version = "2.5-unstable-2025-01-14"; # 2.5 crashes at runtime due to missing kernel32.dll

  src = fetchFromGitHub {
    owner = "QingQiz";
    repo = "BmsToOsu";
    rev = "e6b9dbf44ccdda7db15bf28e32d1fc1e5431319f"; # tag = "v${version}";
    hash = "sha256-JaehaKjV2fGyH6hAKwoo0t2B+hRWOjpQoIJpZq8J8C8=";
  };

  executables = [ "BmsToOsu" ];

  makeWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    "${ffmpeg}/bin"
  ];

  nugetDeps = ./deps.json;
  projectFile = "BmsToOsu.sln";
  runtimeDeps = [ ncurses ];

  meta = {
    description = "Convert BMS files to osu! beatmap files";
    homepage = "https://github.com/QingQiz/BmsToOsu";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.unix;
    mainProgram = "BmsToOsu";
  };
}
