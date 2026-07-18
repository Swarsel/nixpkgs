{
  lib,
  fetchFromGitHub,
  python3Packages,
  testers,
  toolong,
}:

python3Packages.buildPythonApplication {
  pname = "toolong";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "toolong";
    rev = "5aa22ee878026f46d4d265905c4e1df4d37842ae"; # no tag
    hash = "sha256-HrmU7HxWKYrbV25Y5CHLw7/7tX8Y5mTsTL1aXGGTSIo=";
  };

  # From https://github.com/Textualize/toolong/pull/63, also fixes https://github.com/NixOS/nixpkgs/issues/360671
  patches = [ ./0001-log-view.patch ];
  doCheck = false; # no tests
  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    click
    textual
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "toolong" ];
  pythonRelaxDeps = [ "textual" ];

  passthru.tests.version = testers.testVersion {
    command = "${lib.getExe toolong} --version";
    package = toolong;
  };

  meta = {
    description = "Terminal application to view, tail, merge, and search log files (plus JSONL)";
    homepage = "https://github.com/textualize/toolong";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "tl";
  };
}
