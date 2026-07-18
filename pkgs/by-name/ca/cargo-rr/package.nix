{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  rr,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-rr";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dzfranklin";
    repo = "cargo-rr";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-t8pRqeOdaRVG0titQhxezT2aDjljSs//MnRTTsJ73Yo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-s3KZFntAb/q4oreJLDQ2Pnz+Oj8Ik36vYR2InY0BIBw=";

  postInstall = ''
    wrapProgram $out/bin/cargo-rr --prefix PATH : ${lib.makeBinPath [ rr ]}
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cargo subcommand \"rr\": a light wrapper around rr, the time-travelling debugger";
    homepage = "https://github.com/dzfranklin/cargo-rr";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      otavio
      matthiasbeyer
    ];

    mainProgram = "cargo-rr";
  };
})
