{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  poetry-core,

  # tests
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "tomlkit";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zwDvykFdvVdXW++x9mNMT0LS2H27o3YSittCwSG4cGQ=";
  };

  nativeCheckInputs = [
    pyyaml
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "tomlkit" ];

  meta = {
    description = "Style-preserving TOML library for Python";
    homepage = "https://github.com/sdispater/tomlkit";
    changelog = "https://github.com/sdispater/tomlkit/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
}
