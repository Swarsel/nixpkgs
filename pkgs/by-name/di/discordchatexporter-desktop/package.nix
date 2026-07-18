{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "discordchatexporter-desktop";
  version = "2.47.3";

  src = fetchFromGitHub {
    owner = "tyrrrz";
    repo = "discordchatexporter";
    tag = finalAttrs.version;
    hash = "sha256-B/2krGBYp/6qgINRyX/38tHlEy9JxmQMAIPsDNjZF5k=";
  };

  patches = [ ./settings-path.patch ];
  env.XDG_CONFIG_HOME = "$HOME/.config";

  postFixup = ''
    ln -s $out/bin/DiscordChatExporter $out/bin/discordchatexporter
  '';

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  nugetDeps = ./deps.json;
  projectFile = "DiscordChatExporter.Gui/DiscordChatExporter.Gui.csproj";
  passthru.updateScript = ./updater.sh;

  meta = {
    description = "Tool to export Discord chat logs to a file (GUI version)";
    homepage = "https://github.com/Tyrrrz/DiscordChatExporter";
    changelog = "https://github.com/Tyrrrz/DiscordChatExporter/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      phanirithvij
      willow
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "discordchatexporter";
  };
})
