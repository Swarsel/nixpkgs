{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  # dependencies
  boltons,
  buildPythonPackage,
  daemontools,
  dask,
  distributed,
  hypothesis,
  orjson,
  pandas,
  pyrsistent,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  testtools,
  twisted,
  versioneer,
  zope-interface,
}:

buildPythonPackage (finalAttrs: {
  pname = "eliot";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "itamarst";
    repo = "eliot";
    tag = finalAttrs.version;
    hash = "sha256-YUvHdnpWtsy2NlrVLaaewcUPKGLfdfX/zvowV0jcXuw=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    dask
    distributed
    hypothesis
    pandas
    pytestCheckHook
    testtools
    twisted
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ daemontools ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
    versioneer
  ];

  dependencies = [
    boltons
    orjson
    pyrsistent
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "eliot" ];

  meta = {
    description = "Logging library that tells you why it happened";
    homepage = "https://eliot.readthedocs.io";
    changelog = "https://github.com/itamarst/eliot/blob/${finalAttrs.version}/docs/source/news.rst";
    license = lib.licenses.asl20;
    mainProgram = "eliot-prettyprint";
  };
})
