{
  lib,
  R,
  copyDesktopItems,
  fetchPypi,
  makeDesktopItem,
  python3Packages,
  qt6,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyspread";
  version = "2.4.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7Nurn9OmK6LEz5TT543JUYKc/LjpkwfN/7r0ebS1PfY=";
    pname = "pyspread";
  };

  strictDeps = true;

  nativeBuildInputs = [
    R
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ qt6.qtsvg ];
  doCheck = true;

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pyqt6
    numpy
    markdown2

    # Optional
    matplotlib # data visualization
    pyenchant # spellchecker bindings
    pip # python package installer
    python-dateutil # extensions to standard datetime module
    rpy2 # interface to R
    plotnine # data visualization
    openpyxl # r/w Excel 2010 xlsx/xlsm files

    # Optional & not in nixpkgs
    #py-moneyed # currency & money classes
    #pycel # compile Excel spreadsheets to Python code
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "Development"
        "Spreadsheet"
      ];

      comment = "Python-oriented spreadsheet application";
      desktopName = "Pyspread";
      exec = "pyspread";
      genericName = "Spreadsheet";
      icon = "pyspread";
      name = "pyspread";
    })
  ];

  makeWrapperArgs = [ "--set R_HOME ${lib.getLib R}/lib/R" ];
  pyproject = true;
  pythonImportsCheck = [ "pyspread" ];

  meta = {
    description = "Python-oriented spreadsheet application";

    longDescription = ''
      pyspread is a non-traditional spreadsheet application that is based on and
      written in the programming language Python. The goal of pyspread is to be
      the most pythonic spreadsheet.

      pyspread expects Python expressions in its grid cells, which makes a
      spreadsheet specific language obsolete. Each cell returns a Python object
      that can be accessed from other cells. These objects can represent
      anything including lists or matrices.
    '';

    homepage = "https://pyspread.gitlab.io/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ Merikei ];
    platforms = lib.platforms.linux;
    mainProgram = "pyspread";
  };
})
