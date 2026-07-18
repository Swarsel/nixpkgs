{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchMavenArtifact,
  jre,
  makeWrapper,
  stdenvNoCC,
  symlinkJoin,
}:

let
  version = "1.0.0";
  nailgun-server = fetchMavenArtifact {
    inherit version;
    artifactId = "nailgun-server";
    groupId = "com.facebook";
    sha256 = "1mk8pv0g2xg9m0gsb96plbh6mc24xrlyrmnqac5mlbl4637l4q95";
  };

  commonMeta = {
    homepage = "https://www.martiansoftware.com/nailgun/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

  server = stdenvNoCC.mkDerivation {
    inherit version;
    pname = "nailgun-server";
    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      runHook preInstall

      makeWrapper ${jre}/bin/java $out/bin/ng-server \
        --add-flags '-classpath ${nailgun-server.jar}:$CLASSPATH com.facebook.nailgun.NGServer'

      runHook postInstall
    '';

    dontUnpack = true;

    meta = commonMeta // {
      description = "Server for running Java programs from the command line without incurring the JVM startup overhead";
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    };
  };

  client = stdenv.mkDerivation {
    inherit version;
    pname = "nailgun-client";

    src = fetchFromGitHub {
      owner = "facebook";
      repo = "nailgun";
      rev = "nailgun-all-v${version}";
      sha256 = "1syyk4ss5vq1zf0ma00svn56lal53ffpikgqgzngzbwyksnfdlh6";
    };

    makeFlags = [ "PREFIX=$(out)" ];

    meta = commonMeta // {
      description = "Client for running Java programs from the command line without incurring the JVM startup overhead";
    };
  };
in
symlinkJoin rec {
  inherit client server version;
  pname = "nailgun";

  paths = [
    client
    server
  ];

  meta = commonMeta // {
    description = "Client, protocol, and server for running Java programs from the command line without incurring the JVM startup overhead";
  };
}
