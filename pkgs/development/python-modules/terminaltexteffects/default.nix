{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "terminaltexteffects";
  version = "0.14.2";

  # no tests on pypi, no tags on github
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ITyJnOS492Q9LQVorxROEnThHkST259bBDh70XwhdxQ=";
  };

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "terminaltexteffects" ];

  meta = {
    description = "Collection of visual effects that can be applied to terminal piped stdin text";
    homepage = "https://chrisbuilds.github.io/terminaltexteffects";
    changelog = "https://chrisbuilds.github.io/terminaltexteffects/changeblog/changeblog/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "tte";
  };
}
