{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
  versionCheckHook,
}:

let
  sources = {
    "aarch64-linux" = {
      hash = "sha256-pHygFgvMdyh8NQeGwZ1iNkaU1q+pcxvn5/CaoO/amIc=";
      suffix = "linux_arm64";
    };

    "x86_64-linux" = {
      hash = "sha256-3TTVSCZcsUVfNzC9hWn0OLytMAOxL39f5IlqCReCw7g=";
      suffix = "linux_amd64";
    };
  };
  inherit (stdenvNoCC.hostPlatform) system;
  source = sources.${system} or (throw "pipekit: no prebuilt binary for ${system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pipekit";
  version = "6.65.5";

  src = fetchurl {
    inherit (source) hash;
    url = "https://github.com/pipekit/cli/releases/download/v${finalAttrs.version}/cli_${finalAttrs.version}_${source.suffix}.tar.gz";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 pipekit -t $out/bin
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for Pipekit. Observability, governance, and scale for Argo Workflows";
    homepage = "https://pipekit.io";
    changelog = "https://github.com/pipekit/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ jpz13 ];
    platforms = builtins.attrNames sources;
    mainProgram = "pipekit";
  };
})
