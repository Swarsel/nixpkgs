{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  makeDesktopItem,
  nix-update-script,
  openal,
}:

buildDotnetModule rec {
  pname = "knossosnet";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "KnossosNET";
    repo = "Knossos.NET";
    tag = "v${version}";
    hash = "sha256-G/RSopDFn6ma5rXFkRth3NncbTVrVF6OqgqaJZl3EkE=";
  };

  patches = [ ./dotnet-8-upgrade.patch ];
  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -Dm444 $src/packaging/linux/knossos-512.png $out/share/icons/hicolor/512x512/apps/knossos.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Multi-platform launcher for Freespace 2 Open";
      desktopName = "Knossos.NET";
      exec = "Knossos.NET";
      icon = "knossos";
      name = "knossos";
    })
  ];

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  # IO errors in build due to solution building race
  enableParallelBuilding = false;
  executables = [ "Knossos.NET" ];
  nugetDeps = ./deps.json;
  runtimeDeps = [ openal ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-platform launcher for Freespace 2 Open";
    homepage = "https://fsnebula.org/knossos/";
    changelog = "https://github.com/KnossosNET/Knossos.NET/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ cdombroski ];
    platforms = lib.platforms.unix;
    mainProgram = "Knossos.NET";
  };
}
