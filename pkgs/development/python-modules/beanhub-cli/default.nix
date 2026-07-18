{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  attrs,
  # dependencies
  beancount-black,
  beancount-parser,
  beanhub-forms,
  beanhub-import,
  beanhub-inbox,
  buildPythonPackage,
  click,
  cryptography,
  fastapi,
  hatchling,
  httpx,
  jinja2,
  pydantic,
  pydantic-settings,
  pynacl,
  # tests
  pytest-asyncio,
  pytest-factoryboy,
  pytest-httpx,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  rich,
  starlette-wtf,
  tomli,
  tomli-w,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "beanhub-cli";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "beanhub-cli";
    tag = version;
    hash = "sha256-hreVGsptCGW6L3rj6Ec8+lefZWpQ4tZtUEJI+NxTO7w=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-factoryboy
    pytest-httpx
    pytest-mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    beancount-black
    beancount-parser
    beanhub-forms
    beanhub-import
    beanhub-inbox
    click
    fastapi
    jinja2
    pydantic
    pydantic-settings
    pyyaml
    rich
    starlette-wtf
    uvicorn
  ]
  ++ lib.concatAttrValues optional-dependencies;

  optional-dependencies = {
    connect = [
      attrs
      cryptography
      httpx
      pynacl
      python-dateutil
      tomli
      tomli-w
    ];

    login = [
      attrs
      httpx
      python-dateutil
      tomli
      tomli-w
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "beanhub_cli" ];
  pythonRelaxDeps = [ "rich" ];

  meta = {
    description = "Command line tools for BeanHub or Beancount users";
    homepage = "https://github.com/LaunchPlatform/beanhub-cli/";
    changelog = "https://github.com/LaunchPlatform/beanhub-cli/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fangpen ];
    mainProgram = "bh";
  };
}
