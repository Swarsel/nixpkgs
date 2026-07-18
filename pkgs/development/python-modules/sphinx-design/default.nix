{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  defusedxml,
  # build-system
  flit-core,
  # optional-dependencies
  furo,
  pydata-sphinx-theme,
  pytest-regressions,
  pytestCheckHook,
  pythonOlder,
  # dependencies
  sphinx,
  sphinx-book-theme,
  sphinx-rtd-theme,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-design";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "sphinx-design";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NlAAIw8X2gW2ejeSHcFrxj7Jl6OgnpZIXPK16yzxxRQ=";
  };

  nativeCheckInputs = [
    defusedxml
    pytest-regressions
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  dependencies = [ sphinx ];

  optional-dependencies = {
    theme-furo = [ furo ];
    theme-pydata = [ pydata-sphinx-theme ];
    theme-rtd = [ sphinx-rtd-theme ];
    theme-sbt = [ sphinx-book-theme ];
    # TODO: theme-im = [ sphinx-immaterial ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sphinx_design" ];
  pythonRelaxDeps = [ "sphinx" ];

  meta = {
    description = "Sphinx extension for designing beautiful, view size responsive web components";
    homepage = "https://github.com/executablebooks/sphinx-design";
    changelog = "https://github.com/executablebooks/sphinx-design/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
