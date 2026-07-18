{
  lib,
  fetchFromGitHub,
  ctags,
  makeWrapper,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ptags";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "dalance";
    repo = "ptags";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bxp38zWufqS6PZqhw8X5HR5zMRcwH58MuZaJmDRuiys=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-zzbGyfuzJXB/Rf/cm4JTVfjx2rWz1iTnELokie6qBrw=";

  # Sanity check.
  checkPhase = ''
    $releaseDir/ptags --help > /dev/null
  '';

  postInstall = ''
    # `ctags` must be accessible in `PATH` for `ptags` to work.
    wrapProgram "$out/bin/ptags" \
      --prefix PATH : "${lib.makeBinPath [ ctags ]}"
  '';

  meta = {
    description = "Parallel universal-ctags wrapper for git repository";
    homepage = "https://github.com/dalance/ptags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pamplemousse ];
    mainProgram = "ptags";
  };
})
