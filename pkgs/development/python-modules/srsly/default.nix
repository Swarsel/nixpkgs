{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  catalogue,
  # build-system
  cython,
  # tests
  mock,
  numpy,
  psutil,
  pytest,
  ruamel-yaml,
  setuptools,
  tornado,
}:

buildPythonPackage (finalAttrs: {
  pname = "srsly";
  version = "2.5.3";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "srsly";
    tag = "release-v${finalAttrs.version}";
    hash = "sha256-dZuw0+tNIMseznGBQwIS6uICZEozkBWzF7FMQIo0Tbo=";
  };

  nativeCheckInputs = [
    mock
    numpy
    psutil
    pytest
    ruamel-yaml
    tornado
  ];

  build-system = [
    cython
    setuptools
  ];

  dependencies = [ catalogue ];
  pyproject = true;
  pythonImportsCheck = [ "srsly" ];

  meta = {
    description = "Modern high-performance serialization utilities for Python";
    homepage = "https://github.com/explosion/srsly";
    changelog = "https://github.com/explosion/srsly/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
