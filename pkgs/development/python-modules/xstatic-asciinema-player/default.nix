{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-asciinema-player";
  version = "2.6.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-yA6WC067St82Dm6StaCKdWrRBhmNemswetIO8iodfcw=";
    pname = "XStatic-asciinema-player";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.asciinema_player" ];

  meta = {
    description = "Asciinema-player packaged for python";
    homepage = "https://github.com/xstatic-py/xstatic-asciinema-player";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aither64 ];
  };
})
