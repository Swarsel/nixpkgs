{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  icoutils,
  icu,
  makeDesktopItem,
  nix-update-script,
  openssl,
  zlib,
}:
buildDotnetModule rec {
  pname = "lumafly";
  version = "3.3.0.0";

  src = fetchFromGitHub {
    owner = "TheMulhima";
    repo = "lumafly";
    tag = "v${version}";
    hash = "sha256-GVPMAwxbq9XlKjMKd9G5yUol42f+6lSyHukN7NMCVDA=";
  };

  nativeBuildInputs = [
    icoutils
    copyDesktopItems
  ];

  postFixup = ''
    # Icon for the desktop file
    icotool -x $src/Lumafly/Assets/Lumafly.ico
    install -D Lumafly_1_32x32x32.png $out/share/icons/hicolor/32x32/apps/lumafly.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "A cross platform mod manager for Hollow Knight written in Avalonia";
      desktopName = "Lumafly";
      exec = "Lumafly";
      icon = "lumafly";
      name = "lumafly";
      type = "Application";
    })
  ];

  dotnet-runtime = dotnetCorePackages.sdk_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  # Use .NET 9.0 since 7.0 is EOL
  dotnetFlags = [ "-p:TargetFramework=net9.0" ];
  executables = [ "Lumafly" ];
  nugetDeps = ./deps.json;
  projectFile = "Lumafly/Lumafly.csproj";

  runtimeDeps = [
    zlib
    icu
    openssl
  ];

  selfContainedBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross platform mod manager for Hollow Knight written in Avalonia";
    homepage = "https://themulhima.github.io/Lumafly/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rohanssrao ];
    platforms = lib.platforms.linux;
    mainProgram = "Lumafly";
  };
}
