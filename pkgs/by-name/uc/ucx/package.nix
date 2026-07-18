{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  autoreconfHook,
  config,
  cudaPackages,
  doxygen,
  libbfd,
  libiberty,
  numactl,
  perl,
  pkg-config,
  rdma-core,
  rocmPackages,
  symlinkJoin,
  zlib,
  enableCuda ? config.cudaSupport,
  enableRocm ? config.rocmSupport,
}:

let
  rocmList = with rocmPackages; [
    rocm-core
    rocm-runtime
    rocm-device-libs
    clr
  ];

  rocm = symlinkJoin {
    name = "rocm";
    paths = rocmList;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ucx";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "openucx";
    repo = "ucx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Td6L5wXDadIbHfk251bj6k9J3kIjqCYVx5lDso/u76M=";
    # Otherwise compilation fails with:
    #   fatal error: gpunetio/common/doca_gpunetio_verbs_def.h: No such file or directory
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "doc"
    "dev"
  ];

  postPatch = ''
    patchShebangs config/nvcc_wrap.sh
  '';

  # TODO(@connorbaker):
  # When strictDeps is enabled, `cuda_nvcc` is required as the argument to `--with-cuda` in `configureFlags` or else
  # configurePhase fails with `checking for cuda_runtime.h... no`.
  # This is odd, especially given `cuda_runtime.h` is provided by `cuda_cudart.dev`, which is already in `buildInputs`.
  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    doxygen
    pkg-config
  ]
  ++ lib.optionals enableCuda [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs = [
    libbfd
    libiberty
    numactl
    perl
    rdma-core
    zlib
  ]
  ++ lib.optionals enableCuda [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_nvml_dev

  ]
  ++ lib.optionals enableRocm rocmList;

  configureFlags = [
    "--with-rdmacm=${lib.getDev rdma-core}"
    "--with-dc"
    "--with-rc"
    "--with-dm"
    "--with-verbs=${lib.getDev rdma-core}"
  ]
  ++ lib.optionals enableCuda [ "--with-cuda=${cudaPackages.cuda_nvcc}" ]
  ++ lib.optionals enableRocm [ "--with-rocm=${rocm}" ];

  # NOTE: With `__structuredAttrs` enabled, `LDFLAGS` must be set under `env` so it is assured to be a string;
  # otherwise, we might have forgotten to convert it to a string and Nix would make LDFLAGS a shell variable
  # referring to an array!
  env.LDFLAGS = toString (
    lib.optionals enableCuda [
      # Fake libcuda.so (the real one is deployed impurely)
      "-L${lib.getOutput "stubs" cudaPackages.cuda_cudart}/lib/stubs"
      # Fake libnvidia-ml.so (the real one is deployed impurely)
      "-L${lib.getOutput "stubs" cudaPackages.cuda_nvml_dev}/lib/stubs"
    ]
  );

  postInstall = ''
    find $out/lib/ -name "*.la" -exec rm -f \{} \;

    moveToOutput bin/ucx_info $dev

    moveToOutput share/ucx/examples $doc
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Unified Communication X library";
    homepage = "https://www.openucx.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.linux;
    # LoongArch64 is not supported.
    # See: https://github.com/openucx/ucx/issues/9873
    badPlatforms = lib.platforms.loongarch64;
  };
})
