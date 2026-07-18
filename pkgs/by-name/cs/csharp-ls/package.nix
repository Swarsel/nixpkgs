{
  lib,
  buildDotnetGlobalTool,
  dotnetCorePackages,
  nix-update-script,
  versionCheckHook,
}:
let
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
in

buildDotnetGlobalTool (finalAttrs: {
  inherit dotnet-sdk;
  pname = "csharp-ls";
  version = "0.25.0";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dotnet-runtime = dotnet-sdk;
  nugetHash = "sha256-w+zbCCR7ns8a5TqAOlwi5nE3AKWF9xhWG2jLmKbpzeI=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Roslyn-based LSP language server for C#";
    homepage = "https://github.com/razzmatazz/csharp-language-server";
    changelog = "https://github.com/razzmatazz/csharp-language-server/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.unix;

    badPlatforms = [
      # Crashes immediately at runtime
      # terminated by signal SIGKILL (Forced quit)
      # https://github.com/razzmatazz/csharp-language-server/issues/211
      "aarch64-darwin"
    ];

    mainProgram = "csharp-ls";
  };
})
