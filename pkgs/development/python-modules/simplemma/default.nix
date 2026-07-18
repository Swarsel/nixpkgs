{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  marisa-trie,
  platformdirs,
  pytest,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "simplemma";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "adbar";
    repo = "simplemma";
    tag = "v${version}";
    hash = "sha256-VT6+wjyrHLquccnZpDTow7omDqeqlfbrdW3fozo/biU=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  optional-dependencies = {
    marisa-trie = [
      marisa-trie
      platformdirs
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "simplemma" ];

  meta = {
    description = "Simple multilingual lemmatizer for Python, especially useful for speed and efficiency";
    homepage = "https://github.com/adbar/simplemma";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
