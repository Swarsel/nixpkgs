{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  sphinx,
  sphinx-rtd-theme,
}:

buildPythonPackage rec {
  pname = "sphinx-rtd-dark-mode";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "MrDogeBro";
    repo = "sphinx_rtd_dark_mode";
    tag = "v${version}";
    hash = "sha256-N5KG2Wqn9wfGNY3VH4FnBce1aZUbnvVmwD10Loe0Qn4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sphinx
  ];

  build-system = [ setuptools ];
  dependencies = [ sphinx-rtd-theme ];
  enabledTestPaths = [ "tests/build.py" ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_rtd_dark_mode" ];

  meta = {
    description = "Adds a toggleable dark mode to the Read the Docs theme for Sphinx";
    homepage = "https://github.com/MrDogeBro/sphinx_rtd_dark_mode";
    changelog = "https://github.com/MrDogeBro/sphinx_rtd_dark_mode/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wolfgangwalther ];
  };
}
