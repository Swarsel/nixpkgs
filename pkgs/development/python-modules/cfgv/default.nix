{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cfgv";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "cfgv";
    tag = "v${version}";
    hash = "sha256-ccCalTNVEHvh1gKhQgceD/yAScIEQy3ZKqndoWs7FQQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "cfgv" ];

  meta = {
    description = "Validate configuration and produce human readable error messages";
    homepage = "https://github.com/asottile/cfgv";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
