{
  lib,
  clr,
  makeImpureTest,
  opencl-cts,
}:

makeImpureTest {
  nativeBuildInputs = [ opencl-cts ];
  OCL_ICD_VENDORS = "${clr.icd}/etc/OpenCL/vendors";
  name = "opencl-cts";

  sandboxPaths = [
    "/sys"
    "/dev/dri"
    "/dev/kfd"
  ];

  testScript = ''
    test_basic arraycopy arrayreadwrite astype barrier vector_swizzle work_item_functions
  '';

  testedPackage = "rocmPackages.clr";

  meta = {
    teams = [ lib.teams.rocm ];
  };
}
