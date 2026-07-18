{
  lib,
  fetchFromGitHub,
  # buildInputs
  blas,
  # build-system
  blis,
  buildPythonPackage,
  # dependencies
  catalogue,
  confection,
  cymem,
  cython,
  # tests
  hypothesis,
  murmurhash,
  numpy,
  preshed,
  pydantic,
  pytestCheckHook,
  setuptools,
  srsly,
  wasabi,
}:

buildPythonPackage (finalAttrs: {
  pname = "thinc";
  version = "8.3.12";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "thinc";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-8nf+AWAD7Fy50XRJDINmyk42F7KMDhGgATwqbln3r04=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail coverage.exceptions.CoverageWarning ""
  '';

  buildInputs = [
    blas
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  # avoid local paths, relative imports wont resolve correctly
  preCheck = ''
    mv thinc/tests tests
    rm -r thinc
  '';

  build-system = [
    blis
    cymem
    cython
    murmurhash
    numpy
    preshed
    setuptools
  ];

  dependencies = [
    blis
    catalogue
    confection
    cymem
    murmurhash
    numpy
    preshed
    pydantic
    srsly
    wasabi
  ];

  disabledTestPaths = [
    # pydantic.v1.error_wrappers.ValidationError: 1 validation error for DefaultsSchema
    "tests/test_config.py"
  ];

  disabledTests = [
    # RecursionError: Stack overflow (used 8148 kB)
    "test_pickle_with_flatten"
  ];

  pyproject = true;

  pytestFlags = [
    # UserWarning: Core Pydantic V1 functionality isn't compatible with Python 3.14 or greater.
    "-Wignore::UserWarning"
  ];

  pythonImportsCheck = [ "thinc" ];

  meta = {
    description = "Library for NLP machine learning";
    homepage = "https://github.com/explosion/thinc";
    changelog = "https://github.com/explosion/thinc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
