{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-inventory";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "ArnesSI";
    repo = "netbox-inventory";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6MIYwz11YZhu3ksM7iAfKACKIKpuq283DTzaRR3lcXA=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_inventory" ];

  meta = {
    description = "NetBox plugin to manage hardware inventory";
    homepage = "https://github.com/ArnesSI/netbox-inventory";
    changelog = "https://github.com/ArnesSI/netbox-inventory/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
