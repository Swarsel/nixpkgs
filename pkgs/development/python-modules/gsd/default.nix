{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gsd";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "glotzerlab";
    repo = "gsd";
    tag = "v${version}";
    hash = "sha256-qswKeZ8HJEjIV27O2UBmjN+Napa2sItECS5r/vb+l7k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    pushd gsd/test
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "gsd" ];

  meta = {
    description = "General simulation data file format";
    homepage = "https://github.com/glotzerlab/gsd";
    changelog = "https://github.com/glotzerlab/gsd/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "gsd";
  };
}
