{
  lib,
  clr,
  makeImpureTest,
  miopen,
  name,
  rocm-smi,
  testScript,
  writableTmpDirAsHomeHook,
}:

makeImpureTest {
  inherit name;

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    miopen
    clr
    rocm-smi
  ];

  sandboxPaths = [
    "/sys"
    "/dev/dri"
    "/dev/kfd"
  ];

  testScript = ''
    rocm-smi
    ${testScript}
  '';

  testedPackage = "rocmPackages.miopen";

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
