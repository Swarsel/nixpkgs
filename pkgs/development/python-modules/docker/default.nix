{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  # build-system
  hatchling,
  # dependencies
  packaging,
  # optional-dependencies
  paramiko,
  # tests
  pytestCheckHook,
  requests,
  urllib3,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "docker";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "docker-py";
    tag = version;
    hash = "sha256-sk6TZLek+fRkKq7kG9g6cR9lvfPC8v8qUXKb7Tq4pLU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    packaging
    requests
    urllib3
  ];

  # Deselect socket tests on Darwin because it hits the path length limit for a Unix domain socket
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "api_test"
    "stream_response"
    "socket_file"
  ];

  enabledTestPaths = [ "tests/unit" ];

  optional-dependencies = {
    ssh = [ paramiko ];
    tls = [ ];
    websockets = [ websocket-client ];
  };

  pyproject = true;
  pythonImportsCheck = [ "docker" ];

  meta = {
    description = "API client for docker written in Python";
    homepage = "https://github.com/docker/docker-py";
    changelog = "https://github.com/docker/docker-py/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
