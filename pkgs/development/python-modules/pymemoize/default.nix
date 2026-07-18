{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pymemoize";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    sha256 = "0yqr60hm700zph6nv8wb6yp2s0i08mahxvw98bvkmw5ijbsviiq7";
    pname = "PyMemoize";
  };

  # django.core.exceptions.ImproperlyConfigured: Requested settings, but settings are not configured. You must either define the environment variable DJANGO_SETTINGS_MODULE or call settings.configure() before accessing settings
  doCheck = false;
  nativeCheckInputs = [ django ];
  format = "setuptools";

  meta = {
    description = "Simple Python cache and memoizing module";
    homepage = "https://github.com/mikeboers/PyMemoize";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
