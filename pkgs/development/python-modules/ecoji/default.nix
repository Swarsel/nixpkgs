{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ecoji";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lmWyVF1z6gtODJiXzGV134rn3DlGqCrJ1i2y8UcTmpw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ecoji" ];

  meta = {
    description = "Encode and decode data as emojis";
    homepage = "https://pypi.org/project/ecoji/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
