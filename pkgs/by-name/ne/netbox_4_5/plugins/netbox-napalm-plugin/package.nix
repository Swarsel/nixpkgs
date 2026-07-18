{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  napalm,
  netbox,
  python,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "netbox-napalm-plugin";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-napalm-plugin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PdX69SS0SAeUuN2zwcv54Ooih1hyR9a19e7sc5tJvuQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'napalm<5.0' 'napalm'
  '';

  nativeCheckInputs = [
    netbox
    django
  ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ napalm ];
  disabled = python.pythonVersion != netbox.python.pythonVersion;
  pyproject = true;
  pythonImportsCheck = [ "netbox_napalm_plugin" ];

  meta = {
    description = "Netbox plugin for Napalm integration";
    homepage = "https://github.com/netbox-community/netbox-napalm-plugin";
    changelog = "https://github.com/netbox-community/netbox-napalm-plugin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
