{
  lib,
  fetchFromGitHub,
  alsa-lib,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwalarmd";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "amyipdev";
    repo = "pwalarmd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xoC1PtDQjkvoWb9x8A43ITo6xyYOv9hxH2pxiZBBvKI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];
  cargoHash = "sha256-wD6djP2FQgJNL9EryRrv6NrEex0bnqDJmfYw+S2x508=";

  meta = {
    description = "Background CLI-based alarm system for *nix";

    longDescription = ''
      pwalarmd is a command-line (daemon-based) alarm system.
      It has extensive configuration and personalization, PulseAudio
      and PipeWire support, and supports live configuration changes.
    '';

    homepage = "https://github.com/amyipdev/pwalarmd";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ amyipdev ];
    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "pwalarmd";
  };
})
