{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  jinja2,
  sphinxcontrib-serializinghtml,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-websupport";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-C3Nn07rGRUsfl+QqqMTU1KG3VtUl/HJuu+VXHgM+ec0=";
    pname = "sphinxcontrib_websupport";
  };

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    jinja2
    sphinxcontrib-serializinghtml
  ];

  doCheck = false;
  # circular dependency on sphinx
  dontCheckRuntimeDeps = true;
  pyproject = true;
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx API for Web Apps";
    homepage = "http://sphinx-doc.org/";
    license = lib.licenses.bsd2;
  };
}
