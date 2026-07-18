{
  lib,
  stdenv,
  callPackage,
  ...
}@args:

let
  extraArgs = removeAttrs args [ "callPackage" ];

  pname = "spotify";

  updateScript = ./update.sh;

  meta = {
    description = "Play music from the Spotify music service";
    homepage = "https://www.spotify.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "spotify";
  };

in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix (extraArgs // { inherit pname updateScript meta; })
else
  callPackage ./linux.nix (extraArgs // { inherit pname updateScript meta; })
