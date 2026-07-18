{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-re2,
  pytestCheckHook,
  pyyaml,
  setuptools,
  ua-parser-builtins,
  ua-parser-rs,
}:

buildPythonPackage rec {
  pname = "ua-parser";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "ua-parser";
    repo = "uap-python";
    tag = version;
    hash = "sha256-KKQlM1AonRqanhWlWIqPMoD+AzDCdwAzBsAbhqpZ4cs=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    pyyaml
    setuptools
  ];

  dependencies = [
    ua-parser-builtins
  ];

  optional-dependencies = {
    re2 = [ google-re2 ];
    regex = [ ua-parser-rs ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ua_parser" ];

  meta = {
    description = "Python implementation of the UA Parser";
    homepage = "https://github.com/ua-parser/uap-python";
    changelog = "https://github.com/ua-parser/uap-python/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
