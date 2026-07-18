{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-lv2-theme";
  version = "1.4.6";

  src = fetchFromGitLab {
    owner = "LV2";
    repo = "sphinx_lv2_theme";
    rev = "v${version}";
    hash = "sha256-WOunukFWa4AMrLpeKjuvmFT+3GhCzV3k/hl4mQXN0GQ=";
  };

  build-system = [ setuptools ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_lv2_theme" ];

  meta = {
    description = "Sphinx theme in the style of the LV2 plugin";
    homepage = "https://gitlab.com/lv2/sphinx_lv2_theme";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ samueltardieu ];
  };
}
