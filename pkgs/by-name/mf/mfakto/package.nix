{
  lib,
  stdenv,
  fetchFromGitHub,
  makeBinaryWrapper,
  ocl-icd,
  opencl-headers,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mfakto";
  version = "0.16.0-beta.5";

  src = fetchFromGitHub {
    owner = "primesearch";
    repo = "mfakto";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aQWFvdCWrab8Bz4lRWtdp2pS2Rswi5MS/1Ka5n/iJTU=";
  };

  # Patch the hardcoded kernel path
  # Inject opencl-headers for GPU compilation
  postPatch = ''
    substituteInPlace src/mfakto.h \
        --replace-fail '"mfakto_Kernels.cl"' '"'$out'/share/mfakto/mfakto_Kernels.cl"'
    sed -i "/clBuildProgram/i \    strcat(program_options, \" -I $out/share/mfakto\");" src/mfakto.cpp
  '';

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    ocl-icd
    opencl-headers
  ];

  makeFlags = [
    "-C"
    "src"
    # Override needed for aarch64 support
    "CC=${stdenv.cc.targetPrefix}gcc"
    "CPP=${stdenv.cc.targetPrefix}g++"
    "LD=${stdenv.cc.targetPrefix}g++"
    "SHELL=${runtimeShell}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 mfakto $out/bin/mfakto
    install -Dm644 mfakto.ini -t $out/share/mfakto

    install -Dm444 *.cl $out/share/mfakto
    install -Dm444 *.h $out/share/mfakto

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Trial Factoring program using OpenCL for GIMPS";

    longDescription = ''
      mfakto is an OpenCL port of mfaktc that aims to have the same features and
      functions. mfaktc is a program that trial factors Mersenne numbers. It stands
      for "Mersenne faktorisation* with CUDA" and was written for Nvidia GPUs. Both
      programs are used primarily in the Great Internet Mersenne Prime Search. mfakto
      can also run on CPUs, although this is not done in practice.
    '';

    homepage = "https://github.com/primesearch/mfakto";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dstremur ];
    platforms = lib.platforms.linux;
    mainProgram = "mfakto";
  };
})
