{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  cmake,
  config,
  cudaPackages,
  installShellFiles,
  unstableGitUpdater,
  versionCheckHook,
  enableCuda ? config.cudaSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "peakperf";
  version = "1.17-unstable-2024-10-07";

  src = fetchFromGitHub {
    owner = "Dr-Noob";
    repo = "peakperf";
    rev = "289c8a2f58eb51712d346d5c993b3c1d136bf031";
    hash = "sha256-CoGWj+zskcv8caFjhy55GKTKqFq2y1/nMjiVc6TzU1c=";
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
  ]
  ++ lib.optionals enableCuda [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs = lib.optionals enableCuda [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_nvml_dev
  ];

  postInstall = ''
    installManPage ${finalAttrs.src}/peakperf.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  preVersionCheck = ''
    export version=1.17
  '';

  versionCheckProgram = "${placeholder "out"}/bin/peakperf";

  versionCheckProgramArg = [
    "-v"
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Achieve peak performance on x86 CPUs and NVIDIA GPUs";
    homepage = "https://github.com/Dr-Noob/peakperf";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "peakperf";
  };
})
