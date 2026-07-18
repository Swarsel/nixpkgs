{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  terminaltexteffects,
}:

buildPythonPackage rec {
  pname = "textualeffects";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5C84ZdvcgVgxroFZycOdHdB4my3qK8b4wVxD4kd+XfE=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ terminaltexteffects ];
  pyproject = true;
  pythonImportsCheck = [ "textualeffects" ];

  meta = {
    description = "Visual effects for Textual, a TerminalTextEffects wrapper";
    homepage = "https://github.com/ggozad/textualeffects";
    changelog = "https://github.com/ggozad/textualeffects/blob/v${version}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gaelj ];
  };
}
