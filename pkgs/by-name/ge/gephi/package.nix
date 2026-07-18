{
  lib,
  fetchFromGitHub,
  jdk11,
  jogl,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "gephi";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "gephi";
    repo = "gephi";
    rev = "v${version}";
    hash = "sha256-ZNSEaiD32zFfF2ISKa1CmcT9Nq6r5i2rNHooQAcVbn4=";
  };

  nativeBuildInputs = [ jdk11 ];

  installPhase = ''
    cp -r modules/application/target/gephi $out

    # remove garbage
    find $out -type f -name  .lastModified -delete
    find $out -type f -regex '.+\.exe'     -delete

    # use self-compiled JOGL to avoid patchelf'ing .so inside jars
    rm $out/gephi/modules/ext/org.gephi.visualization/org-jogamp-{jogl,gluegen}/*.jar
    cp ${jogl}/share/java/jogl*.jar $out/gephi/modules/ext/org.gephi.visualization/org-jogamp-jogl/
    cp ${jogl}/share/java/glue*.jar $out/gephi/modules/ext/org.gephi.visualization/org-jogamp-gluegen/

    printf "\n\njdkhome=${jdk11}\n" >> $out/etc/gephi.conf
  '';

  mvnHash = "sha256-/2/Yb26Ry0NHQQ3j0LXnjwC0wQqJiztvTgWixyMJqvg=";
  mvnJdk = jdk11;

  meta = {
    description = "Platform for visualizing and manipulating large graphs";
    homepage = "https://gephi.org";
    license = lib.licenses.gpl3;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    maintainers = [ lib.maintainers.taeer ];
    mainProgram = "gephi";
  };
}
