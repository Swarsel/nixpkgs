{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "leb128";
  version = "1.0.9";

  # fetchPypi doesn't include files required for tests
  src = fetchFromGitHub {
    owner = "mohanson";
    repo = "leb128";
    tag = "v${version}";
    hash = "sha256-X3iBYiANzM97M91dCyjEU/Onhqcid3MMsNzzKtcRcyA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "leb128" ];

  meta = {
    description = "Utility to encode and decode Little Endian Base 128";
    homepage = "https://github.com/mohanson/leb128";
    changelog = "https://github.com/mohanson/leb128/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
