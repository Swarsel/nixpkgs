{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "frogmouth";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "frogmouth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0fcCON/M9JklE7X9aRfzTkEFG4ckJqLoQlYCSrWHHGQ=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    httpx
    textual
    typing-extensions
    xdg
  ];

  pyproject = true;
  pythonImportsCheck = [ "frogmouth" ];

  pythonRelaxDeps = [
    "httpx"
    "textual"
  ];

  meta = {
    description = "Markdown browser for your terminal";
    homepage = "https://github.com/Textualize/frogmouth";
    changelog = "https://github.com/Textualize/frogmouth/blob/${finalAttrs.src.rev}/ChangeLog.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "frogmouth";
  };
})
