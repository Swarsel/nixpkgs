{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "py-datastruct";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "kuba2k2";
    repo = "datastruct";
    tag = "v${version}";
    hash = "sha256-oGgvEYfDVxSTrq5ymWyZx6WiTKsofNzQqUr6YBtfV2I=";
  };

  # Add nativeCheckInputs = [ pytestCheckHook ]; once we update to v2.0.0 tag and remove below line
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "datastruct" ];

  meta = {
    description = "Combination of struct and dataclasses for easy parsing of binary formats";
    homepage = "https://github.com/kuba2k2/datastruct";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mevatron ];
  };
}
