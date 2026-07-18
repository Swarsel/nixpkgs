{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-reorder-rack";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-reorder-rack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lWC+Br66POJe3M8L+Pt5D1pWBr9qSpRLn2TcVMXKje4=";
  };

  checkInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_reorder_rack" ];

  meta = {
    description = "NetBox plugin to allow users to reorder devices within a rack using a drag and drop UI";
    homepage = "https://github.com/netbox-community/netbox-reorder-rack";
    changelog = "https://github.com/netbox-community/netbox-reorder-rack/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ minijackson ];
  };
})
