{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  construct,
  pytestCheckHook,
  python-dateutil,
  six,
}:

buildPythonPackage rec {
  pname = "procmon-parser";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "eronnen";
    repo = "procmon-parser";
    tag = "v${version}";
    hash = "sha256-XkMf3MQK4WFRLl60XHDG/j2gRHAiz7XL9MmC6SRg9RE=";
  };

  propagatedBuildInputs = [
    construct
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
    python-dateutil
  ];

  format = "setuptools";
  pythonImportsCheck = [ "procmon_parser" ];

  meta = {
    description = "Parser to process monitor file formats";
    homepage = "https://github.com/eronnen/procmon-parser/";
    changelog = "https://github.com/eronnen/procmon-parser/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
