{
  lib,
  buildPythonPackage,
  chameleon,
  fetchPypi,
  fetchpatch,
  pyramid,
  pytestCheckHook,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "pyramid-chameleon";
  version = "0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0XZ5KlDrAV14ZbRL2bJKe9BIn6mlzrvRe54FBIzvkBc=";
    pname = "pyramid_chameleon";
  };

  patches = [
    # https://github.com/Pylons/pyramid_chameleon/pull/25
    ./test-renderers-pyramid-import.patch
    # Compatibility with pyramid 2, https://github.com/Pylons/pyramid_chameleon/pull/34
    (fetchpatch {
      hash = "sha256-cPS7JhcS8nkBS1T0OdZke25jvWHT0qkPFjyPUDKHBGU=";
      name = "support-later-limiter.patch";
      url = "https://github.com/Pylons/pyramid_chameleon/commit/36348bf4c01f52c3461e7ba4d20b1edfc54dba50.patch";
    })
  ];

  propagatedBuildInputs = [
    chameleon
    pyramid
    setuptools
    zope-interface
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "pyramid_chameleon" ];

  meta = {
    description = "Chameleon template compiler for pyramid";
    homepage = "https://github.com/Pylons/pyramid_chameleon";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
