{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ufal-chu-liu-edmonds";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v3tv6cYWoFPPgaO6KXR2uUk3MsZ458Tz5wKeFW8fzNE=";
    pname = "ufal.chu_liu_edmonds";
  };

  nativeCheckInputs = [ numpy ];

  checkPhase = ''
    runHook preCheck
    cd tests
    python test.py
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ufal.chu_liu_edmonds" ];

  meta = {
    description = "Bindings to Chu-Liu-Edmonds algorithm from TurboParser";
    homepage = "https://github.com/ufal/chu_liu_edmonds";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
