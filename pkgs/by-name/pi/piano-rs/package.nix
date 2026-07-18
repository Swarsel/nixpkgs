{
  lib,
  fetchFromGitHub,
  alsa-lib,
  makeBinaryWrapper,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "piano-rs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "ritiek";
    repo = "piano-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qZeH9xXQPIOJ87mvLahnJB3DuEgLX0EAXPvECgxNlq0=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    alsa-lib
  ];

  cargoHash = "sha256-ygRyYFLNBCLnRhmO6DoK8fwvy/Y9jrOjWChzxc3CRPo=";

  postInstall = ''
    mkdir -p "$out"/share/piano-rs
    cp -r assets "$out"/share/piano-rs
    wrapProgram "$out"/bin/piano-rs \
      --set ASSETS "$out"/share/piano-rs/assets
  '';

  meta = {
    description = "Multiplayer piano using UDP sockets that can be played using computer keyboard, in the terminal";
    homepage = "https://github.com/ritiek/piano-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ritiek ];
    platforms = lib.platforms.unix;
    mainProgram = "piano-rs";
  };
})
