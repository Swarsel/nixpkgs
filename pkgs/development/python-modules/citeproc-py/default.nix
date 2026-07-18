{
  lib,
  buildPythonPackage,
  fetchPypi,
  git,
  lxml,
  pytestCheckHook,
  rnc2rng,
  setuptools,
}:

buildPythonPackage rec {
  pname = "citeproc-py";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-WHgdilY+h8p8zrQ9CL6soQ3N+fPPd93zsXiUBx7cJ8g=";
    pname = "citeproc_py";
  };

  buildInputs = [ rnc2rng ];

  nativeCheckInputs = [
    git
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ lxml ];
  pyproject = true;
  pythonImportsCheck = [ "citeproc" ];

  meta = {
    description = "Citation Style Language (CSL) parser for Python";
    homepage = "https://github.com/citeproc-py/citeproc-py";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "csl_unsorted";
  };
}
