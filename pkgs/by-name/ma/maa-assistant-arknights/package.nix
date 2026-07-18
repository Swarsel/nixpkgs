{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  callPackage,
  cmake,
  config,
  libcpr,
  onnxruntime,
  opencv,
  cudaPackages ? { },
  cudaSupport ? config.cudaSupport,
  isBeta ? false,
}:

let
  fastdeploy = callPackage ./fastdeploy-ppocr.nix { };
  sources = lib.importJSON ./pin.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "maa-assistant-arknights" + lib.optionalString isBeta "-beta";
  version = if isBeta then sources.beta.version else sources.stable.version;

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "MaaAssistantArknights";
    rev = "v${finalAttrs.version}";
    hash = if isBeta then sources.beta.hash else sources.stable.hash;
  };

  postPatch = ''
    cp -v ${fastdeploy.cmake}/Findonnxruntime.cmake cmake/
  '';

  nativeBuildInputs = [
    asio
    cmake
    fastdeploy.cmake
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_nvcc ];

  buildInputs = [
    fastdeploy
    libcpr
    onnxruntime
    opencv
  ]
  ++ lib.optionals cudaSupport (
    with cudaPackages;
    [
      cccl # cub/cub.cuh
      libcublas # cublas_v2.h
      libcurand # curand.h
      libcusparse # cusparse.h
      libcufft # cufft.h
      cudnn # cudnn.h
      cuda_cudart
    ]
  );

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "INSTALL_FLATTEN" false)
    (lib.cmakeBool "INSTALL_PYTHON" true)
    (lib.cmakeBool "INSTALL_RESOURCE" true)
    (lib.cmakeBool "USE_MAADEPS" false)
    (lib.cmakeFeature "MAA_VERSION" "v${finalAttrs.version}")
  ];

  postInstall = ''
    mkdir -p $out/share/${finalAttrs.pname}
    mv $out/{Python,resource} $out/share/${finalAttrs.pname}
  '';

  cmakeBuildType = "None";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Arknights assistant";
    homepage = "https://github.com/MaaAssistantArknights/MaaAssistantArknights";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
