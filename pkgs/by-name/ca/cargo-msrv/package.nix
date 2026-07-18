{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustup,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-msrv";
  version = "0.19.3";

  src = fetchFromGitHub {
    owner = "foresterre";
    repo = "cargo-msrv";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-qt1Mlj4/DSh8V/SkgorLJFRdLwbtXyOvrISU1vmXzyg=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];
  cargoHash = "sha256-cqTSLpmS/9BgtuVXlqBrxpFCPPs+wFhqOalOVhPD5r8=";
  # Integration tests fail
  doCheck = false;

  # Depends at run-time on having rustup in PATH
  postInstall = ''
    wrapProgram $out/bin/cargo-msrv --prefix PATH : ${lib.makeBinPath [ rustup ]};
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v([0-9.]+)$" ];
  };

  meta = {
    description = "Cargo subcommand \"msrv\": assists with finding your minimum supported Rust version (MSRV)";
    homepage = "https://github.com/foresterre/cargo-msrv";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      otavio
      matthiasbeyer
      chrjabs
    ];

    mainProgram = "cargo-msrv";
  };
})
