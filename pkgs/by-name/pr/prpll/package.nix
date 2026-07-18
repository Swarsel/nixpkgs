{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  ocl-icd,
  opencl-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prpll";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "preda";
    repo = "gpuowl";
    tag = "v/prpll/${finalAttrs.version}";
    hash = "sha256-uARWaY48IdqWqiX4Z1ZZdhCNGqqVKbyFKOiILSln7ao=";
  };

  # Fix stricter compilation rules on aarch64
  postPatch = ''
    substituteInPlace src/common.h \
      --replace-fail "__float128" "_Float128"
  '';

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    ocl-icd
    opencl-headers
  ];

  installPhase = ''
    runHook preInstall

    installBin build-release/prpll

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Probable Prime and Lucas-Lehmer mersenne categorizer";

    longDescription = ''
      PRPLL implements two primality tests for Mersenne numbers: PRP ("PRobable Prime") and LL ("Lucas-Lehmer") as
      the name suggests.
      PRPLL is an OpenCL (GPU) program for primality testing Mersenne numbers.
    '';

    homepage = "https://github.com/preda/gpuowl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dstremur ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "prpll";
  };
})
