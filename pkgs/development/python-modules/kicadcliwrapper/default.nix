{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  kicad,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "kicadcliwrapper";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "atopile";
    repo = "kicadcliwrapper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s1j0k6SvZiIHu8PKGTR+GaYUZIlFq5TKYuxoCsvsvUY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    kicad
  ];

  # this script is used to generate the bindings
  # and is intended for development.
  preCheck = ''
    rm src/kicadcliwrapper/main.py
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [ typing-extensions ];
  pyproject = true;

  pythonImportsCheck = [
    "kicadcliwrapper"
    "kicadcliwrapper.lib"
  ];

  pythonRemoveDeps = [ "black" ];

  meta = {
    description = "Strongly typed, auto-generated bindings for KiCAD's CLI";
    homepage = "https://github.com/atopile/kicadcliwrapper";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
