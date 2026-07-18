{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  more-itertools,
  # checks
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  typeguard,
}:

buildPythonPackage rec {
  pname = "inflect";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "inflect";
    tag = "v${version}";
    hash = "sha256-JQn0JySzXFnqz/dPc7BGLzd23Bh72S+/aI40gxAgx8k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    more-itertools
    typeguard
  ];

  disabledTests = [
    # https://errors.pydantic.dev/2.5/v/string_too_short
    "inflect.engine.compare"
  ];

  pyproject = true;
  pythonImportsCheck = [ "inflect" ];

  meta = {
    description = "Correctly generate plurals, singular nouns, ordinals, indefinite articles";
    homepage = "https://github.com/jaraco/inflect";
    changelog = "https://github.com/jaraco/inflect/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
