{
  lib,
  fetchurl,
  autoPatchelfHook,
  grok-build,
  installShellFiles,
  runCommand,
  stdenvNoCC,
  testers,
  versionCheckHook,
}:
let
  version = "0.2.93";

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  platform = {
    aarch64-darwin = "macos-aarch64";
    aarch64-linux = "linux-aarch64";
    x86_64-linux = "linux-x86_64";
  };

  sourceData = lib.mapAttrs (
    system: upstreamPlatform:
    fetchurl {
      hash =
        {
          aarch64-darwin = "sha256-Kpe6Z1vZkqqbmB4ug3dkYNlPRptRDAuO/ii1DSNtdnw=";
          aarch64-linux = "sha256-7a4g6SoKM/7ewao0iPPjgI2MTKISj8jzE/vYGOPpX18=";
          x86_64-linux = "sha256-Tgc407VVDzyEK8CuafRogVxjKcAIoRDQwnppTcNAETU=";
        }
        .${system};

      url = "https://x.ai/cli/grok-${version}-${upstreamPlatform}";
    }
  ) platform;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "grok-build";
  src = sourceData.${stdenvNoCC.hostPlatform.system} or throwSystem;
  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/grok"
    ln -s grok "$out/bin/agent"

    ${lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
      installShellCompletion --cmd grok \
        --bash <("$out/bin/grok" completions bash) \
        --fish <("$out/bin/grok" completions fish) \
        --zsh <("$out/bin/grok" completions zsh)
    ''}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installCheckPhase = ''
    runHook preInstallCheck

    # ensure is a symlink
    test -L "$out/bin/agent"

    # ensure agent points at grok
    [ "$(readlink -f "$out/bin/agent")" = "$(readlink -f "$out/bin/grok")" ]

    runHook postInstallCheck
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontUnpack = true;
  versionCheckProgramArg = "--version";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Command-line coding agent by xAI";
    homepage = "https://docs.x.ai/build/overview";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ crertel ];
    platforms = lib.attrNames sourceData;
    mainProgram = "grok";
    downloadPage = "https://x.ai/cli/stable";
  };
})
