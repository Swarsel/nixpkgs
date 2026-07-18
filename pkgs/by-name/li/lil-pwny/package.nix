{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "lil-pwny";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "PaperMtn";
    repo = "lil-pwny";
    tag = finalAttrs.version;
    hash = "sha256-EE6+PQTmvAv5EvxI9QR/dQcPby13BBk66KSc7XDNAZA=";
  };

  # Project has no test
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "lil_pwny"
  ];

  meta = {
    description = "Offline auditing of Active Directory passwords";
    homepage = "https://github.com/PaperMtn/lil-pwny";
    changelog = "https://github.com/PaperMtn/lil-pwny/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "lil-pwny";
  };
})
