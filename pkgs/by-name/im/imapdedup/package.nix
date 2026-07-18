{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "imapdedup";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "quentinsf";
    repo = "IMAPdedup";
    tag = finalAttrs.version;
    hash = "sha256-CmWkLz9hdmedUxcojmUVTkPjqpaMmtEeHnF7aglKR+s=";
  };

  doCheck = false; # no tests
  build-system = with python3Packages; [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "imapdedup" ];

  meta = {
    description = "Duplicate email message remover";
    homepage = "https://github.com/quentinsf/IMAPdedup";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "imapdedup";
  };
})
