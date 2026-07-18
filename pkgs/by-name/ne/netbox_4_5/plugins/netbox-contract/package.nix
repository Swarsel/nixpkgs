{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  drf-yasg,
  netaddr,
  netbox,
  python,
  python-dateutil,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "netbox-contract";
  version = "2.4.6";

  src = fetchFromGitHub {
    owner = "mlebreuil";
    repo = "netbox-contract";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e8DYjU2UtlWu044e4b5eJWOA/fXDRKLl5AVtaepG0sg=";
  };

  # running tests requires initialized django project
  nativeCheckInputs = [
    netbox
    netaddr
  ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    drf-yasg
  ];

  disabled = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_contract" ];

  meta = {
    description = "Contract plugin for netbox";
    homepage = "https://github.com/mlebreuil/netbox-contract";
    changelog = "https://github.com/mlebreuil/netbox-contract/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
