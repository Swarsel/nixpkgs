{
  lib,
  stdenv,
  alsa-lib,
  autoPatchelfHook,
  stdenvNoCC,
  testers,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
  ];

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-YFLVhDckeXIItc+AvHlJ/B45c43Ubi3BKr8gy3Ui68w=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-jbTFmXqtdt6+1SdhfOLcnhOhtSESYM9th8k5EJ4Nex4=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-YVomTY/KpBcR4dZr0EN4egkuzvQXUCj7RvwgMo88z9Q=";
        };
      };
    in
    {
      version = "2.1.209";
      name = "claude-code";
      publisher = "anthropic";
    }
    // sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system ${stdenvNoCC.hostPlatform.system}");

  passthru.tests.bundled-claude-runs = testers.testVersion {
    command = "${finalAttrs.finalPackage}/share/vscode/extensions/anthropic.claude-code/resources/native-binary/claude --version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Harness the power of Claude Code without leaving your IDE";
    homepage = "https://docs.anthropic.com/s/claude-code";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code";
  };
})
