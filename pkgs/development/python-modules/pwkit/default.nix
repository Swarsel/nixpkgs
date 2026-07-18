{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pwkit";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "pkgw";
    repo = "pwkit";
    tag = "pwkit@${version}";
    hash = "sha256-lEa1AWBhevCOBiAJd0Q0VWDtjSK5O89LYTNnLxKfD8U=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "pwkit" ];

  meta = {
    description = "Miscellaneous science/astronomy tools";
    homepage = "https://github.com/pkgw/pwkit/";
    changelog = "https://github.com/pkgw/pwkit/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
