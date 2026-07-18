{
  lib,
  fetchFromCodeberg,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "turbocase";
  version = "1.8.0";

  src = fetchFromCodeberg {
    owner = "MartijnBraam";
    repo = "TurboCase";
    rev = finalAttrs.version;
    hash = "sha256-mwWN7XYKr/BD9r935oElqoQN87kdrrWjkmhURkAkjj4=";
  };

  build-system = [ python3.pkgs.setuptools ];
  dependencies = [ python3.pkgs.sexpdata ];
  pyproject = true;
  pythonImportsCheck = [ "turbocase" ];

  meta = {
    description = "Generate an OpenSCAD case template from a KiCAD PCB";
    homepage = "https://turbocase.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MayNiklas ];
    mainProgram = "turbocase";
  };
})
