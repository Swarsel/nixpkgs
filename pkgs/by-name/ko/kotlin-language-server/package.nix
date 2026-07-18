{
  lib,
  stdenv,
  fetchzip,
  gradle,
  makeWrapper,
  maven,
  openjdk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kotlin-language-server";
  version = "1.3.13";

  src = fetchzip {
    url = "https://github.com/fwcd/kotlin-language-server/releases/download/${finalAttrs.version}/server.zip";
    hash = "sha256-ypiOeXA+14Js31WPGJAdSjskQJR9sBPVWGecLkKHiN4=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  buildInputs = [
    openjdk
    gradle
  ];

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin
    cp -r lib/* $out/lib
    cp -r bin/* $out/bin
  '';

  postFixup = ''
    wrapProgram "$out/bin/kotlin-language-server" --set JAVA_HOME ${openjdk} --prefix PATH : ${
      lib.strings.makeBinPath [
        openjdk
        maven
      ]
    }
  '';

  dontBuild = true;

  meta = {
    description = "Kotlin language server";

    longDescription = ''
      About Kotlin code completion, linting and more for any editor/IDE
      using the Language Server Protocol Topics'';

    homepage = "https://github.com/fwcd/kotlin-language-server";
    changelog = "https://github.com/fwcd/kotlin-language-server/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ vtuan10 ];
    platforms = lib.platforms.unix;
    mainProgram = "kotlin-language-server";
  };
})
