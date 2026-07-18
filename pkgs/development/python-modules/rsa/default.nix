{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pyasn1,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rsa";
  version = "4.9";

  src = fetchFromGitHub {
    owner = "sybrenstuvel";
    repo = "python-rsa";
    rev = "version-${version}";
    hash = "sha256-PwaRe+ICy0UoguXSMSh3PFl5R+YAhJwNdNN9isadlJY=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ pyasn1 ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    sed -i '/addopts/d' tox.ini
  '';

  disabledTestPaths = [ "tests/test_mypy.py" ];
  pyproject = true;

  meta = {
    description = "Pure-Python RSA implementation";
    homepage = "https://stuvel.eu/rsa";
    license = lib.licenses.asl20;
  };
}
