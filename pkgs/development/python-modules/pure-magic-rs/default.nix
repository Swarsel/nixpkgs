{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "pure-magic-rs";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "qjerome";
    repo = "magic-rs";
    tag = "pure-magic-v${finalAttrs.version}";
    hash = "sha256-cvCAiZSyB+9tNydfco9YGU5NA6Ja/SCsVeYJvuKitGo=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  buildAndTestSubdir = "python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-wysI/3fxHJ+W6q36hFm7D0Jtimq5+tyLAb1KYUYQ6/U=";
  };

  pyproject = true;
  pythonImportsCheck = [ "pure_magic_rs" ];

  meta = {
    description = "Safe Rust implementation of libmagic";
    homepage = "https://github.com/qjerome/magic-rs";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pure-magic-rs";
  };
})
