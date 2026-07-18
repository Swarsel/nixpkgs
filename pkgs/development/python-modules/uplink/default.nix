{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  marshmallow,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytest-twisted,
  pytestCheckHook,
  requests,
  six,
  twisted,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "uplink";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "prkumar";
    repo = "uplink";
    tag = "v${version}";
    hash = "sha256-gI7oHLyC6a5s3jhgG5jj+7q495seMSyUV4XVAp1URTA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    pytest-asyncio
    pytest-twisted
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    requests
    six
    uritemplate
  ];

  optional-dependencies = {
    aiohttp = [ aiohttp ];
    marshmallow = [ marshmallow ];
    pydantic = [ pydantic ];
    twisted = [ twisted ];
  };

  pyproject = true;
  pythonImportsCheck = [ "uplink" ];

  meta = {
    description = "Declarative HTTP client for Python";
    homepage = "https://github.com/prkumar/uplink";
    changelog = "https://github.com/prkumar/uplink/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
