{
  lib,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  fetchpatch,
  libopus,
  nix-update-script,
  pkg-config,
  rustPlatform,
  soxr,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bark";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "haileys";
    repo = "bark";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JaUIWGCYhasM0DgqL+DiG2rE1OWVg/N66my/4RWDN1E=";
  };

  # Broken rustdoc comment
  patches = [
    (fetchpatch {
      hash = "sha256-cA1bqc7XhJ2cxOYvjIJ9oopzBZ9I4rGERkiwDAUh3V4";
      url = "https://patch-diff.githubusercontent.com/raw/haileys/bark/pull/13.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libopus
    soxr
  ];

  cargoHash = "sha256-LcmX8LbK8UHDDeqwLTFEUuRBv9GgDiCpXP4bmIR3gME=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Live sync audio streaming for local networks";
    homepage = "https://github.com/haileys/bark";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ samw ];
    platforms = lib.platforms.linux;
    mainProgram = "bark";
  };
})
