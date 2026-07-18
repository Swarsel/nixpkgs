{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "openstep-plist";
  version = "0.5.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Kg1w/3oDzOZKcnBitkuy9cmvn9SmNqqkM5tqqiz2UZU=";
    pname = "openstep_plist";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "openstep_plist" ];

  meta = {
    description = "Parser for the 'old style' OpenStep property list format also known as ASCII plist";
    homepage = "https://github.com/fonttools/openstep-plist";
    changelog = "https://github.com/fonttools/openstep-plist/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
