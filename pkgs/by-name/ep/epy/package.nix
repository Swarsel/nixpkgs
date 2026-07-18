{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "epy";
  version = "2023.6.11";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-gel503e8DXjrMJK9lpAZ6GxQsrahKX+SjiyRwKbiJUY=";
    pname = "epy_reader";
  };

  nativeBuildInputs = [ python3Packages.poetry-core ];
  dependencies = [ python3Packages.standard-imghdr ];
  pyproject = true;

  pythonImportsCheck = [
    "epy_reader.cli"
    "epy_reader.reader"
  ];

  meta = {
    description = "CLI Ebook Reader";
    homepage = "https://github.com/wustho/epy";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ perstark ];
    mainProgram = "epy";
  };
})
