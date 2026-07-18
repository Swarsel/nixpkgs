{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchzip,
  glslang,
  installShellFiles,
  libwebp,
  ncnn,
  vulkan-headers,
  vulkan-loader,
}:

# upscayl-ncnn is a fork of /pkgs/by-name/re/realesrgan-ncnn-vulkan, so the nix package is basically the same.
stdenv.mkDerivation (finalAttrs: {
  pname = "upscayl-ncnn";
  version = "20240601-103425";

  src = fetchFromGitHub {
    owner = "upscayl";
    repo = "upscayl-ncnn";
    tag = finalAttrs.version;
    hash = "sha256-rGnjL+sU5x3VXHnvuYXVdxGmHdj9eBkIZK3CwL89lN0=";
  };

  patches = [
    ./cmakelists.patch
    ./models_path.patch
  ];

  postPatch = ''
    substituteInPlace main.cpp --replace REPLACE_MODELS $out/share/models
  '';

  nativeBuildInputs = [
    cmake
    glslang
    installShellFiles
  ];

  buildInputs = [
    vulkan-loader
    libwebp
    ncnn
    vulkan-headers
    glslang
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_SYSTEM_NCNN" true)
    (lib.cmakeBool "USE_SYSTEM_WEBP" true)
    (lib.cmakeFeature "GLSLANG_TARGET_DIR" "${glslang}/lib/cmake")
  ];

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isLinux "-rpath ${
    lib.makeLibraryPath [ vulkan-loader ]
  }";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share

    installBin upscayl-bin
    ln -s ${finalAttrs.models}/models $out/share

    runHook postInstall
  '';

  models = fetchzip {
    hash = "sha256-1YiPzv1eGnHrazJFRvl37+C1F2xnoEbN0UQYkxLT+JQ=";
    stripRoot = false;
    # Choose the newst release from https://github.com/xinntao/Real-ESRGAN/releases to update
    url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Upscayl backend powered by the NCNN framework and Real-ESRGAN architecture";
    homepage = "https://github.com/upscayl/upscayl-ncnn";
    changelog = "https://github.com/upscayl/upscayl-ncnn/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      grimmauld
      getchoo
    ];

    platforms = lib.platforms.all;
    mainProgram = "upscayl-bin";
  };
})
