{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "loro";
  version = "1.13.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DDcnvFL1CYV2Uy7dOZ78CM6yNMXZI1oZy9XqN8T7pIU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    rustPlatform.maturinBuildHook
    rustPlatform.cargoSetupHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-KVBe2bUvxilOysCVfcBSZCtwexlTkVAc83tH1H7nMbQ=";
  };

  pyproject = true;

  meta = {
    description = "Data collaborative and version-controlled JSON with CRDTs";
    homepage = "https://github.com/loro-dev/loro-py";
    changelog = "https://github.com/loro-dev/loro-py/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dmadisetti
    ];
  };
}
