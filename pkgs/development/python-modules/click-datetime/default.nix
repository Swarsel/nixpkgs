{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "click-datetime";
  version = "0.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nzXtP6sT9VMiHOjFqJXlGF1zYJk8Ud1/hii5tPY2kws=";
    pname = "click_datetime";
  };

  # no tests
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "click_datetime" ];
  pythonRemoveDeps = [ "wheel" ];

  meta = {
    description = "Datetime type support for click";
    homepage = "https://github.com/click-contrib/click-datetime";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
