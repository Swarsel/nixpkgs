{
  lib,
  stdenv,
  fetchFromGitLab,
  gradle_8,
  jre_headless,
  jre_minimal,
  runtimeShell,
}:
let
  # "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0."
  gradle = gradle_8;

  jre = jre_minimal.override {
    jdk = jre_headless;

    modules = [
      "java.base"
      "java.desktop"
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "pdftk";
  version = "3.3.3";

  src = fetchFromGitLab {
    owner = "pdftk-java";
    repo = "pdftk";
    rev = "v${version}";
    hash = "sha256-ciKotTHSEcITfQYKFZ6sY2LZnXGChBJy0+eno8B3YHY=";
  };

  nativeBuildInputs = [ gradle ];

  installPhase = ''
    mkdir -p $out/{bin,share/pdftk,share/man/man1}
    cp build/libs/pdftk-all.jar $out/share/pdftk

    cat  << EOF > $out/bin/pdftk
    #!${runtimeShell}
    exec ${jre}/bin/java -jar "$out/share/pdftk/pdftk-all.jar" "\$@"
    EOF
    chmod a+x "$out/bin/pdftk"

    cp ${src}/pdftk.1 $out/share/man/man1
  '';

  __darwinAllowLocalNetworking = true;
  gradleBuildTask = "shadowJar";
  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  meta = {
    description = "Command-line tool for working with PDFs";
    homepage = "https://gitlab.com/pdftk-java/pdftk";
    license = lib.licenses.gpl2Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pdftk";
  };
}
