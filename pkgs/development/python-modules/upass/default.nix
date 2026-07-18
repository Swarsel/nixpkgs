{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyperclip,
  setuptools,
  urwid,
}:

buildPythonPackage rec {
  pname = "upass";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Kwpolska";
    repo = "upass";
    rev = "v${version}";
    hash = "sha256-IlNqPmDaRZ3yRV8O6YKjQkZ3fKNcFgzJHtIX0ADrOyU=";
  };

  # Project thas no tests
  doCheck = false;

  postInstall = ''
    export HOME=$(mktemp -d);
    mkdir $HOME/.config
  '';

  build-system = [ setuptools ];

  dependencies = [
    pyperclip
    urwid
  ];

  pyproject = true;
  pythonImportsCheck = [ "upass" ];

  meta = {
    description = "Console UI for pass";
    homepage = "https://github.com/Kwpolska/upass";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "upass";
  };
}
