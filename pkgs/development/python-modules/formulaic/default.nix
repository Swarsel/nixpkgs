{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  interface-meta,
  narwhals,
  numpy,
  pandas,
  polars,
  pyarrow,
  pytestCheckHook,
  scipy,
  sympy,
  typing-extensions,
  wrapt,
}:

buildPythonPackage rec {
  pname = "formulaic";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "matthewwardrop";
    repo = "formulaic";
    tag = "v${version}";
    hash = "sha256-C4IUuyxBbW2DUxF4at8/736ZMmVZrFRRp+RxrJfmLkY=";
  };

  # project uses a version-file that is not present in tagged releases
  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ optional-dependencies.arrow
  ++ optional-dependencies.calculus;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    narwhals
    numpy
    pandas
    scipy
    wrapt
    typing-extensions
    interface-meta
  ];

  optional-dependencies = {
    arrow = [ pyarrow ];
    calculus = [ sympy ];
    polars = [ polars ];
  };

  pyproject = true;
  pythonImportsCheck = [ "formulaic" ];

  meta = {
    description = "High-performance implementation of Wilkinson formulas";
    homepage = "https://matthewwardrop.github.io/formulaic/";
    changelog = "https://github.com/matthewwardrop/formulaic/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ swflint ];
  };
}
