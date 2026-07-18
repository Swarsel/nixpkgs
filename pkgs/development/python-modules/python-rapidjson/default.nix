{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pytz,
  rapidjson,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-rapidjson";
  version = "1.23";

  src = fetchFromGitHub {
    owner = "python-rapidjson";
    repo = "python-rapidjson";
    tag = "v${version}";
    hash = "sha256-BlEmEvwGAm3Ix2YwJSwrxgqqANqmgiWRiRWP91JITio=";
  };

  patches = [
    (replaceVars ./rapidjson-include-dir.patch {
      rapidjson = lib.getDev rapidjson;
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytz
  ];

  build-system = [ setuptools ];
  disabledTestPaths = [ "benchmarks" ];
  pyproject = true;

  meta = {
    description = "Python wrapper around rapidjson";
    homepage = "https://github.com/python-rapidjson/python-rapidjson";
    changelog = "https://github.com/python-rapidjson/python-rapidjson/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
