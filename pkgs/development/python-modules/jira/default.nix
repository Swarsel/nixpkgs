{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  flaky,
  ipython,
  keyring,
  packaging,
  pillow,
  pyjwt,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  requests-futures,
  requests-mock,
  requests-oauthlib,
  requests-toolbelt,
  setuptools,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "jira";
  version = "3.10.5";

  src = fetchFromGitHub {
    owner = "pycontribs";
    repo = "jira";
    tag = version;
    hash = "sha256-Gj9RmNJwmYQviXeNLL6WWFIO91jy6zY/s29Gy18lzyA=";
  };

  # impure tests because of connectivity attempts to jira servers
  doCheck = false;

  nativeCheckInputs = [
    flaky
    pytestCheckHook
    pytest-cov-stub
    requests-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    defusedxml
    packaging
    requests
    requests-oauthlib
    requests-toolbelt
    pillow
    typing-extensions
  ];

  optional-dependencies = {
    async = [ requests-futures ];

    cli = [
      ipython
      keyring
    ];

    opt = [
      # filemagic
      pyjwt
      # requests-jwt
      # requests-keyberos
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jira" ];

  meta = {
    description = "Library to interact with the JIRA REST API";
    homepage = "https://github.com/pycontribs/jira";
    changelog = "https://github.com/pycontribs/jira/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "jirashell";
  };
}
