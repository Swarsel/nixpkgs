{
  lib,
  fetchurl,
  callPackage,
  fetchzip,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) isDarwin system;

  sources = import ./sources.nix { inherit fetchurl fetchzip; };
in
callPackage (if isDarwin then ./darwin.nix else ./linux.nix) {
  inherit (sources.${system} or (throw "Unsupported system: ${system}")) version src;
  pname = "fastmail-desktop";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Dedicated desktop app for Fastmail";
    homepage = "https://www.fastmail.com/blog/desktop-app/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = [
      lib.maintainers.nekowinston
    ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
