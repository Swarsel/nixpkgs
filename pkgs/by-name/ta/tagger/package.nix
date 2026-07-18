{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  buildDotnetModule,
  chromaprint,
  dotnetCorePackages,
  glib,
  gtk4,
  libadwaita,
}:

let
  dotnet = dotnetCorePackages.dotnet_8;
in

buildDotnetModule rec {
  pname = "tagger";
  version = "2024.6.0-1";

  src = fetchFromGitHub {
    owner = "nlogozzo";
    repo = "NickvisionTagger";
    rev = version;
    hash = "sha256-4OfByQYhLXmeFWxzhqt8d7pLUyuMLhDM20E2YcA9Q3s=";
  };

  nativeBuildInputs = [
    blueprint-compiler
  ];

  buildInputs = [
    chromaprint
    libadwaita
  ];

  postInstall = ''
    substituteInPlace NickvisionTagger.Shared/Linux/org.nickvision.tagger.desktop.in --replace '@EXEC@' "NickvisionTagger.GNOME"
    install -Dm444 NickvisionTagger.Shared/Resources/org.nickvision.tagger.svg -t $out/share/icons/hicolor/scalable/apps/
    install -Dm444 NickvisionTagger.Shared/Resources/org.nickvision.tagger-symbolic.svg -t $out/share/icons/hicolor/symbolic/apps/
    install -Dm444 NickvisionTagger.Shared/Linux/org.nickvision.tagger.desktop.in -T $out/share/applications/org.nickvision.tagger.desktop
  '';

  dotnet-runtime = dotnet.runtime;
  dotnet-sdk = dotnet.sdk;
  executables = [ "NickvisionTagger.GNOME" ];
  nugetDeps = ./deps.json;
  projectFile = "NickvisionTagger.GNOME/NickvisionTagger.GNOME.csproj";

  runtimeDeps = [
    glib
    gtk4
    libadwaita
  ];

  meta = {
    description = "Easy-to-use music tag (metadata) editor";
    homepage = "https://github.com/NickvisionApps/Tagger";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zendo
      ratcornu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "NickvisionTagger.GNOME";
  };
}
