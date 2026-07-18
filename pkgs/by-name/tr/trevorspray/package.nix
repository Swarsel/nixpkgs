{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "trevorspray";
  version = "2.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-t6F86JzKLS6f+TN9iMUjqZJkS+ccNRsYa99Mdl2BYwQ=";
  };

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    exchangelib
    mechanicalsoup
    pygments
    pysocks
    sh
    tldextract
    trevorproxy
  ];

  pyproject = true;

  meta = {
    description = "Modular password spraying tool";
    homepage = "https://github.com/blacklanternsecurity/TREVORspray";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "trevorspray";
  };
})
