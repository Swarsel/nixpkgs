{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dataproperty,
  mbstrdecoder,
  pathvalidate,
  pytestCheckHook,
  setuptools,
  sqliteschema,
  tabledata,
  typepy,
}:

buildPythonPackage rec {
  pname = "SimpleSQLite";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "thombashi";
    repo = "SimpleSQLite";
    tag = "v${version}";
    hash = "sha256-PObyZmmECxp6keRymYFGi4Uf07yNHu6rUIqSrRx2bPE=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    dataproperty
    mbstrdecoder
    pathvalidate
    sqliteschema
    tabledata
    typepy
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "simplesqlite" ];

  meta = {
    description = "Python library to simplify SQLite database operations";
    homepage = "https://github.com/thombashi/simplesqlite";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ henrirosten ];
  };
}
