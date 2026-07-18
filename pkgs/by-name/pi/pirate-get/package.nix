{
  lib,
  fetchPypi,
  python3Packages,
}:

with python3Packages;

buildPythonApplication (finalAttrs: {
  pname = "pirate-get";
  version = "0.4.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-VtnVyJqrdGXTqcyzpHCOMUI9G7/BkXzihDrBrsxl7Eg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = [
    colorama
    veryprettytable
    pyperclip
  ];

  pyproject = true;
  pythonImportsCheck = [ "pirate" ];

  meta = {
    description = "Command line interface for The Pirate Bay";
    homepage = "https://github.com/vikstrous/pirate-get";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.unix;
    mainProgram = "pirate-get";
  };
})
