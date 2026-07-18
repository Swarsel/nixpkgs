{
  lib,
  fetchFromGitHub,
  clippy,
  rustPlatform,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fuc";
  version = "3.1.7";

  src = fetchFromGitHub {
    owner = "SUPERCILEX";
    repo = "fuc";
    tag = finalAttrs.version;
    hash = "sha256-LtS2+iqu4+z6K/PZeggLdo4S/F+5AtV5j9Q6hDAcEiQ=";
  };

  cargoHash = "sha256-SSJg/Ns64+NgqrB4mJ5/xa40tZfGZ2VGdvNP7SSKv0E=";
  env.RUSTC_BOOTSTRAP = 1;
  # error[E0602]: unknown lint: `clippy::unnecessary_debug_formatting`
  doCheck = false;

  nativeCheckInputs = [
    clippy
    rustfmt
  ];

  cargoBuildFlags = [
    "--workspace"
    "--bin cpz"
    "--bin rmz"
  ];

  meta = {
    description = "Modern, performance focused unix commands";
    homepage = "https://github.com/SUPERCILEX/fuc";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
