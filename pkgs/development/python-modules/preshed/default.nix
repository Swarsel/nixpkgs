{
  lib,
  buildPythonPackage,
  cymem,
  cython,
  fetchPypi,
  murmurhash,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "preshed";
  version = "3.0.13";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-119xi7/ZfpkveCfg+n+vapG92cki1bqktQ1icxOWy4k=";
  };

  nativeBuildInputs = [ cython ];

  propagatedBuildInputs = [
    cymem
    murmurhash
  ];

  # Tests have import issues with 3.0.8
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "preshed" ];
  # don't update to 4.0.0, version was yanked
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Cython hash tables that assume keys are pre-hashed";
    homepage = "https://github.com/explosion/preshed";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
