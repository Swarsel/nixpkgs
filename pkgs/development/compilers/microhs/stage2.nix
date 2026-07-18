{
  stdenv,
  args,
  callPackage,
  cpphs,
  microcabal-stage1,
  microhs-stage1,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    args' = args finalAttrs;
    haskellCompilerName = "mhs-${args'.version}";
  in
  args'
  // {
    pname = "microhs";

    nativeBuildInputs = [
      microcabal-stage1
      microhs-stage1
    ];

    env = {
      CABALDIR = "${placeholder "out"}/lib/mcabal";
    };

    installPhase = ''
      runHook preInstall

      pushd lib
      mcabal -v install
      popd
      mcabal -v install

      mkdir -p $out/bin
      ln -s ../lib/mcabal/bin/mhs $out/bin/mhs

      runHook postInstall
    '';

    dontBuild = true;

    passthru = {
      inherit
        haskellCompilerName
        cpphs
        microcabal-stage1
        microhs-stage1
        ;

      isMhs = true;
      targetPrefix = "";

      tests = {
        hello-world = callPackage ./test-hello-world.nix { microhs = finalAttrs.finalPackage; };
      };

      usesHugs = false;
    };
  }
)
