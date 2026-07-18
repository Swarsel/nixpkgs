{
  lib,
  fetchzip,
  pkgs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "traccar";
  version = "6.13.3";

  src = fetchzip {
    url = "https://github.com/traccar/traccar/releases/download/v${version}/traccar-other-${version}.zip";
    hash = "sha256-QQJ3+QByXkdfGBPA38F8+sQ72NnRbet6zcD3K82JLbI=";
    stripRoot = false;
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    for dir in lib schema templates web ; do
      mkdir -p $out/$dir
      cp -a $dir $out
    done

    mkdir -p $out/share/traccar
    install -Dm644 tracker-server.jar $out

    makeWrapper ${pkgs.openjdk}/bin/java $out/bin/traccar \
      --add-flags "-jar $out/tracker-server.jar"

    runHook postInstall
  '';

  meta = {
    description = "Open source GPS tracking system";
    homepage = "https://www.traccar.org/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ frederictobiasc ];
    mainProgram = "traccar";
  };
}
