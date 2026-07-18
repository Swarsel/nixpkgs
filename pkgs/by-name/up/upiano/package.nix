{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "upiano";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "eliasdorneles";
    repo = "upiano";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5WhflvUCjzW4ZJ+PLUTMbKcUnQa3ChkDjl0R5YvjBWk=";
    fetchLFS = true;
    forceFetchGit = true;
  };

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyfluidsynth
    textual
  ];

  pyproject = true;

  pythonImportsCheck = [
    "upiano"
  ];

  pythonRelaxDeps = [
    "textual"
  ];

  meta = {
    description = "Piano in your terminal";
    homepage = "https://github.com/eliasdorneles/upiano";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "upiano";
  };
})
