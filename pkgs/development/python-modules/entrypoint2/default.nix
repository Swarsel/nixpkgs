{
  lib,
  buildPythonPackage,
  easyprocess,
  fetchPypi,
  path,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "entrypoint2";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/At/57IazatHpYWrlAfKflxPlstoiFddtrDOuR8OEFo=";
  };

  nativeCheckInputs = [
    easyprocess
    path
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "entrypoint2" ];

  meta = {
    description = "Easy to use command-line interface for python modules";
    homepage = "https://github.com/ponty/entrypoint2/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ austinbutler ];
  };
}
