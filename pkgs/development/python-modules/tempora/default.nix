{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jaraco-functools,
  pytest-freezer,
  pytestCheckHook,
  python-dateutil,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "tempora";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "tempora";
    tag = "v${version}";
    hash = "sha256-1Zeo8bUCHKPZ6I0HGT7bIh7IgbRL4j9Cv3t9FFiZ72s=";
  };

  postPatch = ''
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-freezer
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    jaraco-functools
    python-dateutil
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tempora"
    "tempora.schedule"
    "tempora.timing"
    "tempora.utc"
  ];

  meta = {
    description = "Objects and routines pertaining to date and time";
    homepage = "https://github.com/jaraco/tempora";
    changelog = "https://github.com/jaraco/tempora/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "calc-prorate";
  };
}
