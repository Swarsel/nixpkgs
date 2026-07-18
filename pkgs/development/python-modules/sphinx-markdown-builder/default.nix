{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # deps
  docutils,
  nix-update-script,
  # tests
  pytestCheckHook,
  # build system
  setuptools,
  sphinx,
  sphinxcontrib-httpdomain,
  tabulate,
}:

buildPythonPackage rec {
  pname = "sphinx-markdown-builder";
  version = "0.6.10";

  src = fetchFromGitHub {
    owner = "liran-funaro";
    repo = "sphinx-markdown-builder";
    tag = version;
    hash = "sha256-97mlVD1MCtSw8AYyGc38auOrHU/vKH2aQJa4YIRQcBk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    sphinxcontrib-httpdomain
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    docutils
    sphinx
    tabulate
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sphinx_markdown_builder"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sphinx extension to add markdown generation support";
    homepage = "https://github.com/liran-funaro/sphinx-markdown-builder";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eljamm ];
  };
}
