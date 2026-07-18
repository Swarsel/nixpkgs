{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  meson-python,
  numpy,
  # nativeBuildInputs
  pkg-config,
  # tests
  pytestCheckHook,
  # dependencies
  scikit-learn,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fastcan";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "scikit-learn-contrib";
    repo = "fastcan";
    tag = "v${version}";
    hash = "sha256-1ncdzBMJYEwTkpLXS64g+SaEbsiYslX7zN4xbGjUsAA=";
  };

  nativeBuildInputs = [ pkg-config ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Prevent pytest from importing the required python modules from the source instead of $out
  preCheck = ''
    rm -f fastcan/__init__.py
    echo "" > fastcan/narx/__init__.py
  '';

  build-system = [
    cython
    meson-python
    numpy
    setuptools
  ];

  dependencies = [ scikit-learn ];
  pyproject = true;
  pythonImportsCheck = [ "fastcan" ];

  meta = {
    description = "Library for fast canonical-correlation-based search algorithm";
    homepage = "https://github.com/scikit-learn-contrib/fastcan";
    changelog = "https://github.com/scikit-learn-contrib/fastcan/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
}
