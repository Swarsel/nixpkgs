{
  lib,
  clinfo,
  clr,
  makeImpureTest,
  rocm-smi,
}:

makeImpureTest {
  nativeBuildInputs = [
    clinfo
    rocm-smi
  ];

  OCL_ICD_VENDORS = "${clr.icd}/etc/OpenCL/vendors";
  name = "rocm-smi";

  testScript = ''
    # Test fails if the number of platforms is 0
    clinfo | grep -E 'Number of platforms * [1-9]'
    rocm-smi | grep -A1 GPU
  '';

  testedPackage = "rocmPackages.clr";

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
