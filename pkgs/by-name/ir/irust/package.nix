{
  lib,
  fetchFromGitHub,
  cargo,
  cargo-expand,
  cargo-show-asm,
  clang,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  rustfmt,
  # Workaround to allow easily overriding runtime inputs
  runtimeInputs ? [
    cargo
    rustfmt
    cargo-show-asm
    cargo-expand
    clang
  ],
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "irust";
  version = "1.76.2";

  src = fetchFromGitHub {
    owner = "sigmaSd";
    repo = "IRust";
    rev = "irust@${finalAttrs.version}";
    hash = "sha256-bZKFoN6hr/TLTvGAWUXS+S3RnYhdirUeGz30LYbgA7g=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-lcnKiJCFN/bN/4R6VIhut2Xz3ueYPgXkr4dsYH57d9g=";

  checkFlags = [
    "--skip=repl"
    "--skip=printer::tests"
  ];

  postFixup = ''
    wrapProgram $out/bin/irust \
      --suffix PATH : ${lib.makeBinPath runtimeInputs}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross Platform Rust Repl";
    homepage = "https://github.com/sigmaSd/IRust";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "irust";
  };
})
