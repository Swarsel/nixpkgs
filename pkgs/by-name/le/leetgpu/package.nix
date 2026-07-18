{
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
  versionCheckHook,
}:

let
  version = "1.2.0";

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-B1Sdyw+6fDBKS3PsINmiNA9PnOtEpDZiodFPsx+qk1Y=";
      url = "https://cli.leetgpu.com/dist/${version}/leetgpu-macos-arm64";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-3BcM0SHBugv/72iznR0q6t18B+u1f2auyUK1n1t5KBY=";
      url = "https://cli.leetgpu.com/dist/${version}/leetgpu-linux-arm64";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-um+KHqE1mmx7dkKm3pecrZSnsT+vbMh95kWQAsLGxFw=";
      url = "https://cli.leetgpu.com/dist/${version}/leetgpu-linux-amd64";
    };
  };

  src = srcs.${stdenvNoCC.hostPlatform.system} or throwSystem;
in

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  inherit src;
  pname = "leetgpu";
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${src} $out/bin/leetgpu

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  versionCheckProgramArg = "version";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Run CUDA kernels from your terminal";
    homepage = "https://leetgpu.com/cli";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    mainProgram = "leetgpu";
  };
})
