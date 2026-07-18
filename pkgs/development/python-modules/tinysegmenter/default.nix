{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "tinysegmenter";
  version = "0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZEWL26VLp0gsAseF+WDPPWz2FZSk2rPWTDJUOQlPwbc=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "tinysegmenter" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Very compact Japanese tokenizer";
    homepage = "https://tinysegmenter.tuxfamily.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
