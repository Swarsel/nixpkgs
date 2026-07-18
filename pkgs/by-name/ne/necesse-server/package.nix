{
  lib,
  fetchzip,
  jre,
  stdenvNoCC,
}:

let
  version = "1.2.0-23522718";
  urlVersion = lib.replaceStrings [ "." ] [ "-" ] version;

in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "necesse-server";

  src = fetchzip {
    url = "https://necesse.pwn.sh/server/necesse-server-linux64-${urlVersion}.zip";
    hash = "sha256-PIguTYULddLKj6PpoSvX3gNSvqrS7oRTOPuwoA0/XOc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r . $out
    params='-nogui "$@"'
    cat >$out/bin/necesse-server <<EOF
    #! $SHELL -e
    exec ${lib.getExe jre} -jar $out/Server.jar $params
    EOF
    chmod +x $out/bin/necesse-server

    runHook postInstall
  '';

  # removing packaged jre since we use our own
  postUnpack = ''
    rm -rf "$sourceRoot/jre"
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Dedicated server for Necesse";
    homepage = "https://necessegame.com/server/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ cr0n ];
    platforms = lib.platforms.linux;
    mainProgram = "necesse-server";
  };
}
