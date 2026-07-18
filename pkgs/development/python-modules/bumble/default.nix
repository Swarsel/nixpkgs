{
  lib,
  fetchFromGitHub,
  aiohttp,
  appdirs,
  buildPythonPackage,
  click,
  cryptography,
  grpcio,
  humanize,
  libusb-package,
  libusb1,
  platformdirs,
  prettytable,
  prompt-toolkit,
  protobuf,
  pyee,
  pyserial,
  pyserial-asyncio,
  pytest-asyncio,
  pytestCheckHook,
  pyusb,
  setuptools,
  setuptools-scm,
  tomli,
  websockets,
}:

buildPythonPackage rec {
  pname = "bumble";
  version = "0.0.232";

  src = fetchFromGitHub {
    owner = "google";
    repo = "bumble";
    tag = "v${version}";
    hash = "sha256-NT8WNfkYHorjNfsZWry63Uuxk7zyOQDOHTqxZxJNypI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    appdirs
    click
    cryptography
    grpcio
    humanize
    libusb-package
    libusb1
    platformdirs
    prettytable
    prompt-toolkit
    protobuf
    pyee
    pyserial
    pyserial-asyncio
    pyusb
    tomli
    websockets
  ];

  disabledTests = [
    # tests require networking
    "test_android_netsim_connection"
    "test_open_transport_with_metadata"
  ];

  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "bumble" ];

  pythonRelaxDeps = [
    "libusb-package"
    "tomli"
  ];

  meta = {
    description = "Bluetooth Stack for Apps, Emulation, Test and Experimentation";
    homepage = "https://github.com/google/bumble";
    changelog = "https://github.com/google/bumble/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
