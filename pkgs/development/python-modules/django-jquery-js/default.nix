{
  lib,
  buildPythonPackage,
  django,
  fetchFromBitbucket,
}:

buildPythonPackage rec {
  pname = "django-jquery-js";
  version = "3.1.1";

  src = fetchFromBitbucket {
    owner = "tim_heap";
    repo = "django-jquery";
    tag = "v${version}";
    hash = "sha256-TzMo31jFhcvlrmq2TJgQyds9n8eATaChnyhnQ7bwdzs=";
  };

  buildInputs = [ django ];
  doCheck = false; # no tests
  format = "setuptools";
  pythonImportsCheck = [ "jquery" ];

  meta = {
    description = "jQuery, bundled up so apps can depend upon it";
    homepage = "https://bitbucket.org/tim_heap/django-jquery";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
