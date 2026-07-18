{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchFromCodeberg,
  hatchling,
  yarl,
}:

buildPythonPackage rec {
  pname = "eheimdigital";
  version = "1.7.0";

  src = fetchFromCodeberg {
    owner = "autinerd";
    repo = "eheimdigital";
    tag = version;
    hash = "sha256-aAV63mdgBQ1kbLGOERkUm67S4A+Fyq+0ihllTTGe1mc=";
  };

  # upstream tests are dysfunctional
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "eheimdigital" ];

  meta = {
    description = "Offers a Python API for the EHEIM Digital smart aquarium devices";
    homepage = "https://codeberg.org/autinerd/eheimdigital";
    changelog = "https://codeberg.org/autinerd/eheimdigital/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
