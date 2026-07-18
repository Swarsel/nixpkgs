{
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
  versionCheckHook,
}:

let
  version = "3000.1.27";

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-OnpANdMh9ws9FHwfwWR63OSaC/P3MB+eAV33JxQNUaQ=";
      url = "https://static.devin.ai/cli/${version}/devin-${version}-aarch64-apple-darwin.tar.gz";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-gyWbCpfLNphBjoSGVIhi7hgGToBKceavEKn//yDA1uw=";
      url = "https://static.devin.ai/cli/${version}/devin-${version}-aarch64-unknown-linux.tar.gz";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-y0kHpKT2wZvquR0EOIpFN2EMC84BpOOOKLXWwE0nygo=";
      url = "https://static.devin.ai/cli/${version}/devin-${version}-x86_64-unknown-linux.tar.gz";
    };
  };
in

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "devin-cli";
  src = srcs.${stdenvNoCC.hostPlatform.system} or throwSystem;

  outputs = [
    "out"
    "man"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    installBin ./bin/devin
    installManPage ./share/man/man1/*.1

    mkdir -p $out/share/doc

    mv ./share/devin/docs/* $out/share/doc

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Cognition's Devin Agent CLI";
    homepage = "https://devin.ai/cli";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      ethancedwards8
      nhshah15
    ];

    mainProgram = "devin";
  };
})
