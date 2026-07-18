{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django-polymorphic,
  netbox,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-security";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "andy-shady-org";
    repo = "netbox-security";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DGiuQignYPSTFFm0RkDl5kwYQJNKbRdgdmIZ1DKXkGs=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_security" ];

  meta = {
    description = "NetBox plugin covering various security and NAT related models";
    homepage = "https://github.com/andy-shady-org/netbox-security";
    changelog = "https://github.com/andy-shady-org/netbox-security/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
