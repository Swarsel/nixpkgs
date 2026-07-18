{
  lib,
  buildPythonPackage,
  fetchPypi,
  gcc,
  isPyPy,
  setuptools,
  wirelesstools,
}:

buildPythonPackage (finalAttrs: {
  pname = "basiciw";
  version = "0.2.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-S/vpNoJyc5evFEtrsif6BKkc1Qc9z4ory9RNujd1Vao=";
  };

  buildInputs = [ gcc ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ wirelesstools ];
  disabled = isPyPy;
  pyproject = true;
  pythonImportsCheck = [ "basiciw" ];

  meta = {
    description = "Get info about wireless interfaces using libiw";
    homepage = "https://github.com/enkore/basiciw";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
