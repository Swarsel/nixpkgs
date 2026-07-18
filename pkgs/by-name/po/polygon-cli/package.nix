{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "polygon-cli";
  version = "1.1.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gEz3kcXbXj9dXnMCx0Q8TjCQemXvJne9EwFsPt14xV4=";
  };

  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    requests
    prettytable
    colorama
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "polygon_cli" ];

  meta = {
    description = "Command-line tool for polygon.codeforces.com";
    homepage = "https://github.com/kunyavskiy/polygon-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaser ];
    mainProgram = "polygon-cli";
  };
}
