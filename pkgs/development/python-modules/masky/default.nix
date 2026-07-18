{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  colorama,
  cryptography,
  impacket,
  pyasn1,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "masky";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Z4kSec";
    repo = "Masky";
    tag = "v${version}";
    hash = "sha256-npRuszHkxwjJ+B+q8eQywXPd0OX0zS+AfCro4TM83Uc=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools_80 ];

  dependencies = [
    asn1crypto
    colorama
    cryptography
    impacket
    pyasn1
  ];

  pyproject = true;
  pythonImportsCheck = [ "masky" ];

  meta = {
    description = "Library to remotely dump domain credentials";
    homepage = "https://github.com/Z4kSec/Masky";
    changelog = "https://github.com/Z4kSec/Masky/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "masky";
  };
}
