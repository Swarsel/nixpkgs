{
  lib,
  anyio,
  buildPythonPackage,
  dirty-equals,
  distro,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatchling,
  # Dependencies
  httpx,
  llama-index-core,
  pydantic,
  pytest-asyncio,
  pytest-xdist,
  # Test dependencies
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  respx,
  sniffio,
}:

buildPythonPackage (finalAttrs: {
  pname = "llama-cloud";
  version = "2.11.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-vvyYS5vxN2cMEIEAy82qd1PCxh/TYcDOL6YivkjN9c0=";
    pname = "llama_cloud";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.26.3" "hatchling>=1.26.3"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-xdist
    dirty-equals
    respx
  ]
  ++ lib.optional (pythonOlder "3.14") llama-index-core;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    httpx
    pydantic
    distro
    sniffio
    anyio
  ];

  # Transitively requires google-pasta (broken on 3.14) through llama-index-core
  disabledTestPaths = lib.optional (pythonAtLeast "3.14") "tests/test_index.py";
  pyproject = true;
  pythonImportsCheck = [ "llama_cloud" ];

  meta = {
    description = "LlamaIndex Python Client";
    homepage = "https://pypi.org/project/llama-cloud/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
