{
  lib,
  fetchFromGitHub,
  jre,
  maven,
}:

maven.buildMavenPackage rec {
  inherit jre;
  pname = "zxing";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "zxing";
    repo = "zxing";
    tag = "zxing-${version}";
    hash = "sha256-D+ZKfDa406RIaTRhH9yXxgP8EpGe0iQU9CqkOMC4UdE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/java" "$out/bin"
    cp "target/javase-${version}-jar-with-dependencies.jar" "$out/lib/java"
    for source in "${./java-zxing.sh}" "${./zxing-cmdline-encoder.sh}" "${./zxing-cmdline-runner.sh}" "${./zxing-gui-runner.sh}" "${./zxing.sh}"; do
        target="''${source#*-}"
        target="$out/bin/''${target%.sh}"
        substituteAll "$source" "$target"
        chmod a+x "$target"
    done

    runHook postInstall
  '';

  mvnHash = "sha256-G21YIzAuc4LZhVqPmd2i/N42anUzmfqyciYR5XclzKk=";
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z compile assembly:single";
  sourceRoot = "${src.name}/javase";

  meta = {
    description = "1D and 2D code reading library";
    homepage = "https://github.com/zxing/zxing";
    changelog = "https://github.com/zxing/zxing/releases/tag/zxing-${version}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      fromSource
    ];

    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "zxing";
  };
}
