{
  lib,
  fetchFromGitHub,
  ipset,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "trojan-rs";
  version = "0.16.0-unstable-2024-11-21";

  src = fetchFromGitHub {
    owner = "lazytiger";
    repo = "trojan-rs";
    rev = "a996b83e3d57b571fa59f01034fcdd32a09ee8bc";
    hash = "sha256-rtYvsFxxhkUuR/tLrRFvRBLG8C84Qs0kYmXkNP/Ai3c=";
  };

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  buildInputs = [ ipset ];
  cargoHash = "sha256-1HrIjkv/CyHCiC3RzQ2M8kHl74eMsWNfypr8PsL6kA0=";

  env = {
    RUSTC_BOOTSTRAP = true;
    RUSTFLAGS = "--cfg tokio_unstable";
  };

  meta = {
    description = "Trojan server and proxy programs written in Rust";
    homepage = "https://github.com/lazytiger/trojan-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    mainProgram = "trojan";
  };
}
