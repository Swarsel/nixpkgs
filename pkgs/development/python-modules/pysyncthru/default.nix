{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  demjson3,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysyncthru";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "nielstron";
    repo = "pysyncthru";
    tag = version;
    hash = "sha256-IJfj65p80Q4LwWkGV0A0QPtK2+FPkNVz9/WaNGzgTy8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    demjson3
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysyncthru" ];

  meta = {
    description = "Automated JSON API based communication with Samsung SyncThru Web Service";
    homepage = "https://github.com/nielstron/pysyncthru";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
