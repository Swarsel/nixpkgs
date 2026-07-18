{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  version = "4.2.1";
  relArtifact =
    name: hash:
    fetchurl {
      inherit name hash;
      url = "https://github.com/IdreesInc/Monocraft/releases/download/v${version}/${name}";
    };
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "monocraft";

  installPhase = ''
    runHook preInstall
    for src in "''${srcs[@]}"
    do
      install -Dm644 --target $out/share/fonts/truetype $src
    done
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  srcs = [
    (relArtifact "Monocraft.ttc" "sha256-DqGuoS8D1VKkafwBfxnqkntTv50h5gpBxcR2w/rzx/k=")
    (relArtifact "Monocraft-no-ligatures.ttc" "sha256-k+55umK30KZT39kNXFGflJ461k7EgwRrQX8sxpQ4MdA=")
    (relArtifact "Monocraft-nerd-fonts-patched.ttc" "sha256-Z/iP+efGVg9s9g+wYv01OnL2LcJlRGKVDGW2PtU9l1Q=")
  ];

  meta = {
    description = "Programming font based on the typeface used in Minecraft";
    homepage = "https://github.com/IdreesInc/Monocraft";
    license = lib.licenses.ofl;

    maintainers = with lib.maintainers; [
      zhaofengli
      coca
    ];

    platforms = lib.platforms.all;
  };
}
