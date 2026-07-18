{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pyopenssl,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pyvmomi";
  version = "9.0.0.0";

  src = fetchFromGitHub {
    owner = "vmware";
    repo = "pyvmomi";
    tag = "v${version}";
    hash = "sha256-4r0UtLR1dhhNQ+Lx12JiEozDAjMxPly+RR0LWRg/A4E=";
  };

  # Requires old version of vcrpy
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    six
  ];

  optional-dependencies = {
    sso = [
      lxml
      pyopenssl
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "pyVim"
    "pyVmomi"
  ];

  meta = {
    description = "Python SDK for the VMware vSphere API that allows you to manage ESX, ESXi, and vCenter";
    homepage = "https://github.com/vmware/pyvmomi";
    changelog = "https://github.com/vmware/pyvmomi/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
