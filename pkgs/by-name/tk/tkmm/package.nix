{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  glew,
  libGL,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  makeDesktopItem,
}:
buildDotnetModule (finalAttrs: {
  pname = "Tkmm";
  version = "2.0.0-beta3";

  src = fetchFromGitHub {
    owner = "TKMM-Team";
    repo = "Tkmm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XdnNKnusvWhNy/0rQCULft6ztsB/nhTeQiN4F9LmxJE=";
    fetchSubmodules = true;
  };

  patches = [ ./patchTk.diff ];
  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -D distribution/appimage/tkmm.svg $out/share/icons/hicolor/scalable/apps/tkmm.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
      ];

      comment = "Tears of the Kingdom Mod Manager";
      desktopName = "TKMM";
      exec = "Tkmm";
      icon = "tkmm";
      name = "Tears of the Kingdom Mod Manager";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetFlags = [
    ''-p:DefineConstants="READONLY_FS"''
  ];

  enableParallelBuilding = false;

  executables = [
    "Tkmm"
    "Tkmm.CLI"
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "src/Tkmm/Tkmm.csproj"
    "src/Tkmm.CLI/Tkmm.CLI.csproj"
  ];

  runtimeDeps = [
    # Avalonia UI
    libx11
    libGL
    glew
    libice
    libsm
    libxcursor
    libxext
    libxi
    libxrandr
  ];

  selfContainedBuild = true;

  meta = {
    description = "Tears of the Kingdom Mod Manager, a mod merger and manager for TotK";
    homepage = "https://tkmm.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rucadi
    ];

    platforms = lib.platforms.unix;
    mainProgram = "Tkmm";
  };
})
