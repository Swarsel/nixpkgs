{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  numpy,
  # tests
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "py-stringmatching";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "anhaidgroup";
    repo = "py_stringmatching";
    tag = "v${version}";
    hash = "sha256-gQiIIN0PeeM81ZHsognPFierf9ZXasq/JqxsYZmLAnU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd $out
  '';

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    numpy
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_stringmatching" ];

  meta = {
    description = "Python string matching library including string tokenizers and string similarity measures";
    homepage = "https://github.com/anhaidgroup/py_stringmatching";
    changelog = "https://github.com/anhaidgroup/py_stringmatching/blob/v${version}/CHANGES.txt";
    license = lib.licenses.bsd3;
    broken = lib.versionAtLeast numpy.version "2";
  };
}
