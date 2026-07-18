{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "tg-archive";
  version = "1.3.1";

in
python3.pkgs.buildPythonApplication {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "knadh";
    repo = "tg-archive";
    tag = "v${version}";
    hash = "sha256-GAy3dKkrrLO9IlRBUYaKxm4AswQK4cYUKIjezcBok/k=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    setuptools
    telethon
    jinja2
    pyyaml
    cryptg
    pillow
    feedgen
    python-magic
    pytz
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tgarchive"
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "Tool for exporting Telegram group chats into static websites like mailing list archives";
    homepage = "https://github.com/knadh/tg-archive";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ euxane ];
    mainProgram = "tg-archive";
  };
}
