{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymunk";
  version = "7.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8wRYlyYTJbs+iShEAt1DuQjQpYcdwgEFl+NrQwnwIps=";
  };

  nativeBuildInputs = [ cffi ];

  preBuild = ''
    ${python.pythonOnBuildForHost.interpreter} setup.py build_ext --inplace
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ cffi ];
  enabledTestPaths = [ "pymunk/tests" ];
  pyproject = true;
  pythonImportsCheck = [ "pymunk" ];

  meta = {
    description = "2d physics library";
    homepage = "https://www.pymunk.org";
    changelog = "https://github.com/viblo/pymunk/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.unix;
  };
}
