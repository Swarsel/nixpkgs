{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "chatblade";
  version = "0.7.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-v6X5aqArhp33bm8JELDCUoxE3nsvla4I3n0ZLLMMeJI=";
  };

  doCheck = false; # there are no tests

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    openai
    platformdirs
    pylatexenc
    pyyaml
    rich
    tiktoken
  ];

  pyproject = true;
  pythonImportsCheck = [ "chatblade" ];
  pythonRelaxDeps = true;

  meta = {
    description = "CLI Swiss Army Knife for ChatGPT";
    homepage = "https://github.com/npiv/chatblade/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ deejayem ];
    mainProgram = "chatblade";
  };
})
