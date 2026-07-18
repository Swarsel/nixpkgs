{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {

  pname = "source2viewer-cli";
  version = "19.2";

  src = fetchFromGitHub {
    owner = "ValveResourceFormat";
    repo = "ValveResourceFormat";
    tag = finalAttrs.version;
    hash = "sha256-4aUJlJWfNOqRXeLEHf8ZlXdcASGbmV2o1oFCcHpJG0w=";
  };

  strictDeps = true;
  __structuredAttrs = true;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  executables = [ "Source2Viewer-CLI" ];
  nugetDeps = ./deps.json;
  projectFile = "CLI/CLI.csproj";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Parser, decompiler, and exporter for Valve's Source 2 resource file format (VRF)";
    homepage = "https://github.com/ValveResourceFormat/ValveResourceFormat";
    changelog = "https://github.com/ValveResourceFormat/ValveResourceFormat/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ cr0n ];
    platforms = lib.platforms.linux;
    mainProgram = "Source2Viewer-CLI";
  };
})
