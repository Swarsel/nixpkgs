{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  gtk3,
  libnotify,
  makeDesktopItem,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "pablodraw";
  version = "3.1.14-beta";

  src = fetchFromGitHub {
    owner = "cwensley";
    repo = "pablodraw";
    tag = version;
    hash = "sha256-p2YeWC3ZZOI5zDpgDmEX3C5ByAAjLxJ0CqFAqKeoJ0Q=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    copyDesktopItems
  ];

  postInstall = ''
    install -Dm644 Assets/PabloDraw-512.png $out/share/icons/hicolor/512x512/apps/pablodraw.png
    install -Dm644 Assets/PabloDraw-64.png $out/share/icons/hicolor/64x64/apps/pablodraw.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Graphics" ];
      comment = "An Ansi/Ascii text and RIPscrip vector graphic art editor/viewer";
      desktopName = "PabloDraw";
      exec = "PabloDraw";
      icon = "pablodraw";
      name = "PabloDraw";
      terminal = false;
      type = "Application";
    })
  ];

  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetFlags = [
    "-p:EnableCompressionInSingleFile=false"
    "-p:TargetFrameworks=net9.0"
  ];

  executables = [ "PabloDraw" ];
  nugetDeps = ./deps.json;
  projectFile = "Source/PabloDraw/PabloDraw.csproj";

  runtimeDeps = [
    gtk3
    libnotify
  ];

  meta = {
    description = "Ansi/Ascii text and RIPscrip vector graphic art editor/viewer with multi-user capabilities";
    homepage = "https://picoe.ca/products/pablodraw";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aleksana
      kip93
    ];

    platforms = lib.platforms.all;
    mainProgram = "PabloDraw";
    broken = stdenv.hostPlatform.isDarwin; # Eto.Platform.Mac64 not found in nugetSource
  };
}
