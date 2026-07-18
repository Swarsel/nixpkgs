{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  p11-kit,
  polkit,
  stdenvNoCC,
  tpm2-openssl,
  tpm2-tss,
}:
let
  version = "0.67.3";

  srcs = {
    aarch64-linux = fetchurl {
      sha256 = "sha256-0Vefuc+Xnx8x6Gu+WuS4zTHDIMepY593uFi3JKD+hrk=";
      url = "https://github.com/smallstep/step-agent-plugin/releases/download/v${version}/step-agent_${version}_linux_arm64.tar.gz";
    };

    x86_64-linux = fetchurl {
      sha256 = "sha256-sTZ6dNjyRwCWHWROUKCpq1rb8n9lT0cGOUOUpui9NJM=";
      url = "https://github.com/smallstep/step-agent-plugin/releases/download/v${version}/step-agent_${version}_linux_amd64.tar.gz";
    };
  };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "step-agent";

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    autoPatchelfHook
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -vr ./step-agent $out/bin/step-agent
    wrapProgram $out/bin/step-agent --prefix PATH : ${
      lib.makeBinPath [
        tpm2-tss
        tpm2-openssl
        polkit
        p11-kit
      ]
    }
  '';

  __structuredAttrs = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "step-agent is an automated certificate management agent plugin for step-cli";
    homepage = "https://github.com/smallstep/step-agent-plugin/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ Srylax ];
    platforms = lib.platforms.linux;
    mainProgram = "step-agent";
  };
}
