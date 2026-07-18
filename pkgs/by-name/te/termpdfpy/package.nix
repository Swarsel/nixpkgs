{
  lib,
  fetchFromGitHub,
  bibtool,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "termpdf.py";
  version = "2022-03-28";

  src = fetchFromGitHub {
    owner = "dsanson";
    repo = "termpdf.py";
    rev = "e7bd0824cb7d340b8dba7d862e696dba9cb5e5e2";
    sha256 = "HLQZBaDoZFVBs4JfJcwhrLx8pxdEI56/iTpUjT5pBhk=";
  };

  propagatedBuildInputs = [
    bibtool
  ]
  ++ (with python3Packages; [
    pybtex
    pymupdf
    pyperclip
    roman
    pagelabels
    pdfrw
    pynvim
    setuptools
  ]);

  # upstream doesn't contain tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = ''
      A graphical pdf (and epub, cbz, ...) reader that works
      inside the kitty terminal.
    '';

    homepage = "https://github.com/dsanson/termpdf.py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teto ];
    mainProgram = "termpdf.py";
  };
}
