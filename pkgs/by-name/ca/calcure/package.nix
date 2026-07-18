{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "calcure";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "anufrievroman";
    repo = "calcure";
    tag = finalAttrs.version;
    hash = "sha256-YFX70gtNcIXG5XIuMlz47nmtjt/2oHzi6cajcj+DAyQ=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    holidays
    icalendar
    jdatetime
    taskw
  ];

  pyproject = true;

  pythonImportsCheck = [
    "calcure"
  ];

  meta = {
    description = "Modern TUI calendar and task manager with minimal and customizable UI";
    homepage = "https://github.com/anufrievroman/calcure";
    changelog = "https://github.com/anufrievroman/calcure/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "calcure";
  };
})
