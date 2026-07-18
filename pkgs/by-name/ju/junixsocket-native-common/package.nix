{
  lib,
  fetchMavenArtifact,
  junixsocket-common,
}:

fetchMavenArtifact {
  inherit (junixsocket-common) version;
  artifactId = "junixsocket-native-common";
  groupId = "com.kohlschutter.junixsocket";
  hash = "sha256-ASbOC68c61de9ReAfU0rFLnzLwYYAgThLsc6tKdyVno=";

  meta = junixsocket-common.meta // {
    description = "Binaries of the native JNI library for junixsocket for common platforms";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
