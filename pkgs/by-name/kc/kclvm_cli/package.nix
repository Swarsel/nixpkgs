{
  lib,
  fetchFromGitHub,
  kclvm,
  rustPlatform,
  rustc,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kclvm_cli";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wRmLXR1r/FtZVfc6jifEj0jS0U0HIgJzBtuuzLQchjo=";
  };

  buildInputs = [
    kclvm
    rustc
  ];

  cargoHash = "sha256-ZhrjxHqwWwcVkCVkJJnVm2CZLfRlrI2383ejgI+B2KQ=";
  cargoPatches = [ ./cargo_lock.patch ];
  sourceRoot = "${finalAttrs.src.name}/cli";

  meta = {
    description = "High-performance implementation of KCL written in Rust that uses LLVM as the compiler backend";
    homepage = "https://github.com/kcl-lang/kcl";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      selfuryon
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "kclvm_cli";
  };
})
