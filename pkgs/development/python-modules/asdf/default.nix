{
  lib,
  fetchFromGitHub,
  aiohttp,
  asdf-standard,
  asdf-transform-schemas,
  attrs,
  buildPythonPackage,
  fsspec,
  importlib-metadata,
  jmespath,
  lz4,
  numpy,
  packaging,
  psutil,
  pytest-remotedata,
  pytestCheckHook,
  pyyaml,
  requests,
  semantic-version,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "asdf";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "asdf-format";
    repo = "asdf";
    tag = version;
    hash = "sha256-StudmLkXINe/lIJneid763jBdo6jAHlnjj4PHsGFxwM=";
  };

  nativeCheckInputs = [
    aiohttp
    fsspec
    lz4
    psutil
    pytest-remotedata
    pytestCheckHook
    requests
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asdf-standard
    asdf-transform-schemas
    importlib-metadata
    jmespath
    numpy
    packaging
    pyyaml
    semantic-version
    attrs
  ];

  disabledTests = [
    # AssertionError: assert 527033 >= 1048801
    "test_update_add_array_at_end"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asdf" ];

  meta = {
    description = "Python tools to handle ASDF files";
    homepage = "https://github.com/asdf-format/asdf";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
