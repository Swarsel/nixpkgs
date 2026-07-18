{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  versionCheckHook,
}:

buildDotnetModule (finalAttrs: {
  pname = "discordchatexporter-cli";
  version = "2.47.3";

  src = fetchFromGitHub {
    owner = "tyrrrz";
    repo = "discordchatexporter";
    tag = finalAttrs.version;
    hash = "sha256-B/2krGBYp/6qgINRyX/38tHlEy9JxmQMAIPsDNjZF5k=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    ln -s $out/bin/DiscordChatExporter.Cli $out/bin/discordchatexporter-cli
  '';

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetBuildFlags = [
    # workaround for https://github.com/belav/csharpier/pull/1696
    # remove when csharpier is updated
    "-p:FirstTargetFrameworks=workaround-for-csharpier-pr-1696"
  ];

  nugetDeps = ./deps.json;
  projectFile = "DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj";
  passthru.updateScript = ./updater.sh;

  meta = {
    description = "Tool to export Discord chat logs to a file";
    homepage = "https://github.com/Tyrrrz/DiscordChatExporter";
    changelog = "https://github.com/Tyrrrz/DiscordChatExporter/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.unix;
    mainProgram = "discordchatexporter-cli";
  };
})
