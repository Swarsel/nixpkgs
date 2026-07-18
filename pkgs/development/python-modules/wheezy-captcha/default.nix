{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "wheezy.captcha";
  version = "3.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-UtTpgrPK5eRr7sq97jptjdJyvAyrM2oU07+GZr2Ad7s=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pillow ];
  pyproject = true;
  pythonImportsCheck = [ "wheezy.captcha" ];

  meta = {
    description = "Lightweight CAPTCHA library";
    homepage = "https://wheezycaptcha.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Flakebi ];
  };
})
