{
  lib,
  stdenv,
  fetchurl,
  addDriverRunpath,
  autoPatchelfHook,
  bash,
  buildPythonPackage,
  config,
  cudaPackages,
  # runtime dependencies
  httpx,
  networkx,
  numpy,
  opt-einsum,
  pillow,
  protobuf,
  python,
  pythonAtLeast,
  pythonOlder,
  rdma-core,
  safetensors,
  setuptools,
  typing-extensions,
  zlib,
  cudaSupport ? config.cudaSupport or false,
}:

let
  pname = "paddlepaddle" + lib.optionalString cudaSupport "-gpu";
  sources = import ./sources.nix;
  version = sources.version;
  format = "wheel";
  pyShortVersion = "cp${lib.replaceStrings [ "." ] [ "" ] python.pythonVersion}";
  cudaVersion = "cu${lib.replaceStrings [ "." ] [ "" ] cudaPackages.cudatoolkit.version}";

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";
  systemSources = sources."${stdenv.hostPlatform.system}" or throwSystem;

  supportedCudaVersions = lib.concatStringsSep ", " (builtins.attrNames systemSources.gpu);
  throwCuda = throw "Unsupported CUDA version: ${cudaVersion}. Supported versions: ${supportedCudaVersions}";
  platformSources =
    if cudaSupport then systemSources.gpu.${cudaVersion} or throwCuda else systemSources.cpu;

  throwPython = throw "Unsupported python version: ${pyShortVersion}";
  hash = platformSources.${pyShortVersion} or throwPython;

  platform = sources.${stdenv.hostPlatform.system}.platform;

  src = fetchurl {
    inherit hash;

    url = "https://paddle-whl.bj.bcebos.com/stable/${
      if cudaSupport then cudaVersion else "cpu"
    }/${pname}/${
      lib.replaceStrings [ "-" ] [ "_" ] pname
    }-${version}-${pyShortVersion}-${pyShortVersion}-${platform}.whl";
  };
in
buildPythonPackage {
  inherit
    pname
    version
    format
    src
    ;

  nativeBuildInputs = [
    addDriverRunpath
  ]
  ++ lib.optionals cudaSupport [ autoPatchelfHook ];

  buildInputs = lib.optionals cudaSupport [ rdma-core ];
  # no tests
  doCheck = false;

  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux (
      let
        libraryPath = lib.makeLibraryPath (
          [
            zlib
            (lib.getLib stdenv.cc.cc)
          ]
          ++ lib.optionals cudaSupport (
            with cudaPackages;
            [
              cudatoolkit.lib
              cudatoolkit.out
              cudnn
            ]
          )
        );
      in
      ''
        function fixRunPath {
          patchelf --add-rpath ${libraryPath} $1
          ${lib.optionalString cudaSupport ''
            addDriverRunpath $1
          ''}
        }
        fixRunPath $out/${python.sitePackages}/paddle/base/libpaddle.so
        fixRunPath $out/${python.sitePackages}/paddle/libs/lib*.so
      ''
    )
    + ''
      substituteInPlace $out/bin/paddle \
        --replace-fail "/bin/bash" "${lib.getExe bash}" \
        --replace-fail "python -"  "${lib.getExe (python.withPackages (ps: with ps; [ distutils ]))} -"
      sed -i '/# Check python lib installed or not./,/^fi$/d' $out/bin/paddle
      sed -i 's/^INSTALLED_VERSION=.*/INSTALLED_VERSION="${version}"/' $out/bin/paddle
    '';

  dependencies = [
    setuptools
    httpx
    numpy
    protobuf
    pillow
    opt-einsum
    networkx
    safetensors
    typing-extensions
  ];

  disabled = pythonOlder "3.12" || pythonAtLeast "3.14";
  # Segmentation fault in darwin sandbox
  pythonImportsCheck = lib.optionals stdenv.hostPlatform.isLinux [ "paddle" ];

  pythonRelaxDeps = [
    "opt_einsum"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Machine Learning Framework from Industrial Practice";
    homepage = "https://github.com/PaddlePaddle/Paddle";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ happysalada ];

    platforms = [
      "x86_64-linux"
    ]
    ++ lib.optionals (!cudaSupport) [
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
