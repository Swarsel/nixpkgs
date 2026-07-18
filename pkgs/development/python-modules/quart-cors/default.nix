{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  pdm-backend,
  pytest-asyncio,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # propagates
  quart,
}:

buildPythonPackage rec {
  pname = "quart-cors";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "pgjones";
    repo = "quart-cors";
    tag = version;
    hash = "sha256-f+l+j0bjzi5FTwJzdXNyCgh3uT4zldpg22ZOgW1Wub4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ pdm-backend ];
  dependencies = [ quart ];
  pyproject = true;
  pythonImportsCheck = [ "quart_cors" ];

  meta = {
    description = "Quart-CORS is an extension for Quart to enable and control Cross Origin Resource Sharing, CORS";
    homepage = "https://github.com/pgjones/quart-cors/";
    changelog = "https://github.com/pgjones/quart-cors/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
