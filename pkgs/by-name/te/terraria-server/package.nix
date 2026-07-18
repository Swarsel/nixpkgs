{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  sdl3,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terraria-server";
  version = "1.4.5.6";

  src = fetchurl {
    url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${finalAttrs.urlVersion}.zip";
    hash = "sha256-11xFWsIX/TQ0RIyPglHBNH8IdahcQ4WJ3HG1V3d+kVU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    stdenv.cc.cc.libgcc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r Linux $out/
    chmod +x "$out/Linux/TerrariaServer.bin.x86_64"
    ln -s "$out/Linux/TerrariaServer.bin.x86_64" $out/bin/TerrariaServer

    # use our own SDL3 library
    rm $out/Linux/lib64/libSDL3.so.0
    ln -s ${lib.getLib sdl3}/lib/libSDL3.so.0 $out/Linux/lib64/libSDL3.so.0

    runHook postInstall
  '';

  urlVersion = lib.replaceStrings [ "." ] [ "" ] finalAttrs.version;

  meta = {
    description = "Dedicated server for Terraria, a 2D action-adventure sandbox";
    homepage = "https://terraria.org";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      tomasajt
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "TerrariaServer";
  };
})
