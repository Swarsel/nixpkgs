{
  ant,
  jbr,
  jpsHash,
  runCommand,
  src,
}:
runCommand "jps-bootstrap-repository"
  {
    nativeBuildInputs = [
      ant
      jbr
    ];

    outputHash = jpsHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  }
  ''
    ant -Duser.home=$out -Dbuild.dir=$(mktemp -d) -f ${src}/platform/jps-bootstrap/jps-bootstrap-classpath.xml
    find $out -type f \( \
      -name \*.lastUpdated \
      -o -name resolver-status.properties \
      -o -name _remote.repositories \) \
      -delete
  ''
