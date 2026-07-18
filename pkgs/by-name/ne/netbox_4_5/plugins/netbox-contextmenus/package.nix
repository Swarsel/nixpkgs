{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netbox,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "netbox-contextmenus";
  version = "1.4.14";

  src = fetchFromGitHub {
    owner = "PieterL75";
    repo = "netbox_contextmenus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YqyxZaHKXhMLDdBTAAKQsCBBSXikxBgcOvXEfa6f+0Y=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;

  # pythonImportsCheck fails due to improperly configured django app
  meta = {
    description = "Netbox plugin to add context buttons to the links, making navigating less clicky";
    homepage = "https://github.com/PieterL75/netbox_contextmenus/";
    changelog = "https://github.com/PieterL75/netbox_contextmenus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
  };
})
