{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  ipython,
  matplotlib,
  # check dependencies
  pytest,
  setuptools,
  # runtime dependencies
  sphinx,
  sphinx-rtd-theme,
  # documentation build dependencies
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "sphinx-codeautolink";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "felix-hilden";
    repo = "sphinx-codeautolink";
    tag = "v${version}";
    hash = "sha256-kNnz8MzffqPCxS0uXdbw2ntcdGnz6KDBanFug5+SjOk=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
    matplotlib
    ipython
  ];

  nativeCheckInputs = [ pytest ];
  build-system = [ setuptools ];

  dependencies = [
    sphinx
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_codeautolink" ];
  sphinxRoot = "docs/src";

  meta = {
    description = "Sphinx extension that makes code examples clickable";
    homepage = "https://github.com/felix-hilden/sphinx-codeautolink";
    changelog = "https://github.com/felix-hilden/sphinx-codeautolink/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
