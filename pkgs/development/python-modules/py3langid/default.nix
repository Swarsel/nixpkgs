{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py3langid";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CodaAxpYqvnb2nu4KF/XXoAae9J2IW/6vgN5AdS0Sew=";
  };

  # nixify path to the courlan binary in the test suite
  postPatch = ''
    substituteInPlace tests/test_langid.py --replace "'langid'" "'$out/bin/langid'"
    substituteInPlace pyproject.toml --replace-fail \
      'numpy >= 2.0.0' numpy
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ numpy ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "py3langid" ];

  meta = {
    description = "Fork of the language identification tool langid.py, featuring a modernized codebase and faster execution times";
    homepage = "https://github.com/adbar/py3langid";
    changelog = "https://github.com/adbar/py3langid/blob/v${version}/HISTORY.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jokatzke ];
    mainProgram = "langid";
  };
}
