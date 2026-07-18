{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rinf_cli";
  version = "8.10.0";

  src = fetchFromGitHub {
    owner = "cunarist";
    repo = "rinf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ivfair5NC8RtxhOsHXlzR/AN28bZoEJDLg/9/2eSBIU=";
  };

  cargoHash = "sha256-0vhayxwQoeMuvvYImFsBiOQEqxub/hIipQrqpRaGXq0=";
  sourceRoot = "${finalAttrs.src.name}/rust_crate_cli";

  meta = {
    description = "Framework for creating cross-platform Rust apps leveraging Flutter";
    homepage = "https://rinf.cunarist.com";
    changelog = "https://github.com/cunarist/rinf/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Noah765 ];
    mainProgram = "rinf";
  };
})
