{
  lib,
  buildPythonPackage,
  click-odoo,
  fetchPypi,
  manifestoo-core,
  nix-update-script,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "click-odoo-contrib";
  version = "1.23.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3xw3AstUtX99lT+rPOvBGSSqjAyxt752LibBMMbXSoU=";
    pname = "click_odoo_contrib";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    click-odoo
    manifestoo-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "click_odoo_contrib" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Collection of community-maintained scripts for Odoo maintenance";
    homepage = "https://github.com/acsone/click-odoo-contrib";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
