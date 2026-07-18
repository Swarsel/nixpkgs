{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "javaproperties";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "javaproperties";
    tag = "v${version}";
    sha256 = "sha256-8Deo6icInp7QpTqa+Ou6l36/23skxKOYRef2GbumDqo=";
  };

  nativeCheckInputs = [
    python-dateutil
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  disabledTestPaths = [ "test/test_propclass.py" ];
  disabledTests = [ "time" ];
  pyproject = true;

  meta = {
    description = "Python library for reading and writing Java .properties files";
    homepage = "https://github.com/jwodder/javaproperties";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
