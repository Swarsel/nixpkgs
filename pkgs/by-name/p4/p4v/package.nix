{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  qt6Packages,
}:

let
  # Upstream replaces minor versions, so use archived URLs.
  srcs = {
    aarch64-darwin = fetchurl {
      sha256 = "sha256-8MBLS6EQOVenxZ1Uv75kPzU8aO2AldmxkwOz+JcBRpY=";
      url = "https://web.archive.org/web/20260414052748/https://filehost.perforce.com/perforce/r26.1/bin.macosx12u/P4V.dmg";
    };

    x86_64-linux = fetchurl {
      sha256 = "sha256-89Xz9dxAeLGOOr90K0CdlxjrfIf9vUmyZV3tzWspWdQ=";
      url = "https://web.archive.org/web/20260414052921/https://filehost.perforce.com/perforce/r26.1/bin.linux26x86_64/p4v.tgz";
    };
    # this is universal
  };

  mkDerivation =
    if stdenv.hostPlatform.isDarwin then
      callPackage ./darwin.nix { }
    else
      qt6Packages.callPackage ./linux.nix { };
in
mkDerivation {
  pname = "p4v";
  version = "2026.1/2933292";

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = {
    description = "Perforce Helix Visual Client";
    homepage = "https://www.perforce.com";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      impl
      nathyong
      nioncode
    ];

    platforms = builtins.attrNames srcs;
  };
}
