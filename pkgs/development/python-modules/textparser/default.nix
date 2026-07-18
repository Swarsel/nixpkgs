{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "textparser";
  version = "0.24.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VvcI51qp0AKtt22CO6bvFm1+zsHj5MpMHKED+BdWgzU=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "textparser" ];

  meta = {
    description = "Text parser";
    homepage = "https://github.com/eerimoq/textparser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gray-heron ];
  };
}
