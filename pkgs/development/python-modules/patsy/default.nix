{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy, # optional, allows spline-related features (see patsy's docs)
  setuptools,
}:

buildPythonPackage rec {
  pname = "patsy";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "pydata";
    repo = "patsy";
    tag = "v${version}";
    hash = "sha256-queErA3RdYBxIgOh3f2EfKPixpNfmevxLfNtjzcCCaI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "patsy" ];

  meta = {
    description = "Python package for describing statistical models";
    homepage = "https://github.com/pydata/patsy";
    changelog = "https://github.com/pydata/patsy/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ilya-kolpakov ];
  };
}
