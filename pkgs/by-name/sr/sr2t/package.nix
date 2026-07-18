{
  lib,
  fetchFromGitLab,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "sr2t";
  version = "0.0.26";

  src = fetchFromGitLab {
    owner = "0bs1d1an";
    repo = "sr2t";
    tag = finalAttrs.version;
    hash = "sha256-BPsYnKBTxt5WUd2+WumMdVi8p6iryOWG2MjI97qbaCw=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    prettytable
    pyyaml
    setuptools
    xlsxwriter
  ];

  pyproject = true;
  pythonImportsCheck = [ "sr2t" ];

  meta = {
    description = "Tool to convert scanning reports to a tabular format";
    homepage = "https://gitlab.com/0bs1d1an/sr2t";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "sr2t";
  };
})
