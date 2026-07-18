{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "fileinfo";
  version = "0-unstable-2022-09-16";

  src = fetchFromGitHub {
    owner = "sdushantha";
    repo = "fileinfo";
    rev = "503f26189ad5043bad3fe71333dd5ba3ffbce485";
    hash = "sha256-tEmCsR3LmTxeDZAbMvbIwqp/6uaGNUhgGlm18gdsnOw=";
  };

  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ requests ];
  pyproject = true;

  meta = {
    description = "File extension metadata lookup tool";
    homepage = "https://github.com/sdushantha/fileinfo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ h7x4 ];
    mainProgram = "fileinfo";
  };
}
