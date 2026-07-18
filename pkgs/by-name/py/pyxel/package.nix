{
  lib,
  fetchFromGitHub,
  SDL2,
  cargo,
  fetchpatch,
  python3Packages,
  rustPlatform,
  rustc,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyxel";
  version = "2.9.7";

  src = fetchFromGitHub {
    owner = "kitao";
    repo = "pyxel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k86VRX25yVNZvsnsWl0EYGd8njhx9yl6gkqI7mznjEs=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [ SDL2 ];
  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL2}/include/SDL2";

  preBuild = ''
    # logic taken from Makefile
    cp LICENSE README.md python/pyxel/
  '';

  # Tests want to use the display
  doCheck = false;
  buildAndTestSubdir = "python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      src
      pname
      version
      cargoRoot
      ;

    hash = "sha256-tpJSUdjdXwXK/n1nyMga5uTk7TAz/JLQVN0rSdbKxGk=";
  };

  cargoRoot = "crates";

  maturinBuildFlags = [
    "--features"
    "sdl2_dynamic"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyxel"
    "pyxel.pyxel_binding"
  ];

  meta = {
    description = "Retro game engine for Python";
    homepage = "https://github.com/kitao/pyxel";
    changelog = "https://github.com/kitao/pyxel/tree/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tomasajt
      miniharinn
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "pyxel";
  };
})
