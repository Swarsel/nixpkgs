{
  lib,
  fetchFromGitHub,
  alsa-lib,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwalarmctl";
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

  preBuild = ''
    cargo check
  '';

  buildAndTestSubdir = "pwalarmctl";

  meta = {
    description = "Controller for pwalarmd";

    longDescription = ''
      pwalarmctl is a command-line controller for pwalarmd which allows
      for live configuration changes and access to the active state
      of pwalarmd.
    '';

    homepage = "https://github.com/amyipdev/pwalarmd";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ amyipdev ];
    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "pwalarmctl";
  };
})
