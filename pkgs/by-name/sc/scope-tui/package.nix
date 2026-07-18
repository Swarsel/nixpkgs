{
  lib,
  fetchFromGitHub,
  alsa-lib,
  libpulseaudio,
  pkg-config,
  rustPlatform,
  withPulseaudio ? true,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "scope-tui";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "alemidev";
    repo = "scope-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-etiJmbLuzrKZXhi/BsEhipvmzEilJAfgfv7t9oYrltw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ] ++ lib.optionals withPulseaudio [ libpulseaudio ];
  cargoHash = "sha256-yAy3kk62HYe1/1EXGUhOg++sZua65iN3ZEmPoERcu0I=";
  doCheck = false; # no tests
  buildFeatures = lib.optionals withPulseaudio [ "pulseaudio" ];

  meta = {
    description = "Simple oscilloscope/vectorscope/spectroscope for your terminal";
    homepage = "https://github.com/alemidev/scope-tui";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      iynaix
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "scope-tui";
  };
})
