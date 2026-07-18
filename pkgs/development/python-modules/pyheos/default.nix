{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "pyheos";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "andrewsayre";
    repo = "pyheos";
    tag = version;
    hash = "sha256-CqUeDIHRD+stIVr9nMqfKUExVHPq8gbIzsZg8U36E7I=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTests = [
    # accesses network
    "test_connect_timeout"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # OSError: could not bind on any address out of [('127.0.0.2', 1255)]
    "test_failover"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyheos" ];

  meta = {
    description = "Async python library for controlling HEOS devices through the HEOS CLI Protocol";
    homepage = "https://github.com/andrewsayre/pyheos";
    changelog = "https://github.com/andrewsayre/pyheos/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
