{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "legacy-cgi";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "jackrosenthal";
    repo = "legacy-cgi";
    tag = "v${version}";
    hash = "sha256-2CCYRRWP8FP54AcLnehJ0Kj3F3U4cz8vnesSj5EakdA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;

  pythonImportsCheck = [
    "cgi"
    "cgitb"
  ];

  meta = {
    description = "Fork of the standard library cgi and cgitb modules, being deprecated in PEP-594";
    homepage = "https://github.com/jackrosenthal/legacy-cgi";
    changelog = "https://github.com/jackrosenthal/legacy-cgi/releases/tag/${src.tag}";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
