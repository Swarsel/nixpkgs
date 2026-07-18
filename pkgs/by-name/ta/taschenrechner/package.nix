{
  lib,
  fetchFromGitLab,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "taschenrechner";
  version = "2.0.1";

  src = fetchFromGitLab {
    owner = "mabl";
    repo = "taschenrechner";
    rev = finalAttrs.version;
    hash = "sha256-lUQmgC3GcLJ2BxE+UOHPBfl8XMclgMrk+rClZI06giE=";
    domain = "gitlab.fem-net.de";
  };

  cargoHash = "sha256-1DNEsVwrGekCuQTgBNAe+j/4JKk0EFgkSklTXAjwFXU=";

  meta = {
    description = "Cli-calculator written in Rust";
    homepage = "https://gitlab.fem-net.de/mabl/taschenrechner";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ netali ];
    mainProgram = "taschenrechner";
  };
})
