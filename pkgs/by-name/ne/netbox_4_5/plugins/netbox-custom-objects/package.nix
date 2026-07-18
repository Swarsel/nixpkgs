{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-custom-objects";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "netboxlabs";
    repo = "netbox-custom-objects";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HnA2CJL0EOJctQpsu/G+9fULBIa8rrrYNiT0aaDw/rI=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_custom_objects" ];

  meta = {
    description = "NetBox plugin to create new object types";
    homepage = "https://github.com/netboxlabs/netbox-custom-objects";
    changelog = "https://github.com/netboxlabs/netbox-custom-objects/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.netboxLimitedUse;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
