# NOTE: Though NCCL tests is called within the cudaPackages package set, we avoid passing in
# the names of dependencies from that package set directly to avoid evaluation errors
# in the case redistributable packages are not available.
{
  lib,
  fetchFromGitHub,
  _cuda,
  backendStdenv,
  cccl,
  cudaNamePrefix,
  cuda_cudart,
  cuda_nvcc,
  flags,
  gitUpdater,
  mpi,
  nccl,
  which,
  mpiSupport ? false,
}:
let
  inherit (_cuda.lib) _mkMetaBroken;
  inherit (lib) licenses maintainers teams;
  inherit (lib.attrsets) getBin getInclude getLib;
  inherit (lib.lists) optionals;
in
backendStdenv.mkDerivation (finalAttrs: {
  pname = "nccl-tests";
  version = "2.19.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "nccl-tests";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eRwIl646ndISFttjG5nPqsXfPVmInABNIsphhh5I0wM=";
  };

  postPatch = ''
    nixLog "patching $PWD/src/common.mk to remove NVIDIA's ccbin declaration"
    substituteInPlace ./src/common.mk \
      --replace-fail \
        '-ccbin $(CXX)' \
        ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    which
    cuda_nvcc
  ];

  buildInputs = [
    cccl # <nv/target>
    cuda_cudart
    nccl
  ]
  ++ optionals mpiSupport [ mpi ];

  # NOTE: CUDA_HOME is expected to have the bin directory
  # TODO: This won't work with cross-compilation since cuda_nvcc will come from hostPackages by default (aka pkgs).
  makeFlags = [
    "CXXSTD=-std=c++17"
    "CUDA_HOME=${getBin cuda_nvcc}"
    "CUDA_INC=${getInclude cuda_cudart}/include"
    "CUDA_LIB=${getLib cuda_cudart}/lib"
    "NVCC_GENCODE=${flags.gencodeString}"
    "PREFIX=$(out)"
  ]
  ++ optionals mpiSupport [ "MPI=1" ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -Dm755 \
      $(find build -type f -executable) \
      "$out/bin"
    runHook postInstall
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;
  # NOTE: Depends on the CUDA package set, so use cudaNamePrefix.
  name = "${cudaNamePrefix}-${finalAttrs.pname}-${finalAttrs.version}";

  passthru = {
    brokenAssertions = [
      {
        assertion = mpiSupport -> mpi != null;
        message = "mpi is non-null when mpiSupport is true";
      }
    ];

    updateScript = gitUpdater {
      inherit (finalAttrs) pname version;
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Tests to check both the performance and the correctness of NVIDIA NCCL operations";
    homepage = "https://github.com/NVIDIA/nccl-tests";
    license = licenses.bsd3;
    maintainers = with maintainers; [ jmillerpdt ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    broken = _mkMetaBroken finalAttrs;
    teams = [ teams.cuda ];
  };
})
