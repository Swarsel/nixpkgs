{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  docutils,
  pygments,
  # test dependencies
  pytest,
  # build-system
  setuptools,
  # runtime dependencies
  sphinx,
  # documentation build dependencies
  sphinxHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-tabs";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "executablebooks";
    repo = "sphinx-tabs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OuGrrlCEkTxu3WueCPHHuEeMGXPf/lrETbTP/9uVWbU=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    setuptools
    sphinxHook
  ];

  propagatedBuildInputs = [
    sphinx
    pygments
    docutils
  ];

  nativeCheckInputs = [
    pytest
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_tabs" ];

  meta = {
    description = "Sphinx extension for creating tabbed content when building HTML";
    homepage = "https://github.com/executablebooks/sphinx-tabs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
})
