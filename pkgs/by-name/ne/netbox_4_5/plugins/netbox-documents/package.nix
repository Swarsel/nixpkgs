{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  drf-extra-fields,
  netbox,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-documents";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "jasonyates";
    repo = "netbox-documents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6t7r/98UILL73JT1TwUBAqygQOtOWj1s1bY7IbRcUKQ=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ drf-extra-fields ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_documents" ];

  meta = {
    description = "Plugin designed to faciliate the storage of site, circuit, device type and device specific documents within NetBox";
    homepage = "https://github.com/jasonyates/netbox-documents";
    changelog = "https://github.com/jasonyates/netbox-documents/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
