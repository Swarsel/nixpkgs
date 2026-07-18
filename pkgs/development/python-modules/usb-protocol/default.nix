{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  construct,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "usb-protocol";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "python-usb-protocol";
    tag = version;
    hash = "sha256-lLepd2ja/UBSOARHXVwuCxLCIp0vTpUQBMdR2ovfhq8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [ construct ];
  pyproject = true;

  pythonImportsCheck = [
    "usb_protocol"
  ];

  meta = {
    description = "Python library providing utilities, data structures, constants, parsers, and tools for working with the USB protocol";
    homepage = "https://github.com/greatscottgadgets/python-usb-protocol";
    changelog = "https://github.com/greatscottgadgets/python-usb-protocol/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
