{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "mixins";
  version = "0.1.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SmYYRzo6wClQBMc2oRgO0CQEHOxWe8GFL24TPa6A4NQ=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "mixins" ];

  meta = {
    description = "Mixin classes which may be added to your own classes to add certain functionality to them";
    homepage = "https://github.com/nickderobertis/py-mixins";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aanderse ];
  };
}
