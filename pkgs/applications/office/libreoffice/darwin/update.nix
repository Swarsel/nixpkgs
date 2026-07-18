# Impure functions, for passthru.updateScript runtime only
{
  aarch64Url,
  version,
  x86_64Url,
  pkgs ? import ../../../../../default.nix { },
}:
let
  inherit (import ./update-utils.nix { inherit (pkgs) lib; })
    getLatestStableVersion
    getSha256
    ;
in
pkgs.mkShell rec {
  buildInputs = [ pkgs.common-updater-scripts ];
  newAarch64Sha256 = getSha256 aarch64Url version newVersion;
  newVersion = getLatestStableVersion;
  newX86_64Sha256 = getSha256 x86_64Url version newVersion;
}
