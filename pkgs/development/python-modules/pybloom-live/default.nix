{
  lib,
  bitarray,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  wheel,
  xxhash,
}:

buildPythonPackage rec {
  pname = "pybloom-live";
  version = "4.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-mVRcXTsFvTiLVJHja4I7cGgwpoa6GLTBkGPQjeUyERA=";
    pname = "pybloom_live";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    bitarray
    xxhash
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pybloom_live" ];

  meta = {
    description = "Probabilistic data structure";
    homepage = "https://github.com/joseph-fox/python-bloomfilter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
