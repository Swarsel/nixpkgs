{
  lib,
  stdenv,
  vscode-utils,
}:

let
  supported = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-6NhhAhE+r3m5tY1eR8ibKeMivmCqPooAt2rkWjWkv2w=";
    };

    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-ugluaghNNZ/VrQORVIhc0Fuv3rHo++LO3Uwg2ujmsQc=";
    };

    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-jfjd2V7IJ4GQlz/pXmrY/LlBjQ2qtlsQV4ZRD8RiWTg=";
    };
  };

  base =
    supported.${stdenv.hostPlatform.system}
      or (throw "unsupported platform ${stdenv.hostPlatform.system}");

in
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = base // {
    version = "0.18.0";
    name = "docker";
    publisher = "docker";
  };

  meta = {
    description = "Official Docker DX (Developer Experience) extension. Edit smarter, ship faster with an enhanced Docker-development experience.";
    homepage = "https://github.com/docker/vscode-extension#readme";
    changelog = "https://marketplace.visualstudio.com/items/docker.docker/changelog";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.kozm9000 ];
    platforms = builtins.attrNames supported;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=docker.docker";
  };
}
