{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustlens";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "yashksaini-coder";
    repo = "Rustlens";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BYROEUBa9RZXuJbNbKUbWXu9mPYIuAyO6JwPlNmj244=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-WvUu2M2WFLo5Ve+ER7vpl7q/cpPR4g1vY4z9hRl3On0=";
  __structuredAttrs = true;

  meta = {
    description = "Rustlens is a terminal-based application for exploring Rust codebases.";
    homepage = "https://github.com/yashksaini-coder/Rustlens";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gwg313 ];
    mainProgram = "rustlens";
  };
})
