{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  coverage,
  jinja2,
  msgspec,
  pydantic,
  pytest,
  pytest-asyncio,
  pytest-cov-stub,
  # Test dependencies
  pytestCheckHook,
  # Dependencies
  pyyaml,
  sanic-testing,
  # Build system
  setuptools,
  tox,
}:

buildPythonPackage rec {
  pname = "sanic-ext";
  version = "25.12.0";

  src = fetchFromGitHub {
    owner = "sanic-org";
    repo = "sanic-ext";
    tag = "v${version}";
    hash = "sha256-h1yN5VYFPFUZoeZeJ6+CfGE3m/5zz+/G3BbetDKtZAo=";
  };

  nativeCheckInputs = [
    pytestCheckHook

    sanic-testing
    attrs
    coverage
    msgspec
    pydantic
    pytest
    pytest-cov-stub
    pytest-asyncio
    tox
    jinja2
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
  ];

  disabledTests = [
    "test_models[FooPydanticDataclass]" # KeyError: 'paths'
    "test_pydantic_base_model[AlertResponsePydanticBaseModel-True]" # AssertionError: assert 'AlertPydanticBaseModel' in {'AlertResponsePydanticBaseModel': ... }
    "test_pydantic_base_model[AlertResponsePydanticDataclass-True]" # AssertionError: assert 'AlertPydanticDataclass' in {'AlertResponsePydanticDataclass': ... }
  ];

  pyproject = true;
  pythonImportsCheck = [ "sanic_ext" ];

  meta = {
    description = "Common, officially supported extension plugins for the Sanic web server framework";
    homepage = "https://github.com/sanic-org/sanic-ext/";
    changelog = "https://github.com/sanic-org/sanic-ext/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ p0lyw0lf ];
  };
}
