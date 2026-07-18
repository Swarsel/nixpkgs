{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-asyncio,
  pytest-repeat,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "zict";
  version = "3.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-4yHiY7apeq/AeQw8+zwEZWtwZuZzjDf//MqV2APJ+6U=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    pytest-repeat
    pytest-timeout
  ];

  disabledTests = [
    # timeout
    "test_stress_different_keys_threadsafe"
  ];

  pyproject = true;

  meta = {
    description = "Mutable mapping tools";
    homepage = "https://github.com/dask/zict";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
  };
})
