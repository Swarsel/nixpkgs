{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  flow-record,
  hatch-vcs,
  hatchling,
  httpx,
  lark,
  pycryptodome,
  pyshark,
  pytest-httpserver,
  pytestCheckHook,
  rich,
}:

buildPythonPackage rec {
  pname = "dissect-cobaltstrike";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.cobaltstrike";
    tag = "v${version}";
    hash = "sha256-0Wi0H9jL7suF/d92Sg2LuE6M2EzbIWsEC7Jjd1eJGTw=";
  };

  nativeCheckInputs = [
    pytest-httpserver
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
    lark
  ];

  disabledTests = [
    # Don't run tests with a beacon
    "test_c2profile_beacon_gate"
    "test_beacon_dump_guardrails"
  ];

  optional-dependencies = {
    c2 = [
      flow-record
      httpx
      pycryptodome
    ];

    full = [
      flow-record
      httpx
      pycryptodome
      pyshark
      rich
    ];

    pcap = [
      flow-record
      httpx
      pycryptodome
      pyshark
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dissect.cobaltstrike" ];

  meta = {
    description = "Dissect module implementing a parser for Cobalt Strike related data";
    homepage = "https://github.com/fox-it/dissect.cobaltstrike";
    changelog = "https://github.com/fox-it/dissect.cobaltstrike/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
