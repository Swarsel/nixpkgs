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
  pname = "netbox-attachments";
  version = "11.2.1";

  src = fetchFromGitHub {
    owner = "Kani999";
    repo = "netbox-attachments";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vljF55gYykxHnitYoag9G8PzAxjRe4YpPmu8gGMNMd8=";
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
  pythonImportsCheck = [ "netbox_attachments" ];

  meta = {
    description = "Plugin to manage attachments for any model";
    homepage = "https://github.com/Kani999/netbox-attachments";
    changelog = "https://github.com/Kani999/netbox-attachments/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
