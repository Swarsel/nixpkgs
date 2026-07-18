{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  perf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-flamegraph";
  version = "0.6.13";

  src = fetchFromGitHub {
    owner = "flamegraph-rs";
    repo = "flamegraph";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-XB0/ltiiYZpOlQWoyEPyNFhHqolDgIq0waIjQwT3L88=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ makeWrapper ];
  cargoHash = "sha256-OxPvye1HjcQOazAWn7VIa+twWC7uKXeyXkicPiWVe6I=";

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/cargo-flamegraph \
      --set-default PERF ${perf}/bin/perf
    wrapProgram $out/bin/flamegraph \
      --set-default PERF ${perf}/bin/perf
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Easy flamegraphs for Rust projects and everything else, without Perl or pipes <3";
    homepage = "https://github.com/flamegraph-rs/flamegraph";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      killercup
      matthiasbeyer
    ];
  };
})
