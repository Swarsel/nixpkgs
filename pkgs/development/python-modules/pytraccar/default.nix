{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytraccar";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = "pytraccar";
    tag = version;
    hash = "sha256-DtxZCvLuvQpbu/1lIXz2BVbACt5Q1N2txVMyqwd4d9A=";
  };

  postPatch = ''
    # Upstream doesn't set version in the repo
    substituteInPlace pyproject.toml \
      --replace 'version = "0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "pytraccar" ];

  meta = {
    description = "Python library to handle device information from Traccar";
    homepage = "https://github.com/ludeeus/pytraccar";
    changelog = "https://github.com/ludeeus/pytraccar/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
