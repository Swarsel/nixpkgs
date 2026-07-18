{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  pytestCheckHook,
  setuptools,
  sphinx,
  sphinx-last-updated-by-git,
  sphinx-pytest,
}:
let
  pname = "sphinx-sitemap";
  version = "2.9.0";
in
buildPythonPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "jdillard";
    repo = "sphinx-sitemap";
    tag = "v${version}";
    hash = "sha256-TiR6F9wMWOGYexSKDzbSPPq0oiIDrZwSiO3a9DajL+0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sphinx-pytest
    defusedxml
  ];

  build-system = [ setuptools ];

  dependencies = [
    sphinx
    sphinx-last-updated-by-git
  ];

  pyproject = true;

  meta = {
    description = "Sitemap generator for Sphinx";
    homepage = "https://github.com/jdillard/sphinx-sitemap";
    changelog = "https://github.com/jdillard/sphinx-sitemap/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alejandrosame ];
  };
}
