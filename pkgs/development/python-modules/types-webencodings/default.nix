{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-webencodings";
  version = "0.5.0.20260408";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-KMWWYZ82fkPu45PYX2Po0v22h0xlSo1EHDf4r+KcbQ0=";
    pname = "types_webencodings";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "webencodings-stubs" ];

  meta = {
    description = "Typing stubs for webencodings";
    homepage = "https://pypi.org/project/types-webencodings/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
