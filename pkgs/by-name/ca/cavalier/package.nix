{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  buildDotnetModule,
  cava,
  desktop-file-utils,
  dotnetCorePackages,
  glib,
  gtk4,
  libGL,
  libadwaita,
  pkg-config,
  wrapGAppsHook4,
}:

buildDotnetModule rec {
  pname = "cavalier";
  version = "2024.1.0";

  src = fetchFromGitHub {
    owner = "NickvisionApps";
    repo = "Cavalier";
    tag = version;
    hash = "sha256-SFhEKtYrlnkbLMnxU4Uf4jnFsw0MJHstgZgLLnGC2d8=";
  };

  nativeBuildInputs = [
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  postInstall = ''
    substituteInPlace NickvisionCavalier.Shared/Linux/org.nickvision.cavalier.desktop.in \
      --replace-fail '@EXEC@' "NickvisionCavalier.GNOME"
    install -Dm444 NickvisionCavalier.Shared/Linux/org.nickvision.cavalier.desktop.in -T $out/share/applications/org.nickvision.cavalier.desktop
    install -Dm444 NickvisionCavalier.Shared/Resources/org.nickvision.cavalier.svg -t $out/share/icons/hicolor/scalable/apps/
    install -Dm444 NickvisionCavalier.Shared/Resources/org.nickvision.cavalier-symbolic.svg -t $out/share/icons/hicolor/symbolic/apps/
  '';

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = "NickvisionCavalier.GNOME";
  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ cava ]}" ];
  nugetDeps = ./deps.json;
  projectFile = "NickvisionCavalier.GNOME/NickvisionCavalier.GNOME.csproj";

  runtimeDeps = [
    glib
    gtk4
    libadwaita
    libGL
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Visualize audio with CAVA";
    homepage = "https://github.com/NickvisionApps/Cavalier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
    mainProgram = "NickvisionCavalier.GNOME";
  };
}
