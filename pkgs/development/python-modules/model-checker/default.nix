{
  lib,
  buildPythonPackage,
  fetchPypi,
  networkx,
  setuptools,
  tqdm,
  z3-solver,
}:

buildPythonPackage rec {
  pname = "model-checker";
  version = "1.2.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vIH3CFgFEO+UlmpS7FhBsQtZv5Yep4OQ6koMGzyJGa4=";
    pname = "model_checker";
  };

  # Tests have multiple issues, ImportError, TypeError, etc.
  # Check with the next release > 0.3.13
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    networkx
    tqdm
    z3-solver
  ];

  pyproject = true;
  pythonImportsCheck = [ "model_checker" ];
  # z3 does not provide a dist-info, so python-runtime-deps-check will fail
  pythonRemoveDeps = [ "z3-solver" ];

  meta = {
    description = "Hyperintensional theorem prover for counterfactual conditionals and modal operators";
    homepage = "https://pypi.org/project/model-checker/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
