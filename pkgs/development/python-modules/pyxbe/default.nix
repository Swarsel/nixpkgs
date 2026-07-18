{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyxbe";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "mborgerson";
    repo = "pyxbe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MtkY4vwPvlYoS4ws8MzIFR8D6ORVqFXA0JvOEspzmtQ=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xbe" ];

  meta = {
    description = "Library to work with XBE files";
    homepage = "https://github.com/mborgerson/pyxbe";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
