{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-bgp";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-bgp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6LZLsUPC9L9L19KeXJilJvmZYcl6YwqysGO8nFAUmcI=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_bgp" ];

  meta = {
    description = "NetBox plugin for BGP related objects documentation";
    homepage = "https://github.com/netbox-community/netbox-bgp";
    changelog = "https://github.com/netbox-community/netbox-bgp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
