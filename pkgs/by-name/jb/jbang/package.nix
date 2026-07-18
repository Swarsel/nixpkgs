{
  lib,
  stdenv,
  coreutils,
  curl,
  fetchzip,
  jdk,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "jbang";
  version = "0.136.0";

  src = fetchzip {
    url = "https://github.com/jbangdev/jbang/releases/download/v${version}/${pname}-${version}.tar";
    sha256 = "sha256-MsP4iLquOwJWlV7EPxSuAPWuyTv1PPSyQCrVdq4lPlM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    rm bin/jbang.{cmd,ps1}
    cp -r . $out
    wrapProgram $out/bin/jbang \
      --set JAVA_HOME ${jdk} \
      --prefix PATH ${
        lib.makeBinPath [
          (placeholder "out")
          coreutils
          jdk
          curl
        ]
      }
    runHook postInstall
  '';

  installCheckPhase = ''
    $out/bin/jbang --version 2>&1 | grep -q "${version}"
  '';

  meta = {
    description = "Run java as scripts anywhere";

    longDescription = ''
      jbang uses the java language to build scripts similar to groovy scripts. Dependencies are automatically
      downloaded and the java code runs.
    '';

    homepage = "https://www.jbang.dev";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ moaxcp ];
    platforms = lib.platforms.all;
    mainProgram = "jbang";
  };
}
