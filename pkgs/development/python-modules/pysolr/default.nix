{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pysolr";
  version = "3.11.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-u9DnRng1MWiA+ZS1U4bJvDwUZzPBfYWj/tMXdVl2xAo=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ requests ];
  doCheck = false; # requires network access
  nativeCheckInputs = [ mock ];
  format = "setuptools";

  meta = {
    description = "Lightweight Python wrapper for Apache Solr";
    homepage = "https://github.com/toastdriven/pysolr/";
    license = lib.licenses.bsd3;
  };
}
