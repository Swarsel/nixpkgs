{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mloader";
  version = "1.1.12";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-0o4FvhuFudNSEL6fwBVqxldaNePbbidY9utDqXiLRNc=";
  };

  # No tests in repository
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    click
    protobuf
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mloader" ];
  pythonRelaxDeps = [ "protobuf" ];

  meta = {
    description = "Command-line tool to download manga from mangaplus";
    homepage = "https://github.com/hurlenko/mloader";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "mloader";
  };
})
