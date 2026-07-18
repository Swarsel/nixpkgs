{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  gmp,
  nix-update-script,
  ocl-icd,
  opencl-headers,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prmers";
  version = "4.20.14-alpha-vtrace-memsafe-v63";

  src = fetchFromGitHub {
    owner = "cherubrock-seb";
    repo = "PrMers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QnQTAwsReKY7Rqm8spXmHZwfrw5VCsOOAtvhzE4GmHg=";
  };

  buildInputs = [
    curl
    gmp
    ocl-icd
    opencl-headers
  ];

  installPhase = ''
    runHook preInstall

    make install PREFIX=$out KERNEL_PATH=$out/bin/kernels

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  versionCheckProgramArg = "-v";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=unstable" ]; };

  meta = {
    description = "GPU-accelerated Mersenne primality testing";

    longDescription = ''
      PrMers is a high-performance GPU application for Lucas–Lehmer (LL), PRP, and P-1 testing of Mersenne numbers.
         It uses OpenCL and integer NTT/IBDWT kernels and is built for long, reliable runs with checkpointing and PrimeNet submission.
    '';

    homepage = "https://github.com/cherubrock-seb/PrMers";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dstremur ];
    platforms = lib.platforms.linux;
    mainProgram = "prmers";
    downloadPage = "https://github.com/cherubrock-seb/PrMers/releases/tag/v${finalAttrs.version}";
  };
})
