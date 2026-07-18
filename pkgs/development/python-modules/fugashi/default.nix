{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  ipadic,
  mecab,
  pytestCheckHook,
  setuptools-scm,
  unidic,
  unidic-lite,
}:

buildPythonPackage rec {
  pname = "fugashi";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "polm";
    repo = "fugashi";
    tag = "v${version}";
    hash = "sha256-rkQskRz7lgVBrqBeyj9kWO2/7POrZ0TaM+Z7mhpZLvM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython~=3.0.11" "Cython"
  '';

  nativeCheckInputs = [
    ipadic
    pytestCheckHook
  ]
  ++ optional-dependencies.unidic-lite;

  preCheck = ''
    cd fugashi
  '';

  build-system = [
    cython
    mecab
    setuptools-scm
  ];

  optional-dependencies = {
    unidic = [ unidic ];
    unidic-lite = [ unidic-lite ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fugashi" ];

  meta = {
    description = "Cython MeCab wrapper for fast, pythonic Japanese tokenization and morphological analysis";
    homepage = "https://github.com/polm/fugashi";
    changelog = "https://github.com/polm/fugashi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
