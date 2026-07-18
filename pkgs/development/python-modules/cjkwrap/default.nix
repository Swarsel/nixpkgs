{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cjkwrap";
  version = "2.2";

  src = fetchFromGitLab {
    owner = "fgallaire";
    repo = "cjkwrap";
    rev = "v${version}";
    hash = "sha256-0wTx3rnlUfQEE2/Z8Y7iwlsHk+CIy6ut+QIpC5yg4aM=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cjkwrap" ];

  meta = {
    description = "Library for wrapping and filling CJK text";
    homepage = "https://f.gallai.re/cjkwrap";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.kaction ];
  };
}
