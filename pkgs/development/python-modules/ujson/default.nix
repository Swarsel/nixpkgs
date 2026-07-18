{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ujson";
  version = "5.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4gSub5CfCZumtrlCExzuNZ3dorbk6jnBLri5kf4gEOA=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "ujson" ];

  meta = {
    description = "Ultra fast JSON encoder and decoder";
    homepage = "https://github.com/ultrajson/ultrajson";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
