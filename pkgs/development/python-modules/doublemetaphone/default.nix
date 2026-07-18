{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "doublemetaphone";
  version = "1.2i";

  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "doublemetaphone";
    tag = "v${version}";
    hash = "sha256-VPJqHxQHLiLSko+aJYTIgISluHPARgQN5pYWYxP9QKQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Prevent importing from source during test collection (only $out has compiled extensions)
  preCheck = ''
    rm -rf doublemetaphone
  '';

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "doublemetaphone"
  ];

  meta = {
    description = "Python wrapper for Double Metaphone phonetic encoding algorithm";
    homepage = "https://github.com/dedupeio/doublemetaphone";
    license = lib.licenses.artistic1;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
