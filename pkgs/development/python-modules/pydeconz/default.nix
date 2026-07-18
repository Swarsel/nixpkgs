{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  orjson,
  pytest-aiohttp,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydeconz";
  version = "120";

  src = fetchFromGitHub {
    owner = "Kane610";
    repo = "deconz";
    tag = "v${version}";
    hash = "sha256-L9v6j8CFc19TlcFBTm3YCQG1nS78uIUfERB6mfwzMNM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==77.0.3" "setuptools" \
      --replace-fail "wheel==" "wheel>="
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "pydeconz" ];

  meta = {
    description = "Python library wrapping the Deconz REST API";
    homepage = "https://github.com/Kane610/deconz";
    changelog = "https://github.com/Kane610/deconz/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pydeconz";
  };
}
