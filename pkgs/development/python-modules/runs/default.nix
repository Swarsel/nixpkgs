{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  tdir,
  xmod,
}:

buildPythonPackage rec {
  pname = "runs";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "rec";
    repo = "runs";
    rev = "v${version}";
    hash = "sha256-aEamhXr3C+jYDzQGzcmGFyl5oEtovxlNacFM08y0ZEk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    tdir
  ];

  build-system = [ poetry-core ];
  dependencies = [ xmod ];

  disabledTests = [
    # requires .git directory
    "test_many"
  ];

  pyproject = true;
  pythonImportsCheck = [ "runs" ];

  meta = {
    description = "Run a block of text as a subprocess";
    homepage = "https://github.com/rec/runs";
    changelog = "https://github.com/rec/runs/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
