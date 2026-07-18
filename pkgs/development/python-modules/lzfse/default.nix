{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lzfse";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "m1stadev";
    repo = "lzfse";
    tag = "v${version}";
    hash = "sha256-ER+Hr/WrGCB0uYwsSgB4U8sCPeZ4JlOHoeb5YEGUFFM=";
    fetchSubmodules = true;
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lzfse" ];

  meta = {
    description = "Python bindings for the LZFSE reference implementation";
    homepage = "https://github.com/m1stadev/lzfse";
    changelog = "https://github.com/m1stadev/lzfse/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
