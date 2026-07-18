{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytun-pmd3";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "pytun-pmd3";
    tag = "v${version}";
    hash = "sha256-7kkQB+3MFq283JI2lbEBmpuV0S4KADibgIRBJWVp5Ug=";
  };

  # upstream has no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytun_pmd3" ];

  meta = {
    description = "TUN/TAP wrapper for Python with Darwin support";
    homepage = "https://github.com/doronz88/pytun-pmd3";
    changelog = "https://github.com/doronz88/pytun-pmd3/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
