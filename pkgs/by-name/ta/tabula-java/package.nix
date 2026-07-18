{
  lib,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "tabula-java";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "tabulapdf";
    repo = "tabula-java";
    rev = "v${version}";
    hash = "sha256-lg8/diyGhfkUU0w7PEOlxb1WNpJZVDDllxMMsTIU/Cw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp target/tabula-${version}-jar-with-dependencies.jar $out/lib/tabula.jar

    makeWrapper ${jre}/bin/java $out/bin/tabula-java \
      --add-flags "-cp $out/lib/tabula.jar" \
      --add-flags "technology.tabula.CommandLineApp"

    runHook postInstall
  '';

  mvnHash = "sha256-XMrAwOqQCt0vDUqFXodLhmujnrz2/FRSBYkAxDz9Z8c=";
  mvnParameters = "compile assembly:single -Dmaven.test.skip=true";

  meta = {
    description = "Library for extracting tables from PDF files";

    longDescription = ''
      tabula-java is the table extraction engine that powers
      Tabula. You can use tabula-java as a command-line tool to
      programmatically extract tables from PDFs.
    '';

    homepage = "https://tabula.technology/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jakewaksbaum ];
    platforms = lib.platforms.all;
    mainProgram = "tabula-java";
  };
}
