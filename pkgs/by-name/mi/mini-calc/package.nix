{
  lib,
  fetchFromGitHub,
  gnuplot,
  makeWrapper,
  mini-calc,
  rustPlatform,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mini-calc";
  version = "4.0.4";

  src = fetchFromGitHub {
    owner = "vanilla-extracts";
    repo = "calc";
    tag = finalAttrs.version;
    hash = "sha256-GvWWFTJfgPn26BXVl4MV65pubpIg1y544oHvycTcrGo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-tPrACzeUaBK/981ReGWwwfuhBki8Bfebmp7xCLPzXDo=";

  postFixup = ''
    wrapProgram $out/bin/mini-calc \
      --prefix PATH : "${lib.makeBinPath [ gnuplot ]}"
  '';

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    # `mini-calc -v` does not output in the test env, fallback to pipe
    command = "echo -v | mini-calc";
    package = mini-calc;
  };

  meta = {
    description = "Fully-featured minimalistic configurable calculator written in Rust";
    homepage = "https://calc.charlotte-thomas.me/";
    changelog = "https://github.com/vanilla-extracts/calc/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.unix;
    mainProgram = "mini-calc";
  };
})
