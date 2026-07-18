{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  netaddr,
  netbox,
  python,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "netbox-topology-views";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-topology-views";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uKxIu8IPeEwBdRbtQaLWGwLnxvFyJ5FrScsU/ufyTuM=";
  };

  nativeCheckInputs = [
    netbox
    django
    netaddr
  ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  disabled = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_topology_views" ];

  meta = {
    description = "Netbox plugin for generate topology views/maps from your devices";
    homepage = "https://github.com/netbox-community/netbox-topology-views";
    changelog = "https://github.com/netbox-community/netbox-topology-views/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
