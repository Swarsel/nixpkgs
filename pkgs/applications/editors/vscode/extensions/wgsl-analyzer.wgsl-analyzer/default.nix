{
  lib,
  jq,
  moreutils,
  vscode-utils,
  wgsl-analyzer,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postPatch = ''
    jq '(.contributes.configuration[] | select(.title == "server") | .properties."wgsl-analyzer.server.path".default) = $s' \
      --arg s "${lib.getExe wgsl-analyzer}" \
      package.json | sponge package.json
  '';

  nativeBuildInputs = [
    jq
    moreutils
  ];

  mktplcRef = {
    version = "0.11.318";
    hash = "sha256-px6lKME6aapi9L9Owb3zhbEMoKmA9GpBQrHtb8Kg0XI=";
    name = "wgsl-analyzer";
    publisher = "wgsl-analyzer";
  };

  meta = {
    description = "Extension that integrates wgsl-analyzer a wgsl language server into VSCode";
    homepage = "https://github.com/wgsl-analyzer/wgsl-analyzer";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ timon ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=wgsl-analyzer.wgsl-analyzer";
  };
}
