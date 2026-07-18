{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  netbox-napalm-plugin,
  pydriller,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-config-backup";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "DanSheps";
    repo = "netbox-config-backup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PT7/RCpB7SAinQ8McQV59b9ouqqUSoEqEj0ultL37cs=";
  };

  nativeCheckInputs = [ netbox ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    netbox-napalm-plugin
    pydriller
  ];

  dontUsePythonImportsCheck = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_config_backup" ];
  pythonRemoveDeps = [ "uuid" ]; # python builtin

  meta = {
    description = "NetBox plugin for configuration backups using napalm";
    homepage = "https://github.com/DanSheps/netbox-config-backup";
    changelog = "https://github.com/DanSheps/netbox-config-backup/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
