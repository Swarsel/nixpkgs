{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "rfc-bibtex";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "iluxonchik";
    repo = "rfc-bibtex";
    tag = finalAttrs.version;
    hash = "sha256-bPCNQqiG50vWVFA6J2kyxftwsXunHTNBdSkoIRYkb0s=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    vcrpy
  ];

  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "rfc_bibtex"
  ];

  meta = {
    description = "Generate Bibtex entries for IETF RFCs and Internet-Drafts";
    homepage = "https://github.com/iluxonchik/rfc-bibtex/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teto ];
    mainProgram = "rfcbibtex";
  };
})
