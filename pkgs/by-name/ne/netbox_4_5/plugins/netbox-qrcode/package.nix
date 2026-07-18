{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeCheckInputs
  django,
  netaddr,
  netbox,
  nix-update-script,
  # dependencies
  pillow,
  psycopg2,
  qrcode,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-qrcode";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox-qrcode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A4qjpbfTULzS0UchUN9eX8jZmwoX/ej/18L/YAB8dKA=";
  };

  nativeCheckInputs = [
    django
    netaddr
    netbox
    psycopg2 # not specified in pyproject.toml, but required at import time
  ];

  preFixup = ''
    export PYTHONPATH=${netbox}/opt/netbox/netbox:$PYTHONPATH
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    qrcode
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "netbox_qrcode" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    description = "Netbox plugin for generate QR codes for objects: Rack, Device, Cable";
    homepage = "https://github.com/netbox-community/netbox-qrcode";
    changelog = "https://github.com/netbox-community/netbox-qrcode/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
