{
  lib,
  fetchurl,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "yokadi";
  version = "1.3.0";

  src = fetchurl {
    url = "https://yokadi.github.io/download/${pname}-${version}.tar.gz";
    hash = "sha256-zF2ffHeU+i7wzu1u4DhQ5zJXr8AjXboiyFAisXNX6TM=";
  };

  # Yokadi doesn't have any tests
  doCheck = false;

  dependencies = with python3Packages; [
    python-dateutil
    sqlalchemy
    setproctitle
    icalendar
    colorama
  ];

  format = "setuptools";

  meta = {
    description = "Command line oriented, sqlite powered, todo-list";
    homepage = "https://yokadi.github.io/index.html";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.nkpvk ];
    mainProgram = "yokadi";
  };
}
