{
  lib,
  buildPythonPackage,
  click,
  fetchFromCodeberg,
  pycountry,
  pyscard,
  pytestCheckHook,
  setuptools,
  terminaltables,
}:

buildPythonPackage (finalAttrs: {
  pname = "emv";
  version = "1.0.14";

  src = fetchFromCodeberg {
    owner = "russss";
    repo = "python-emv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MnaeQZ0rA3i0CoUA6HgJQpwk5yo4rm9e+pc5XzRd1eg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    click
    pyscard
    pycountry
    terminaltables
  ];

  pyproject = true;
  pythonImportsCheck = [ "emv" ];

  pythonRelaxDeps = [
    "click"
    "pyscard"
    "pycountry"
    "terminaltables"
  ];

  pythonRemoveDeps = [
    "enum-compat"
    "argparse"
  ];

  meta = {
    description = "Implementation of the EMV chip-and-pin smartcard protocol";
    homepage = "https://codeberg.org/russss/python-emv/";
    changelog = "https://codeberg.org/russss/python-emv/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lukegb ];
    mainProgram = "emvtool";
  };
})
