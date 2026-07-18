{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  distro,
  matrix-nio,
  pytestCheckHook,
  requests,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "zulip";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "zulip";
    repo = "python-zulip-api";
    tag = version;
    hash = "sha256-mcqIfha+4nsqlshayLQ2Sd+XOYVKf1FkoczjiFRNybc=";
  };

  nativeCheckInputs = [
    matrix-nio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    distro
    click
    typing-extensions
  ]
  ++ requests.optional-dependencies.security;

  pyproject = true;
  pythonImportsCheck = [ "zulip" ];
  sourceRoot = "${src.name}/zulip";

  meta = {
    description = "Bindings for the Zulip message API";
    homepage = "https://github.com/zulip/python-zulip-api";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
