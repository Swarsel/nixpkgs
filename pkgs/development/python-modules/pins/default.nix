{
  lib,
  fetchFromGitHub,
  adlfs,
  appdirs,
  buildPythonPackage,
  databackend,
  fastparquet,
  fsspec,
  gcsfs,
  humanize,
  importlib-metadata,
  importlib-resources,
  jinja2,
  joblib,
  pandas,
  pyarrow,
  pytest-cases,
  pytest-parallel,
  pytestCheckHook,
  pyyaml,
  requests,
  s3fs,
  setuptools,
  setuptools-scm,
  typing-extensions,
  xxhash,
}:

buildPythonPackage rec {
  pname = "pins";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "rstudio";
    repo = "pins-python";
    tag = "v${version}";
    hash = "sha256-fDbgas4RG4cJRqrISWmrMUQUycQindlqF9/jA5R1TF8=";
  };

  nativeCheckInputs = [
    fastparquet
    pyarrow
    pytest-cases
    pytest-parallel
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    appdirs
    databackend
    fsspec
    humanize
    importlib-metadata
    importlib-resources
    jinja2
    joblib
    pandas
    pyyaml
    requests
    typing-extensions
    xxhash
  ];

  disabledTestPaths = [
    # Tests require network access
    "pins/tests/test_boards.py"
    "pins/tests/test_compat.py"
    "pins/tests/test_constructors.py"
    "pins/tests/test_rsconnect_api.py"
  ];

  enabledTestPaths = [ "pins/tests/" ];

  optional-dependencies = {
    aws = [ s3fs ];
    azure = [ adlfs ];
    gcs = [ gcsfs ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pins" ];

  pythonRelaxDeps = [
    "fsspec"
  ];

  meta = {
    description = "Module to publishes data, models and other Python objects";
    homepage = "https://github.com/rstudio/pins-python";
    changelog = "https://github.com/rstudio/pins-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
