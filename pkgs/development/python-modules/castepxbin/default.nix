{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  numpy,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "castepxbin";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "zhubonan";
    repo = "castepxbin";
    tag = "v${version}";
    hash = "sha256-M+OoKr9ODIp47gt64hf47A1PblyZpBzulKI7nEm8hdo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;

  meta = {
    description = "Collection of readers for CASTEP binary outputs";
    homepage = "https://github.com/zhubonan/castepxbin";
    changelog = "https://github.com/zhubonan/castepxbin/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
