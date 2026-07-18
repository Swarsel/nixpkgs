{
  lib,
  buildPythonPackage,
  composable_kernel,
  python,
  rocm-toolchain,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage {
  inherit (composable_kernel) version src sourceRoot;
  pname = "ck4inductor";

  propagatedBuildInputs = [
    # At runtime will fail to compile anything with ck4inductor without this
    # can't easily use in checks phase because most of the compiler machinery is in torch
    rocm-toolchain
  ];

  checkPhase = ''
    if [ ! -d "$out/${python.sitePackages}/ck4inductor" ]; then
      echo "ck4inductor isn't at the expected location in $out/${python.sitePackages}/ck4inductor"
      exit 1
    fi
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ck4inductor"
    "ck4inductor.universal_gemm.gen_instances"
    "ck4inductor.universal_gemm.gen_instances"
    "ck4inductor.universal_gemm.op"
  ];

  meta = {
    description = "Pytorch inductor backend which uses composable_kernel universal GEMM implementations";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/projects/composablekernel";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
}
