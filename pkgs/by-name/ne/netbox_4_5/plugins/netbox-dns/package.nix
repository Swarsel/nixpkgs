{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "netbox-plugin-dns";
  version = "1.5.10";

  src = fetchFromGitHub {
    owner = "peteeckel";
    repo = "netbox-plugin-dns";
    tag = finalAttrs.version;
    hash = "sha256-wxTW/qiwp+1CXUeCDJnllEW2oCTjlFVUot7JfWPooaw=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    dnspython
  ];

  pyproject = true;

  # pythonImportsCheck fails due to improperly configured django app
  meta = {
    description = "Netbox plugin for managing DNS data";
    homepage = "https://github.com/peteeckel/netbox-plugin-dns";
    changelog = "https://github.com/peteeckel/netbox-plugin-dns/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
})
