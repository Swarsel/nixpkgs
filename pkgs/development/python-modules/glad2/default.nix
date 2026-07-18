{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  setuptools,
}:

buildPythonPackage rec {
  pname = "glad2";
  version = "2.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uEB5ufpATzcXG5Yb3R2NohNw5sgY3vuEgcWz/j1kNto=";
  };

  # no python tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ jinja2 ];
  pyproject = true;
  pythonImportsCheck = [ "glad" ];

  meta = {
    description = "Multi-Language GL/GLES/EGL/GLX/WGL Loader-Generator based on the official specifications";
    homepage = "https://github.com/Dav1dde/glad";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "glad";
  };
}
