{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "django-tagging";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "28d68fa4831705e51ad7d1e845ed6dd9e354f9b6f8a5f63b655a430646ef4e8d";
  };

  propagatedBuildInputs = [ django ];
  # error: invalid command 'test'
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Generic tagging application for Django projects";
    homepage = "https://github.com/Fantomas42/django-tagging";

    license = lib.licenses.AND [
      lib.licenses.mit
      lib.licenses.bsd3
    ];
  };
}
