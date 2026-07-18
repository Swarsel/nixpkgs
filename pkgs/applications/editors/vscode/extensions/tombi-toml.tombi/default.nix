{
  lib,
  stdenv,
  vscode-utils,
}:

let
  supported = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-qe7K3PQIgZztIdOVx37LGXrzBmYui2o2CcmDK+5jaFM=";
    };

    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-iFHeZiTubXA/t2Gib9hP42d7yjq/WRyywp+l8VhGfmo=";
    };

    x86_64-linux = {
      arch = "linux-x64";
      hash = "sha256-DWrKvjWpUYvyqgZCShqwBKw33MHW31cxb4ERV65O+uc=";
    };
  };

  base =
    supported.${stdenv.hostPlatform.system}
      or (throw "unsupported platform ${stdenv.hostPlatform.system}");

in

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = base // {
    version = "1.1.7";
    name = "tombi";
    publisher = "tombi-toml";
  };

  meta = {
    description = "TOML Language Server";
    homepage = "https://tombi-toml.github.io/tombi/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.m0nsterrr ];
    platforms = builtins.attrNames supported;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=tombi-toml.tombi";
  };
}
