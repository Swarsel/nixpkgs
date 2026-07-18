{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wttrbar";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "bjesus";
    repo = "wttrbar";
    tag = finalAttrs.version;
    hash = "sha256-Fr9Zlzssw69YUdiQA1AcqQdHVg1cZghuoVB1EgS1vak=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-oumahPzbX8EjuQt1ke7yc1KAGayjsRcucsSm9uT6gOs=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple but detailed weather indicator for Waybar using wttr.in";
    homepage = "https://github.com/bjesus/wttrbar";
    changelog = "https://github.com/bjesus/wttrbar/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ khaneliman ];
    mainProgram = "wttrbar";
  };
})
