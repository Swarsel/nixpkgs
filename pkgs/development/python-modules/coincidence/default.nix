{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-regressions,
  pytest-timeout,
  pytestCheckHook,
  toml,
  typing-extensions,
  whey,
}:

buildPythonPackage rec {
  pname = "coincidence";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "python-coincidence";
    repo = "coincidence";
    tag = "v${version}";
    hash = "sha256-ktSuUzAwMych6Y2eJWMUfG1a3mGypg8L20f/105RFXc=";
  };

  nativeCheckInputs = [
    pytest-regressions
    pytest-timeout
    pytestCheckHook
    toml
  ];

  build-system = [ whey ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "coincidence" ];

  meta = {
    description = "Helper functions for pytest";
    homepage = "https://github.com/python-coincidence/coincidence";
    changelog = "https://github.com/python-coincidence/coincidence/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
