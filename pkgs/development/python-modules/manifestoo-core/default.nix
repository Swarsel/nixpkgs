{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  nix-update-script,
}:

buildPythonPackage rec {
  pname = "manifestoo-core";
  version = "1.15.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-wUx7YhLMv//nqesJbgYILViDJYHeGBpp05NqAed0Dx4=";
    pname = "manifestoo_core";
  };

  nativeBuildInputs = [ hatch-vcs ];
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library to reason about Odoo addons manifests";
    homepage = "https://github.com/acsone/manifestoo-core";
    changelog = "https://github.com/acsone/manifestoo-core/blob/v${version}/HISTORY.rst";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
