{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cattrs,
  fonttools,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  ufo2ft,
  ufolib2,
}:

buildPythonPackage rec {
  pname = "statmake";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "daltonmaag";
    repo = "statmake";
    tag = "v${version}";
    hash = "sha256-PlMbJuJUkUjKXhkcCfLO5G3R1z9Zwf9qKYj9olOANno=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    ufo2ft
    ufolib2
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    attrs
    cattrs
    fonttools
  ]
  ++ fonttools.optional-dependencies.ufo;

  disabledTests = [
    # Test requires an update as later cattrs is present in Nixpkgs
    # https://github.com/daltonmaag/statmake/issues/42
    "test_load_stylespace_broken_range"
  ];

  pyproject = true;
  pythonImportsCheck = [ "statmake" ];

  meta = {
    description = "Applies STAT information from a Stylespace to a variable font";
    homepage = "https://github.com/daltonmaag/statmake";
    changelog = "https://github.com/daltonmaag/statmake/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "statmake";
  };
}
