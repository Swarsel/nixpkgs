{
  lib,
  fetchFromGitHub,
  cmake,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  pkg-config,
  protobuf,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clash-rs";
  version = "0.10.7";

  src = fetchFromGitHub {
    owner = "Watfaq";
    repo = "clash-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tY/GB6J8kr6Ni9ScOpKkDYLaLffvtaIxH8tXK24LHt8=";
  };

  patches = [
    # Remove the `npm ci` call in build.rs as it fails.
    ./skip-npm-ci.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
    nodejs
    npmHooks.npmConfigHook
  ];

  cargoHash = "sha256-SlkqNu6Vk1D9aU4GgyNDW9Or3z8KSbEjwCUK9w3Jyx0=";

  env = {
    # requires nightly features: sync_unsafe_cell, unbounded_shifts, let_chains, ip
    RUSTC_BOOTSTRAP = 1;
    # if_let_guard is stable since Rust 1.95.0, but some deps still carry
    # the stale #![feature(if_let_guard)] attribute.
    RUSTFLAGS = "-A stable-features";
  };

  doCheck = false; # test failed

  postInstall = ''
    # Align with upstream
    ln -s "$out/bin/clash-rs" "$out/bin/clash"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    protobuf
    versionCheckHook
  ];

  buildFeatures = [ "plus" ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-H8G3GuEh4JXZV1zxTfo89tl6D6WA5hWGOF9i8qP0njw=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    sourceRoot = "${finalAttrs.src.name}/clash-dashboard";
  };

  npmRoot = "clash-dashboard";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Custom protocol, rule based network proxy software";
    homepage = "https://github.com/Watfaq/clash-rs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "clash";
  };
})
