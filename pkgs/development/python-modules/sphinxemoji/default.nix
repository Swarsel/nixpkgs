{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  sphinx,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "sphinxemoji";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "emojicodes";
    tag = "v${version}";
    hash = "sha256-2/2fOIxjF4vs90uqZyzfidrh+P/MHa+LTf1RsQYmgZ0=";
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
    # sphinxemoji.py imports pkg_resources directly
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinxemoji" ];

  meta = {
    description = "Extension to use emoji codes in your Sphinx documentation";
    homepage = "https://github.com/sphinx-contrib/emojicodes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
