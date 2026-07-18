{
  lib,
  fetchFromGitHub,
  # tests
  aioresponses,
  buildHomeAssistantComponent,
  # dependencies
  mypyllant,
  polyfactory,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytest-xdist,
  pytestCheckHook,
  voluptuous,
}:

buildHomeAssistantComponent rec {
  version = "0.9.17";

  src = fetchFromGitHub {
    owner = "signalkraft";
    repo = "mypyllant-component";
    tag = "v${version}";
    hash = "sha256-OUNWju1g3vBjrUd/ZzQCMS08PWUyQUMnUkqElss9KaQ=";
  };

  nativeCheckInputs = [
    aioresponses
    polyfactory
    pytest-cov-stub
    pytest-homeassistant-custom-component
    pytest-xdist
    pytestCheckHook
  ];

  dependencies = [
    mypyllant
    voluptuous
  ];

  domain = "mypyllant";
  owner = "signalkraft";

  meta = {
    description = "Unofficial Home Assistant integration for interacting with myVAILLANT";
    homepage = "https://github.com/signalkraft/mypyllant-component";
    changelog = "https://github.com/signalkraft/mypyllant-component/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ urbas ];
  };
}
