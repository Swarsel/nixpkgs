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
  pname = "netbox-floorplan-plugin";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-floorplan-plugin";
    tag = finalAttrs.version;
    hash = "sha256-0EeE5NrImbCs6xqrSTGupXOuv455EfNXgcLVix2HTPs=";
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
  pythonImportsCheck = [ "netbox_floorplan" ];

  meta = {
    description = "Netbox plugin providing floorplan mapping capability for locations and sites";
    homepage = "https://github.com/netbox-community/netbox-floorplan-plugin";
    changelog = "https://github.com/netbox-community/netbox-floorplan-plugin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ cobalt ];
  };
})
