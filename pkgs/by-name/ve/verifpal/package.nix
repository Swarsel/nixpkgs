{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "verifpal";
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "symbolicsoft";
    repo = "verifpal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o59Pn5B1GW8fzSsUzaJaK1S/CWaYLLVpqIcQ0L5P1KA=";
  };

  cargoHash = "sha256-BvaCEqxdY16oHb2jHsqu6mL4ZNtIhY4S+OnrqQ80Yhc=";

  meta = {
    description = "Cryptographic protocol analysis for students and engineers";
    homepage = "https://verifpal.com/";
    license = with lib.licenses; [ gpl3 ];
    maintainers = with lib.maintainers; [ zimbatm ];
    mainProgram = "verifpal";
  };
})
