{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lw12";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "jaypikay";
    repo = "python-lw12";
    tag = "v${version}";
    hash = "sha256-6zZolUfs1SzCH0DT2YYuP4eXt8Hxv+TYIDgLnR51MAQ=";
  };

  # Tests require hardware access
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Library to control the Lagute LW-12 WiFi LED controller";
    homepage = "https://github.com/jaypikay/python-lw12";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
