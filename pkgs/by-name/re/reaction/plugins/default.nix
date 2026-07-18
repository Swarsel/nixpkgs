{
  lib,
  callPackage,
  reaction,
  rustPlatform,
}:
{
  # NOTE: plugins are binaries, so no special integration with the derivation is required
  # mkReactionPlugin is meant for only official plugins living in the reaction source tree
  mkReactionPlugin =
    name: extra:
    rustPlatform.buildRustPackage (
      {
        inherit (reaction)
          version
          src
          patches
          cargoHash
          ;

        pname = name;
        buildAndTestSubdir = "plugins/${name}";

        meta = {
          description = "Official reaction plugin ${name}";
          homepage = "https://framagit.org/ppom/reaction";
          changelog = "https://framagit.org/ppom/reaction/-/releases/v${reaction.version}";
          license = lib.licenses.agpl3Plus;
          maintainers = with lib.maintainers; [ ppom ];
          platforms = lib.platforms.unix;
          mainProgram = name;
          teams = [ lib.teams.ngi ];
        };
      }
      // extra
    );

  # capture all plugins except default.nix (this file)
  plugins = lib.removeAttrs (lib.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ./.;
  }) [ "default" ];
}
