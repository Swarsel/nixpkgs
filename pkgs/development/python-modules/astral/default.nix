{
  lib,
  buildPythonPackage,
  fetchPypi,
  freezegun,
  # build
  poetry-core,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "astral";
  version = "3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-m3w7QS6eadFyz7JL4Oat3MnxvQGijbi+vmbXXMxTPYg=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "astral" ];

  meta = {
    description = "Calculations for the position of the sun and the moon";
    homepage = "https://github.com/sffjunkie/astral/";
    changelog = "https://github.com/sffjunkie/astral/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
