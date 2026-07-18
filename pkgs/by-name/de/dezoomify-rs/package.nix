{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dezoomify-rs";
  version = "2.16.0";

  src = fetchFromGitHub {
    owner = "lovasoa";
    repo = "dezoomify-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-45Vlgle605s3uvPh+Lr+KAk72AzIoolnSuhFzRCORC4=";
  };

  nativeBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    pkg-config
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    openssl
  ];

  cargoHash = "sha256-tfeknHPrY11rSmHyEAUvJgCLDwmIpo9jk8BLgzgQCrc=";

  nativeCheckInputs = [
    cacert
  ];

  __structuredAttrs = true;

  # hyper uses SystemConfiguration.framework to read system proxy settings.
  # Allow access to the Mach service to prevent the tests from failing.
  sandboxProfile = ''
    (allow mach-lookup (global-name "com.apple.SystemConfiguration.configd"))
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Zoomable image downloader for Google Arts & Culture, Zoomify, IIIF, and others";
    homepage = "https://github.com/lovasoa/dezoomify-rs/";
    changelog = "https://github.com/lovasoa/dezoomify-rs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fsagbuya
      kybe236
    ];

    mainProgram = "dezoomify-rs";
  };
})
