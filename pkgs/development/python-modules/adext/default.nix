{
  lib,
  fetchFromGitHub,
  alarmdecoder,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "adext";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "ajschmidt8";
    repo = "adext";
    tag = "v${version}";
    hash = "sha256-cZMA8/t24xk5b1At2LQWeDWuRfPcXBCXpl2T70YxZeA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dependencies = [ alarmdecoder ];
  pyproject = true;
  pythonImportsCheck = [ "adext" ];

  meta = {
    description = "Python extension for AlarmDecoder";
    homepage = "https://github.com/ajschmidt8/adext";
    changelog = "https://github.com/ajschmidt8/adext/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
