{
  lib,
  buildPythonPackage,
  defusedxml,
  fetchPypi,
  hatchling,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-moderncmakedomain";
  version = "3.29.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-NYfe8kH/JXfQu+8RgQoILp3sG3ij1LSgZiQLXz3BtbI=";
    pname = "sphinxcontrib_moderncmakedomain";
  };

  nativeCheckInputs = [
    defusedxml
    pytestCheckHook
    sphinx
  ];

  build-system = [ hatchling ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension which renders CMake documentation";
    homepage = "https://github.com/scikit-build/moderncmakedomain";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jhol ];
  };
}
