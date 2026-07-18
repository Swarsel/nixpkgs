{
  lib,
  # dependencies
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  # tests
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "openwebifpy";
  version = "4.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FaynJT+bR63nIwLEwXjTjwPXZ3Q5/X+zpx0gTA3Pqo8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    yarl
  ];

  disabledTests = [
    # https://github.com/autinerd/openwebifpy/issues/1
    "test_get_picon_name"
  ];

  pyproject = true;
  pythonImportsCheck = [ "openwebif" ];

  meta = {
    description = "Provides a python interface to interact with a device running OpenWebIf";
    homepage = "https://openwebifpy.readthedocs.io/";
    changelog = "https://github.com/autinerd/openwebifpy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    downloadPage = "https://github.com/autinerd/openwebifpy";
  };
}
