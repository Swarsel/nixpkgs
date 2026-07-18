{
  lib,
  fetchFromGitHub,
  exabgp,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "exabgp";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "Exa-Networks";
    repo = "exabgp";
    tag = finalAttrs.version;
    hash = "sha256-UFo92jS/QmwTUEAhxQnbtY9K905jiBrJujfqGIUCUOg=";
  };

  postPatch = ''
    # https://github.com/Exa-Networks/exabgp/pull/1344
    substituteInPlace src/exabgp/application/healthcheck.py --replace-fail \
      "f'/sbin/ip -o address show dev {ifname}'.split()" \
      '["ip", "-o", "address", "show", "dev", ifname]'
  '';

  nativeCheckInputs = with python3Packages; [
    hypothesis
    psutil
    pytest-asyncio
    pytest-benchmark
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = with python3Packages; [
    setuptools
  ];

  disabledTests = [
    # AssertionError: Server should receive connection
    "test_outgoing_connection_establishment"
  ];

  enabledTests = [ "tests" ];
  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];

  pythonImportsCheck = [
    "exabgp"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "exabgp version";
      package = exabgp;
    };
  };

  meta = {
    description = "BGP swiss army knife of networking";
    homepage = "https://github.com/Exa-Networks/exabgp";
    changelog = "https://github.com/Exa-Networks/exabgp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      hexa
      raitobezarius
    ];

    mainProgram = "exabgp";
  };
})
