{
  lib,
  stdenv,
  clr,
  makeImpureTest,
  rocm-smi,
}:
# minimal hiprtc test that compiles a kernel using <type_traits> at runtime
# mirrors an migraphx workload, better test/iteration UX to be able to confirm
# with just a build up to clr
let
  hiprtc-test = stdenv.mkDerivation {
    pname = "hiprtc-type-traits-test";
    version = "0";
    nativeBuildInputs = [ clr ];

    buildPhase = ''
      runHook preBuild
      hipcc -o hiprtc-test ${./test-hiprtc-type-traits.cpp} -lhiprtc
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp hiprtc-test $out/bin/
      runHook postInstall
    '';

    dontUnpack = true;
  };
in
makeImpureTest {
  nativeBuildInputs = [
    hiprtc-test
    rocm-smi
  ];

  name = "hiprtc-type-traits";

  sandboxPaths = [
    "/sys"
    "/dev/dri"
    "/dev/kfd"
  ];

  testScript = ''
    rocm-smi
    hiprtc-test
  '';

  testedPackage = "rocmPackages.clr";

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
