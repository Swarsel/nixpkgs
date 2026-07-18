{
  lib,
  fetchFromGitHub,
  ansicolors,
  attrs,
  buildPythonPackage,
  exceptiongroup,
  fetchpatch,
  fetchpatch2,
  grpcio,
  grpcio-reflection,
  grpcio-tools,
  jinja2,
  mock,
  nix-update-script,
  openssh,
  pexpect,
  psutil,
  py-netgear-plus,
  pyserial,
  pytest,
  pytest-benchmark,
  pytest-dependency,
  pytest-mock,
  pytestCheckHook,
  pyudev,
  pyusb,
  pyyaml,
  requests,
  setuptools,
  setuptools-scm,
  util-linux,
  xmodem,
}:

buildPythonPackage (finalAttrs: {
  pname = "labgrid";
  version = "26.0";

  src = fetchFromGitHub {
    owner = "labgrid-project";
    repo = "labgrid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SX7FIaSl2sy1hMPEmgGCQQAzXUeFZRw/CrXf/ZHRBDU=";
  };

  nativeCheckInputs = [
    mock
    openssh
    psutil
    pytestCheckHook
    pytest-benchmark
    pytest-mock
    pytest-dependency
    util-linux
    py-netgear-plus
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    ansicolors
    attrs
    exceptiongroup
    jinja2
    grpcio
    grpcio-tools
    grpcio-reflection
    pexpect
    pyserial
    pyudev
    pyusb
    pyyaml
    pytest
    requests
    xmodem
  ];

  disabledTests = [
    # flaky, timing sensitive
    "test_timing"

    # flaky, depends on ssh connection
    "test_argument_device_expansion"
    "test_argument_file_expansion"
    "test_local_managedfile"

    # flaky: teardown race on x86_64-linux
    "test_remoteplace_target"

    # netns tests require working SSH & Agentwrapper
    "test_tcp"
    "test_udp"
    "test_getaddrinfo"
    "test_closed_socket"
    "test_dup"
    "test_detach"
    "test_socks"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "labgrid" ];
  pythonRemoveDeps = [ "pyserial-labgrid" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Embedded control & testing library";
    homepage = "https://github.com/labgrid-project/labgrid";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux;
  };
})
