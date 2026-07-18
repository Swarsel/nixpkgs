{
  lib,
  buildPythonPackage,
  cmake,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "kuzu";
  version = "0.11.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-576jyjDEu0Ynku7cqn8hJcgAskO7SocuHu3BaRfBlno=";
  };

  nativeBuildInputs = [
    setuptools-scm
    cmake
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "kuzu" ];

  meta = {
    description = "Python bindings for Kuzu, an embeddable property graph database management system";
    homepage = "https://kuzudb.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sdht0 ];
  };
}
