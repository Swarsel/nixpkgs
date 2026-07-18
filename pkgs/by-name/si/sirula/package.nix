{
  lib,
  fetchFromGitHub,
  gtk-layer-shell,
  gtk3,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sirula";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "DorianRudolph";
    repo = "sirula";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rBaH2cIIaRoaw8Os60s4MknZywzDuGLagJiAvEYU4m8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk3
    gtk-layer-shell
  ];

  cargoHash = "sha256-7trHMGTWtf4IT7efyKIXM7n4x6j7n2V3I7ZXSSwvzys=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple app launcher for wayland written in rust";
    homepage = "https://github.com/DorianRudolph/sirula";
    license = [ lib.licenses.gpl3Plus ];
    maintainers = [ lib.maintainers.atagen ];
    platforms = lib.platforms.linux;
  };
})
