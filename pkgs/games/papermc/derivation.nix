{
  lib,
  fetchurl,
  hash,
  jre,
  makeBinaryWrapper,
  stdenvNoCC,
  udev,
  version,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version hash;
  pname = "papermc";

  src =
    let
      version-split = lib.strings.splitString "-" finalAttrs.version;
      mcVersion = builtins.elemAt version-split 0;
      buildNum = builtins.elemAt version-split 1;
    in
    fetchurl {
      inherit (finalAttrs) hash;
      url = "https://api.papermc.io/v2/projects/paper/versions/${mcVersion}/builds/${buildNum}/downloads/paper-${mcVersion}-${buildNum}.jar";
    };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -D $src $out/share/papermc/papermc.jar

    makeWrapper ${lib.getExe jre} "$out/bin/minecraft-server" \
      --append-flags "-jar $out/share/papermc/papermc.jar nogui" \
      ${lib.optionalString stdenvNoCC.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]}"}

    runHook postInstall
  '';

  allowSubstitutes = false;
  dontUnpack = true;
  preferLocalBuild = true;

  passthru = {
    updateScript = ./update.py;
  };

  meta = {
    description = "High-performance Minecraft Server";
    homepage = "https://papermc.io/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      aaronjanse
      MayNiklas
    ];

    platforms = lib.platforms.unix;
    mainProgram = "minecraft-server";
  };
})
