{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "typst";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "messense";
    repo = "typst-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9wHUikOf/WULPaGkCOXa0aXcSme+xbweC6IDwaJnwRk=";
  };

  buildInputs = [ openssl ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    cargo
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-TyLKnJUVbodCHQXhpjIr1numNDmeUkvpsKH1o5tWFCM=";
  };

  pyproject = true;
  pythonImportsCheck = [ "typst" ];

  meta = {
    description = "Python binding to typst";
    homepage = "https://github.com/messense/typst-py";
    changelog = "https://github.com/messense/typst-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
