{
  lib,
  stdenv,
  fetchurl,
  jre_headless,
  makeWrapper,
  nixosTests,
  sha1,
  udev,
  url,
  version,
}:
stdenv.mkDerivation {
  inherit version;
  pname = "minecraft-server";
  src = fetchurl { inherit url sha1; };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/lib/minecraft/server.jar

    makeWrapper ${lib.getExe jre_headless} $out/bin/minecraft-server \
      --append-flags "-jar $out/lib/minecraft/server.jar nogui" \
      ${lib.optionalString stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]}"}

    runHook postInstall
  '';

  dontUnpack = true;
  preferLocalBuild = true;

  passthru = {
    tests = { inherit (nixosTests) minecraft-server; };
    updateScript = ./update.py;
  };

  meta = {
    description = "Minecraft Server";
    homepage = "https://minecraft.net";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      tomberek
      costrouc
    ];

    platforms = lib.platforms.unix;
    mainProgram = "minecraft-server";
  };
}
