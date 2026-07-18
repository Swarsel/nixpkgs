{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  flake8,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pytest-flake8";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "coherent-oss";
    repo = "pytest-flake8";
    tag = "v${version}";
    hash = "sha256-uc5DOqqdoLfhzI2ogDOqhbJOHzdu+uqSOojIH+S1LZI=";
  };

  patches = [
    # Drop deprecated `path` arg from pytest_collect_file hook. (https://github.com/coherent-oss/pytest-flake8/issues/5)
    (fetchpatch2 {
      hash = "sha256-mHGRKaMmDTJdj6ajWS0Dts1ZTbT1bNLMjOOZAP156Jg=";
      url = "https://raw.githubusercontent.com/OpenIndiana/oi-userland/0d06abedf17256d1f2c89086acc05cfa53dbc647/components/python/pytest-flake8/patches/02-deprecated-path.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dependencies = [ flake8 ];
  pyproject = true;

  meta = {
    description = "py.test plugin for efficiently checking PEP8 compliance";
    homepage = "https://github.com/coherent-oss/pytest-flake8";
    changelog = "https://github.com/coherent-oss/pytest-flake8/blob/${src.rev}/NEWS.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
