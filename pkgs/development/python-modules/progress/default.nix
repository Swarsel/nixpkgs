{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "progress";
  version = "1.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wbpxn4Ys6IUjKnWeq0eXH+dN/Hu3arilHvWUC601CGw=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} test_progress.py
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Easy to use progress bars";
    homepage = "https://github.com/verigak/progress/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
