{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "arpeggio";
  version = "2.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-noWtNc/GyThnaBfHrpoQAKfHKjTHHbDGhxNsRg0SuF4=";
    pname = "Arpeggio";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "arpeggio" ];

  meta = {
    description = "Recursive descent parser with memoization based on PEG grammars (aka Packrat parser)";
    homepage = "https://github.com/textX/Arpeggio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
