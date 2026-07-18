{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  roboto,
}:

buildGoModule (finalAttrs: {
  pname = "deckmaster";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "muesli";
    repo = "deckmaster";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1hZ7yAKTvkk20ho+QOqFEtspBvFztAtfmITs2uxhdmQ=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = "sha256-DFssAic2YtXNH1Jm6zCDv1yPNz3YUXaFLs7j7rNHhlE=";

  # Let the app find Roboto-*.ttf files (hard-coded file names).
  postFixup = ''
    wrapProgram $out/bin/deckmaster \
      --prefix XDG_DATA_DIRS : "${roboto.out}/share/"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;

  meta = {
    description = "Application to control your Elgato Stream Deck on Linux";
    homepage = "https://github.com/muesli/deckmaster";
    changelog = "https://github.com/muesli/deckmaster/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "deckmaster";
  };
})
