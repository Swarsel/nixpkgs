{
  lib,
  stdenv,
  fetchurl,
  jdk21,
  makeWrapper,
  nixosTests,
  jdk ? jdk21,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lavalink";
  version = "4.2.2";

  src = fetchurl {
    url = "https://github.com/lavalink-devs/Lavalink/releases/download/${finalAttrs.version}/Lavalink.jar";
    hash = "sha256-jLgB5ZEHLDaJ+v1xzPVxqVpOrTzDXfwEXhV9dj2JEZo=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${lib.getExe jdk} $out/bin/lavalink \
      --add-flags "-jar $src"

    runHook postInstall
  '';

  dontUnpack = true;
  passthru.tests = { inherit (nixosTests) lavalink; };

  meta = {
    inherit (jdk.meta) platforms;
    description = "Standalone audio sending node based on Lavaplayer and Koe";

    longDescription = ''
      A standalone audio sending node based on Lavaplayer and Koe. Allows for sending audio without it ever reaching any of your shards.

      Being used in production by FredBoat, Dyno, LewdBot, and more.
    '';

    homepage = "https://lavalink.dev/";
    changelog = "https://github.com/lavalink-devs/Lavalink/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ nanoyaki ];
    mainProgram = "lavalink";
  };
})
