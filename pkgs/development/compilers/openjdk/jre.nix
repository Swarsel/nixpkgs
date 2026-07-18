{
  lib,
  stdenv,
  callPackage,
  jdk,
  jdkOnBuild, # must provide jlink
  modules ? [ "java.base" ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "${jdk.pname}-minimal-jre";
  version = jdk.version;
  strictDeps = true;
  nativeBuildInputs = [ jdkOnBuild ];
  buildInputs = [ jdk ];

  buildPhase = ''
    runHook preBuild

    jlink --module-path ${jdk}/lib/openjdk/jmods --add-modules ${lib.concatStringsSep "," modules} --output $out

    runHook postBuild
  '';

  dontInstall = true;
  dontUnpack = true;
  # Strip more heavily than the default '-S', since if you're
  # using this derivation you probably care about this.
  stripDebugFlags = [ "--strip-unneeded" ];

  passthru = {
    home = "${finalAttrs.finalPackage}";

    tests = {
      jre_minimal-hello = callPackage ./tests/test_jre_minimal.nix { };
      jre_minimal-hello-logging = callPackage ./tests/test_jre_minimal_with_logging.nix { };
    };
  };

  meta = jdk.meta // {
    description = "Minimal JRE for OpenJDK ${jdk.version}";

    longDescription = ''
      This is a minimal JRE built from OpenJDK, containing only the specified modules.
      It is suitable for running Java applications that do not require the full JDK.
    '';
  };
})
