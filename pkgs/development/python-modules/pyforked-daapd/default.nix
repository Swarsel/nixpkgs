{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyforked-daapd";
  version = "0.1.14";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v1NOlwP8KtBsQiqwbx1y8p8lABEuEJdNhvR2kGzLxKs=";
  };

  # Tests require a running forked-daapd server
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyforked_daapd"
  ];

  meta = {
    description = "Python interface for forked-daapd";
    homepage = "https://github.com/uvjustin/pyforked-daapd";
    changelog = "https://github.com/uvjustin/pyforked-daapd/blob/v${version}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
