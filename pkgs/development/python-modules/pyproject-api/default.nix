{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  furo,
  hatch-vcs,
  # build time
  hatchling,
  # runtime
  packaging,
  # tests
  pytest-mock,
  pytestCheckHook,
  sphinx-autodoc-typehints,
  # docs
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "pyproject-api";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "pyproject-api";
    tag = version;
    hash = "sha256-fWlGGVjB43NPfBRFfOWqZUDQuqOdrFP7jsqq9xOfvaw=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    # docs
    sphinxHook
    furo
    sphinx-autodoc-typehints
  ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "pyproject_api" ];

  meta = {
    description = "API to interact with the python pyproject.toml based projects";
    homepage = "https://github.com/tox-dev/pyproject-api";
    changelog = "https://github.com/tox-dev/pyproject-api/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
