{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  redis,
  redisTestHook,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "walrus";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "coleifer";
    repo = "walrus";
    tag = finalAttrs.version;
    hash = "sha256-AgaqDZHjUX/oLjzisWjZcrGL9QXQf73WW+hfK2WMQJ8=";
  };

  nativeCheckInputs = [
    unittestCheckHook
    redisTestHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ redis ];
  pyproject = true;
  pythonImportsCheck = [ "walrus" ];

  meta = {
    description = "Lightweight Python utilities for working with Redis";
    homepage = "https://github.com/coleifer/walrus";
    changelog = "https://github.com/coleifer/walrus/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
