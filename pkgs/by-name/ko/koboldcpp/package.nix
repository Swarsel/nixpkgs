{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  clblast,
  config,
  makeWrapper,
  nix-update-script,
  ocl-icd,
  python3Packages,
  shaderc,
  tk,
  vulkan-loader,
  clblastSupport ? stdenv.hostPlatform.isLinux,
  cublasSupport ? config.cudaSupport,
  # You can find a full list here: https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
  # For example if you're on an RTX 3060 that means you're using "Ampere" and you need to pass "sm_86"
  cudaArches ? cudaPackages.flags.realArches or [ ],
  cudaPackages ? { },
  koboldLiteSupport ? true,
  metalSupport ? stdenv.hostPlatform.isDarwin,
  vulkanSupport ? true,
}:

let
  makeBool = option: bool: (if bool then "${option}=1" else "");

  libraryPathWrapperArgs = lib.optionalString config.cudaSupport ''
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ addDriverRunpath.driverLink ]}"
  '';

  effectiveStdenv = if cublasSupport then cudaPackages.backendStdenv else stdenv;
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "koboldcpp";
  version = "1.110";

  src = fetchFromGitHub {
    owner = "LostRuins";
    repo = "koboldcpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wizg/XkNjWUeF0heK1sQQhfKRlIYBKwJmQ8fIaZ2zdE=";
  };

  postPatch = ''
    nixLog "patching $PWD/Makefile to remove explicit linking against CUDA driver"
    substituteInPlace "$PWD/Makefile" \
      --replace-fail \
        'CUBLASLD_FLAGS = -lcuda ' \
        'CUBLASLD_FLAGS = '
  '';

  nativeBuildInputs = [
    makeWrapper
    python3Packages.wrapPython
  ]
  ++ lib.optionals vulkanSupport [ shaderc ];

  buildInputs = [
    tk
  ]
  ++ finalAttrs.pythonInputs
  ++ lib.optionals cublasSupport [
    cudaPackages.libcublas
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    cudaPackages.cccl
  ]
  ++ lib.optionals clblastSupport [
    clblast
    ocl-icd
  ]
  ++ lib.optionals vulkanSupport [
    vulkan-loader
  ];

  makeFlags = [
    (makeBool "LLAMA_CUBLAS" cublasSupport)
    (makeBool "LLAMA_CLBLAST" clblastSupport)
    (makeBool "LLAMA_VULKAN" vulkanSupport)
    (makeBool "LLAMA_METAL" metalSupport)
    (lib.optionals cublasSupport "CUDA_DOCKER_ARCH=${builtins.head cudaArches}")
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"

    install -Dm755 koboldcpp.py "$out/bin/koboldcpp.unwrapped"
    cp *.so "$out/bin"
    cp embd_res/*.embd "$out/bin"

    ${lib.optionalString metalSupport ''
      cp *.metal "$out/bin"
    ''}

    ${lib.optionalString (!koboldLiteSupport) ''
      rm "$out/bin/kcpp_docs.embd"
      rm "$out/bin/klite.embd"
    ''}

    runHook postInstall
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/bin" "''${pythonPath[*]}"
    makeWrapper "$out/bin/koboldcpp.unwrapped" "$out/bin/koboldcpp" \
      --prefix PATH : ${lib.makeBinPath [ tk ]} ${libraryPathWrapperArgs}
  '';

  enableParallelBuilding = true;
  pythonInputs = builtins.attrValues { inherit (python3Packages) tkinter customtkinter packaging; };
  pythonPath = finalAttrs.pythonInputs;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Way to run various GGML and GGUF models";
    homepage = "https://github.com/LostRuins/koboldcpp";
    changelog = "https://github.com/LostRuins/koboldcpp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      maxstrid
      _4evy
    ];

    platforms = lib.platforms.unix;
    mainProgram = "koboldcpp";
  };
})
