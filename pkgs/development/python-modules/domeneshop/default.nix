{
  lib,
  buildPythonPackage,
  certifi,
  fetchPypi,
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "domeneshop";
  version = "0.4.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UCxIDnhIAkxZ1oQXYRyAMdGgUsUZ6AlYXwsxL49TFAg=";
  };

  nativeBuildInputs = [ setuptools ];
  # There are none
  doCheck = false;

  dependencies = [
    certifi
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "domeneshop" ];

  meta = {
    description = "Python library for working with the Domeneshop API";
    homepage = "https://api.domeneshop.no/docs/";
    changelog = "https://github.com/domeneshop/python-domeneshop/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
