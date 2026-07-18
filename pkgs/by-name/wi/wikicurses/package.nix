{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wikicurses";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "ids1024";
    repo = "wikicurses";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1U7RkW31IRbn0JKiJozu4q9aFhkMGGJ3ybfg0THRJDg=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  doCheck = false;

  postInstall = ''
    installManPage wikicurses.1 wikicurses.conf.5
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    urwid
    beautifulsoup4
    lxml
  ];

  pyproject = true;

  meta = {
    description = "Simple curses interface for MediaWiki sites such as Wikipedia";
    homepage = "https://github.com/ids1024/wikicurses/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
    mainProgram = "wikicurses";
  };

})
