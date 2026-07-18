{
  lib,
  buildPythonPackage,
  fetchPypi,
  pbr,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "beconde-py";
  version = "4.0.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-KiTM2hclpRplCJPQtjJgE4NZ6qKZu256CZYTUKKm4Fw=";
    pname = "bencode.py";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
    pbr
  ];

  pyproject = true;
  pythonImportsCheck = [ "bencodepy" ];

  meta = {
    description = "Simple bencode parser (for Python 2, Python 3 and PyPy)";
    homepage = "https://github.com/fuzeman/bencode.py";
    license = lib.licenses.bitTorrent11;
    maintainers = with lib.maintainers; [ vamega ];
  };
})
