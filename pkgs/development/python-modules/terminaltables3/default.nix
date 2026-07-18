{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  colorclass,
  poetry-core,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  termcolor,
}:

buildPythonPackage rec {
  pname = "terminaltables3";
  version = "4.0.0-unstable-2024-07-21";

  src = fetchFromGitHub {
    owner = "matthewdeanmartin";
    repo = "terminaltables3";
    #tag = "v${version}";
    rev = "f1c465b36eb9b91a984d8864b21376e7c37075b8";
    hash = "sha256-UcEovh1Eb4QNPwLGDjCphPlJSSkOdhCJ2fK3tuSWOTc=";
  };

  nativeCheckInputs = [
    colorama
    colorclass
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
    termcolor
  ];

  build-system = [ poetry-core ];

  disabledTests = [
    # Tests are comparing CLI output
    "test_color"
    "test_colors"
    "test_height"
    "test_width"
  ];

  pyproject = true;
  pythonImportsCheck = [ "terminaltables3" ];

  meta = {
    description = "Generate simple tables in terminals from a nested list of strings";
    homepage = "https://github.com/matthewdeanmartin/terminaltables3";
    changelog = "https://github.com/matthewdeanmartin/terminaltables3/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
