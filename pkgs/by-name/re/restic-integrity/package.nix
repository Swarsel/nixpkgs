{
  lib,
  fetchFromGitea,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "restic-integrity";
  version = "1.4.0";

  src = fetchFromGitea {
    owner = "networkException";
    repo = "restic-integrity";
    tag = finalAttrs.version;
    hash = "sha256-Nii+rdz51+Acd+lZVpBispeFfVE8buxEGHvK2zMKbOM=";
    domain = "git.nwex.de";
  };

  cargoHash = "sha256-Hnr003TbG0y/Ry4yOAs6t6rhc5yEJkc+TDAuxGePb0Y=";

  meta = {
    description = "CLI tool to check the integrity of a restic repository without unlocking it";
    homepage = "https://git.nwex.de/networkException/restic-integrity";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ networkexception ];
    mainProgram = "restic-integrity";
  };
})
