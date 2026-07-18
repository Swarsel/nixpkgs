{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  netaddr,
  # tests
  netbox,
  numpy,
  psycopg,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-interface-synchronization";
  version = "4.5.8";

  src = fetchFromGitHub {
    owner = "NetTech2001";
    repo = "netbox-interface-synchronization";
    tag = finalAttrs.version;
    hash = "sha256-DZ1xOfHop/rASWbBzVILVqvll94tQM7tRiSXwOo/QQI=";
  };

  # netbox is required for the pythonImportsCheck; plugin does not provide unit tests
  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    django
    netaddr
    requests
    numpy
    psycopg # not specified in pyproject.toml, but required at import time
  ];

  pyproject = true;
  pythonImportsCheck = [ "netbox_interface_synchronization" ];

  meta = {
    description = "Netbox plugin to compare and synchronize interfaces between devices and device types";
    homepage = "https://github.com/NetTech2001/netbox-interface-synchronization";
    changelog = "https://github.com/NetTech2001/netbox-interface-synchronization/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
