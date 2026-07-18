{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  pytestCheckHook,
  pyyaml,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "ua-parser-rs";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "ua-parser";
    repo = "uap-rust";
    tag = "ua-parser-rs-${version}";
    hash = "sha256-8IU4NNW0v2zl6COtL6o7FALxqYNVKBGhERugxpXIN5g=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  buildAndTestSubdir = "ua-parser-py";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-PNkyd9/0DdIqEmXbnw3dZs5ajWSo0rLhjJwRu3H06Cc=";
  };

  format = "setuptools";
  passthru.updateScript = gitUpdater { rev-prefix = "ua-parser-rs-"; };

  meta = {
    description = "Native accelerator for ua-parser";
    homepage = "https://github.com/ua-parser/uap-rust/tree/main/ua-parser-py";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
