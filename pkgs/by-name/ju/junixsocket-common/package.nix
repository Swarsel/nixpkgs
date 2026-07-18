{
  lib,
  fetchMavenArtifact,
}:

fetchMavenArtifact {
  version = "2.10.1";
  artifactId = "junixsocket-common";
  groupId = "com.kohlschutter.junixsocket";
  hash = "sha256-GeX3YVrSKT81Mrw/mRsxOWwRYYNOidmmqgx975OcZyk=";

  meta = {
    description = "Java/JNI library that allows the use of Unix Domain Sockets (AF_UNIX sockets) and other socket types, such as AF_TIPC and AF_VSOCK, from Java, using the standard Socket API";
    homepage = "https://kohlschutter.github.io/junixsocket/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.vog ];
  };
}
