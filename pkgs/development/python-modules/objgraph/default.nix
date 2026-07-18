{
  lib,
  buildPythonPackage,
  fetchPypi,
  graphviz,
  graphvizPkgs,
  isPyPy,
  python,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "objgraph";
  version = "3.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ALny9A90IuPH9FphxNr9r4HwP/BknW6uyGbwEDDlGtg=";
  };

  patches = [
    (replaceVars ./hardcode-graphviz-path.patch {
      graphviz = graphvizPkgs;
    })
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests.py
    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  disabled = isPyPy;

  optional-dependencies = {
    ipython = [ graphviz ];
  };

  pyproject = true;
  pythonImportsCheck = [ "objgraph" ];

  meta = {
    description = "Draws Python object reference graphs with graphviz";
    homepage = "https://mg.pov.lt/objgraph/";
    changelog = "https://github.com/mgedmin/objgraph/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
