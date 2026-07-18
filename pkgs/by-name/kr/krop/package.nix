{
  lib,
  fetchFromGitHub,
  ghostscript,
  libsForQt5,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "krop";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "arminstraub";
    repo = "krop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8mhTUP0oS+AnZXVmywxBTbR1OOg18U0RQ1H9lyjaiVI=";
  };

  nativeBuildInputs = [ libsForQt5.wrapQtAppsHook ];

  buildInputs = [
    libsForQt5.poppler
    libsForQt5.qtwayland
  ];

  # Disable checks because of interference with older Qt versions // xcb
  doCheck = false;

  dependencies = with python3Packages; [
    pyqt5
    pypdf2
    poppler-qt5
    ghostscript
  ];

  format = "setuptools";
  makeWrapperArgs = [ "\${qtWrapperArgs[@]}" ];

  meta = {
    description = "Graphical tool to crop the pages of PDF files";

    longDescription = ''
      Krop is a tool that allows you to optimise your PDF files, and remove
      sections of the page you do not want.  A unique feature of krop, at least to my
      knowledge, is its ability to automatically split pages into subpages to fit the
      limited screensize of devices such as eReaders. This is particularly useful, if
      your eReader does not support convenient scrolling. Krop also has a command line
      interface.
    '';

    homepage = "http://arminstraub.com/software/krop";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "krop";
  };
})
