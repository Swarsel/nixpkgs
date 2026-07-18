{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  setuptools,
  # runtime dependencies
  sphinx,
  sphinx-autoapi,
  sphinx-prompt,
  sphinx-rtd-theme,
  sphinx-tabs,
  # documentation build dependencies
  sphinxHook,
  sphinxemoji,
}:

buildPythonPackage rec {
  pname = "sphinx-notfound-page";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "readthedocs";
    repo = "sphinx-notfound-page";
    tag = version;
    hash = "sha256-KkdbK8diuQtZQk6FC9xDK/U7mfRBwwUmXp4YYuKueLQ=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    flit-core
    sphinxHook
    sphinx-prompt
    sphinx-rtd-theme
    sphinx-tabs
    sphinx-autoapi
    sphinxemoji
  ];

  buildInputs = [ sphinx ];
  propagatedBuildInputs = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "notfound" ];

  meta = {
    description = "Sphinx extension to create a custom 404 page with absolute URLs hardcoded";
    homepage = "https://github.com/readthedocs/sphinx-notfound-page";
    changelog = "https://github.com/readthedocs/sphinx-notfound-page/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
