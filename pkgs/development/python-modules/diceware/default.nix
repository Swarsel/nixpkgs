{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "diceware";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VLaQgJ8MVqswhaGOFaDDgE1KDRJ/OK7wtc9fhZ0PZjk=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-yXGotV/tq7/vCYhY+1OZgCW3r6/SXTTvsHIU/jywbHc=";

      hunks = [
        2
        3
      ];

      includes = [ "diceware/__init__.py" ];
      # Set prog in ArgumentParser explicitly to fix test failure with Python 3.14
      # https://github.com/ulif/diceware/issues/122
      url = "https://github.com/ulif/diceware/commit/77d98606748df7755f36ebbb3bd838b1cdd80c61.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ setuptools ];

  disabledTestMarks = [
    # see https://github.com/ulif/diceware/commit/a7d844df76cd4b95a717f21ef5aa6167477b6733
    "packaging"
  ];

  pyproject = true;
  pythonImportsCheck = [ "diceware" ];

  meta = {
    description = "Generates passphrases by concatenating words randomly picked from wordlists";
    homepage = "https://github.com/ulif/diceware";
    changelog = "https://github.com/ulif/diceware/blob/v${version}/CHANGES.rst";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ asymmetric ];
    mainProgram = "diceware";
  };
}
