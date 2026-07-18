{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  freezegun,
  gitMinimal,
  hatch-vcs,
  # build system
  hatchling,
  httpx,
  # test
  mercurial,
  pydantic,
  pydantic-settings,
  pytest-cov-stub,
  pytest-localserver,
  pytest-mock,
  pytestCheckHook,
  questionary,
  rich,
  rich-click,
  tomlkit,
  versionCheckHook,
  wcmatch,
}:

buildPythonPackage rec {
  pname = "bump-my-version";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "callowayproject";
    repo = "bump-my-version";
    tag = version;
    hash = "sha256-fqbh1Ul1TzB2/HkTTlGFoUO6/hLNLNykcXjNb6I+Kpc=";
  };

  env = {
    GIT_AUTHOR_EMAIL = "test@example.com";
    GIT_AUTHOR_NAME = "test";
    GIT_COMMITTER_EMAIL = "test@example.com";
    GIT_COMMITTER_NAME = "test";
  };

  nativeCheckInputs = [
    mercurial
    gitMinimal
    freezegun
    pytest-cov-stub
    pytest-localserver
    pytest-mock
    pytestCheckHook
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    click
    httpx
    pydantic
    pydantic-settings
    questionary
    rich-click
    rich
    tomlkit
    wcmatch
  ];

  pyproject = true;
  pythonImportsCheck = [ "bumpversion" ];

  meta = {
    description = "Small command line tool to update version";

    longDescription = ''
      This is a maintained refactor of the bump2version fork of the
      excellent bumpversion project. This is a small command line tool to
      simplify releasing software by updating all version strings in your source code
      by the correct increment and optionally commit and tag the changes.
    '';

    homepage = "https://github.com/callowayproject/bump-my-version";
    changelog = "https://github.com/callowayproject/bump-my-version/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daspk04 ];
    mainProgram = "bump-my-version";
  };
}
