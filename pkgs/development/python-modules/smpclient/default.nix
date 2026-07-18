{
  lib,
  fetchFromGitHub,
  async-timeout,
  bleak,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  intelhex,
  pyserial,
  pytest-asyncio,
  pytestCheckHook,
  smp,
}:

buildPythonPackage rec {
  pname = "smpclient";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "intercreate";
    repo = "smpclient";
    tag = version;
    hash = "sha256-5o2z+cyOVpTNpOdc9GfFNmqcOhbGgbFM0qGng44E1xE=";
  };

  env.HATCH_BUILD_HOOK_VCS_VERSION = version;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ optional-dependencies.all;

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    async-timeout
    intelhex
    smp
  ];

  optional-dependencies = {
    all = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "all" ]);
    ble = [ bleak ];
    serial = [ pyserial ];
    udp = [ ];
  };

  pyproject = true;
  pythonImportsCheck = [ "smpclient" ];

  meta = {
    description = "Simple Management Protocol (SMP) Client for remotely managing MCU firmware";
    homepage = "https://github.com/intercreate/smpclient";
    changelog = "https://github.com/intercreate/smpclient/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
  };
}
