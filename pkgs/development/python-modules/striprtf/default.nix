{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "striprtf";
  version = "0.0.32";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fzdaN12ZonAIQhcxaMkMm1RcskQkH/xdho7Z9rr5FV8=";
  };

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "striprtf" ];

  meta = {
    description = "Simple library to convert rtf to text";
    homepage = "https://github.com/joshy/striprtf";
    changelog = "https://github.com/joshy/striprtf/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ aanderse ];
    mainProgram = "striprtf";
  };
}
