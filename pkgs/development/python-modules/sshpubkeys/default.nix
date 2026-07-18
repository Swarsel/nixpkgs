{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sshpubkeys";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "ojarva";
    repo = "python-sshpubkeys";
    # https://github.com/ojarva/python-sshpubkeys/issues/94
    tag = "v3.2.0";
    hash = "sha256-2OJatnQuCt9XQ797F5nEmgEZl5/tu9lrAry5yBGW61g=";
  };

  build-system = [ setuptools ];

  dependencies = [
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "sshpubkeys" ];

  meta = {
    description = "OpenSSH Public Key Parser for Python";
    homepage = "https://github.com/ojarva/python-sshpubkeys";
    changelog = "https://github.com/ojarva/python-sshpubkeys/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
