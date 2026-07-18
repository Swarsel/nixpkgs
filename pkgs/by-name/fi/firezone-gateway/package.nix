{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "firezone-gateway";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    tag = "gateway-${finalAttrs.version}";
    hash = "sha256-bfLPOhxv0xfnU3Q1zZWbhqvNe9Hav2RgF/ESMk81F4I=";
  };

  # Required to remove profiling arguments which conflict with this builder
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-oOJ/UkamQrlWjAz2A4oObdBssHH9iJWN2BHFgMPOxck=";
  env.RUSTFLAGS = "--cfg system_certs";
  buildAndTestSubdir = "gateway";
  sourceRoot = "${finalAttrs.src.name}/rust";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "gateway-(.*)"
    ];
  };

  meta = {
    description = "WireGuard tunnel server for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];

    platforms = lib.platforms.linux;
    mainProgram = "firezone-gateway";
  };
})
