{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "useful-types";
  version = "0.2.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hwoLzI/LfQsvFAVUOMHKt+JI/e2UKwlDpNcBnn+72s0=";
    pname = "useful_types";
  };

  build-system = [
    flit-core
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "useful_types" ];

  meta = {
    description = "Useful types for Python";
    homepage = "https://github.com/hauntsaninja/useful_types";
    changelog = "https://github.com/hauntsaninja/useful_types/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ different-name ];
  };
}
