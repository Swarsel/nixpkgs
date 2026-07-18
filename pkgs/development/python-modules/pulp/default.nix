{
  lib,
  fetchFromGitHub,
  amply,
  buildPythonPackage,
  cbc,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pulp";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "pulp";
    tag = version;
    hash = "sha256-b9qTJqSC8G3jxcqS4mkQ1gOLLab+YzYaNClRwD6I/hk=";
  };

  patches = [ ./cbc_path_fixes.patch ];

  postPatch = ''
    substituteInPlace pulp/apis/coin_api.py --subst-var-by "cbc" "${lib.getExe' cbc "cbc"}"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    amply
    pyparsing
  ];

  pyproject = true;
  pythonImportsCheck = [ "pulp" ];

  meta = {
    description = "Module to generate MPS or LP files";
    homepage = "https://github.com/coin-or/pulp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teto ];
    mainProgram = "pulptest";
  };
}
