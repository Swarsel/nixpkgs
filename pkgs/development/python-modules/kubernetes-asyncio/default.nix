{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  certifi,
  coreutils,
  # tests
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  # build-system
  setuptools,
  six,
  urllib3,
}:

buildPythonPackage rec {
  pname = "kubernetes-asyncio";
  version = "33.3.0";

  src = fetchFromGitHub {
    owner = "tomplus";
    repo = "kubernetes_asyncio";
    tag = version;
    hash = "sha256-Ei5Y2IBBk8AoMQQBHOvKkJ1H+9dmnz22qrrZKrWazVE=";
  };

  postPatch = ''
    substituteInPlace kubernetes_asyncio/config/google_auth_test.py \
      --replace-fail "/bin/echo" "${lib.getExe' coreutils "echo"}"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    certifi
    python-dateutil
    pyyaml
    six
    urllib3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "kubernetes_asyncio"
  ];

  meta = {
    description = "Python asynchronous client library for Kubernetes http://kubernetes.io";
    homepage = "https://github.com/tomplus/kubernetes_asyncio";
    changelog = "https://github.com/tomplus/kubernetes_asyncio/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
