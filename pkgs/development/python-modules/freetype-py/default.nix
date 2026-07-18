{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  freetype,
  pytestCheckHook,
  replaceVars,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "freetype-py";
  version = "2.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-z+JoahdNDdPXGp2O6b9qLCP1hyOFz4zp8kr4PQduL70=";
    extension = "zip";
  };

  patches = [
    (replaceVars ./library-paths.patch {
      freetype = "${freetype.out}/lib/libfreetype${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ freetype ];
  pyproject = true;
  pythonImportsCheck = [ "freetype" ];

  meta = {
    description = "FreeType (high-level Python API)";
    homepage = "https://github.com/rougier/freetype-py";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ goertzenator ];
  };
}
