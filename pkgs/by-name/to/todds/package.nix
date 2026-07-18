{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  boost,
  # nativeBuildInputs
  cmake,
  config,
  cudaPackages,
  fmt,
  ispc,
  ninja,
  # passthru
  nix-update-script,
  onetbb,
  opencv,
  pkg-config,
  vectorscan,
  # tests
  versionCheckHook,
  cudaSupport ? config.cudaSupport,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "todds";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "todds-encoder";
    repo = "todds";
    tag = finalAttrs.version;
    hash = "sha256-nyYFYym9ZZskkaTPV30+QavdqpvVopnIXXZC6zkeu7c=";
    fetchSubmodules = true;
  };

  patches = [ ./TBB-version.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ispc
    ninja
    pkg-config
  ]
  ++ lib.optionals cudaSupport [
    (lib.getBin cudaPackages.cuda_nvcc)
  ];

  buildInputs = [
    boost
    fmt
    onetbb
    opencv
    vectorscan
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CPU-based DDS encoder optimized for fast batch conversions with high encoding quality";
    homepage = "https://github.com/todds-encoder/todds";
    changelog = "https://github.com/todds-encoder/todds/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ weirdrock ];
    platforms = lib.platforms.linux;
    mainProgram = "todds";
  };
})
