{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clr,
  distro,
  fetchpatch,
  filelock,
  joblib,
  msgpack,
  pandas,
  pytestCheckHook,
  pyyaml,
  rich,
  rocmUpdateScript,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tensile";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "ROCm";
    repo = "rocm-libraries";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-sYudPiEPGeZLmf6+3XfQDZqRXiKgRsGPucApzYwlGV8=";

    sparseCheckout = [
      "shared/tensile"
      "shared"
    ];
  };

  patches = [
    ./tensile-solutionstructs-perf-fix.diff
    ./tensile-create-library-dont-copy-twice.diff
    (fetchpatch {
      # [PATCH] Extend Tensile HIP ISA compatibility
      hash = "sha256-ZHXNYSeLkhhNDaIfdqQm68Pxmh1shUL7mAVmh8/I6Xk=";
      relative = "shared/tensile";
      url = "https://github.com/GZGavinZhao/rocm-libraries/commit/1f7135dfc0cdb175c8f0e5eb71b2d24699942873.patch";
    })
  ];

  # TODO: It should be possible to run asm caps test ONCE for all supported arches
  # We currently disable the test because it's slow and runs each time tensile launches
  postPatch = ''
    substituteInPlace Tensile/Common.py \
      --replace-fail 'if globalParameters["AssemblerPath"] is not None:' "if False:"
    # Add an assert that the fallback 9,0,0 is supported before setting the kernel to it
    # If it's not detected as supported we have an issue with compiler paths or the compiler is broken
    # and it's better to stop immediately
    substituteInPlace Tensile/KernelWriter.py \
      --replace-fail '= (9,0,0)' '= (9,0,0);assert(globalParameters["AsmCaps"][(9,0,0)]["SupportedISA"])'
    find . -type f -iname "*.sh" -exec chmod +x {} \;
    patchShebangs Tensile
  '';

  buildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pyyaml
    msgpack
    pandas
    joblib
    distro
    rich
  ];

  env.ROCM_PATH = "${clr}";
  doCheck = false; # Too many errors, not sure how to set this up properly

  nativeCheckInputs = [
    pytestCheckHook
    filelock
    clr
  ];

  pyproject = true;
  pythonImportsCheck = [ "Tensile" ];
  sourceRoot = "${finalAttrs.src.name}/shared/tensile";
  passthru.updateScript = rocmUpdateScript { inherit finalAttrs; };

  meta = {
    description = "GEMMs and tensor contractions";
    homepage = "https://github.com/ROCm/rocm-libraries/tree/develop/shared/tensile";
    license = with lib.licenses; [ mit ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.rocm ];
  };
})
