{
  lib,
  fetchFromGitHub,
  docbook_xml_dtd_42,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "sqlline";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "julianhyde";
    repo = "sqlline";
    tag = "sqlline-${version}";
    hash = "sha256-rUlGtMgTfhciQVif0KaUcuY28wh+PrHsKen8qODom24=";
  };

  # Patch the DOCTYPE declaration in manual.xml
  postPatch = ''
    substituteInPlace src/docbkx/manual.xml \
      --replace-fail "https://docbook.org/xml/4.2/docbookx.dtd" "${docbook_xml_dtd_42}/xml/dtd/docbook/docbookx.dtd" \
      --replace-fail 'PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"' 'PUBLIC "-//OASIS//DTD DocBook XML V4.2//EN"'
  '';

  nativeBuildInputs = [
    makeWrapper
    docbook_xml_dtd_42
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -D target/sqlline-${version}-jar-with-dependencies.jar $out/share/java/sqlline-${version}.jar
    makeWrapper ${jre}/bin/java $out/bin/sqlline \
      --add-flags "-jar $out/share/java/sqlline-${version}.jar"
    runHook postInstall
  '';

  buildOffline = true;
  mvnHash = "sha256-rqVKHMG/MKyo9P8DiMm87/Gc4YFgkkawagOjBUlrESU=";
  mvnParameters = "-DskipTests";

  meta = {
    description = "Shell for issuing SQL to relational databases via JDBC";
    homepage = "https://github.com/julianhyde/sqlline";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ taranarmo ];
    mainProgram = "sqlline";
  };
}
