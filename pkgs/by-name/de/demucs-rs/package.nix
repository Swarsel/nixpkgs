{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
  vulkan-loader,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "demucs-rs";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "nikhilunni";
    repo = "demucs-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IidfPS+/T8aJoW30gdnKhhsgluMt+h9RllAXH9Yrq1g=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-xngHyenlB3sMqzJHNk9utk4TNhdt+awutDuP1JzhhBA=";

  # wgpu dlopen()s libvulkan at runtime, so LD_LIBRARY_PATH is needed (RPATH has no effect).
  # this is Linux-only: on Darwin wgpu uses Metal and should need no runtime patching.
  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/demucs \
      --prefix LD_LIBRARY_PATH : "${vulkan-loader}/lib"
  '';

  # Only build the CLI crate, not the DAW plugin or WASM targets
  buildAndTestSubdir = "demucs-cli";

  meta = {
    description = "Native Rust implementation of HTDemucs v4 music source separation CLI";

    longDescription = ''
      A native Rust implementation of HTDemucs v4 — state-of-the-art music
      source separation. Splits any song into individual stems (drums, bass,
      vocals, etc.) using GPU-accelerated inference via Burn.

      Model weights are downloaded automatically from Hugging Face on first
      use and cached for future runs.
    '';

    homepage = "https://github.com/nikhilunni/demucs-rs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eymeric ];
    platforms = lib.platforms.unix;
    mainProgram = "demucs";
  };
})
