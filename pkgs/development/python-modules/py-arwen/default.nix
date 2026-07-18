{
  lib,
  arwen,
  buildPythonPackage,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  inherit (arwen)
    version
    src
    ;

  pname = "py-arwen";

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # conflicts with built module
    rm -r arwen
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-SJ3RZ/kCfMJb26uaJEQzA2NXOCudyqbJpbvC4d/R/T8=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "arwen"
  ];

  sourceRoot = "${finalAttrs.src.name}/py-arwen";

  meta = {
    inherit (arwen.meta)
      description
      homepage
      license
      platforms
      maintainers
      teams
      ;
  };
})
