{
  lib,
  stdenv,
  autoPatchelfHook,
  buildPythonPackage,
  cudaPackages,
  fetchPypi,
  jax-cuda12-pjrt,
  jaxlib,
  pypaInstallHook,
  python,
  wheelUnpackHook,
}:
let
  inherit (jaxlib) version;
  inherit (jax-cuda12-pjrt) cudaLibPath;

  getSrcFromPypi =
    {
      dist,
      hash,
      platform,
    }:
    fetchPypi {
      inherit
        version
        platform
        dist
        hash
        ;

      pname = "jax_cuda12_plugin";
      abi = dist;
      format = "wheel";
      python = dist;
    };

  # upstream does not distribute jax-cuda12-plugin 0.4.38 binaries for aarch64-linux
  srcs = {
    "3.11-aarch64-linux" = getSrcFromPypi {
      dist = "cp311";
      hash = "sha256-nNCTcHC70o5EuRQ1tSxyJcjtbLN922qQ6cJGhzoD+c0=";
      platform = "manylinux_2_27_aarch64";
    };

    "3.11-x86_64-linux" = getSrcFromPypi {
      dist = "cp311";
      hash = "sha256-drv+zi9u/7TokI64pfvxq7wRJd5mdoPsL/ulHGPcV68=";
      platform = "manylinux_2_27_x86_64";
    };

    "3.12-aarch64-linux" = getSrcFromPypi {
      dist = "cp312";
      hash = "sha256-dnoUgtv2UmiEA8TiL/AUcOGt0TxI+dgXFp/Y90QK/OU=";
      platform = "manylinux_2_27_aarch64";
    };

    "3.12-x86_64-linux" = getSrcFromPypi {
      dist = "cp312";
      hash = "sha256-Trbo4Jkv2Yl9skaNoz8nauQU7ITcQ2gEEkQEQwUC7qw=";
      platform = "manylinux_2_27_x86_64";
    };

    "3.13-aarch64-linux" = getSrcFromPypi {
      dist = "cp313";
      hash = "sha256-aXdqyEkRL0/C1vphb4dyEG2v84/NuCXE459H6HjydhA=";
      platform = "manylinux_2_27_aarch64";
    };

    "3.13-x86_64-linux" = getSrcFromPypi {
      dist = "cp313";
      hash = "sha256-lIqYiSfLEIQ7UBohUYHMsdrtP6cFMbLxrghC/hwIsF4=";
      platform = "manylinux_2_27_x86_64";
    };

    "3.14-aarch64-linux" = getSrcFromPypi {
      dist = "cp314";
      hash = "sha256-SUbsV923leLagojOsc7d1YwqIEoPd2WvierkhqHTrOc=";
      platform = "manylinux_2_27_aarch64";
    };

    "3.14-x86_64-linux" = getSrcFromPypi {
      dist = "cp314";
      hash = "sha256-DHoCBBVVhcwcT8swxmt/iBs45X4fDY6X1I4WVL8NJ/g=";
      platform = "manylinux_2_27_x86_64";
    };
  };
in
buildPythonPackage {
  inherit version;
  pname = "jax-cuda12-plugin";

  src = (
    srcs."${python.pythonVersion}-${stdenv.hostPlatform.system}"
      or (throw "python${python.pythonVersion}Packages.jax-cuda12-plugin is not supported on ${stdenv.hostPlatform.system}")
  );

  nativeBuildInputs = [
    autoPatchelfHook
    pypaInstallHook
    wheelUnpackHook
  ];

  # FIXME: there are no tests, but we need to run preInstallCheck above
  doCheck = true;

  # jax-cuda12-plugin looks for ptxas at runtime, e.g. with a triton kernel.
  # Linking into $out is the least bad solution. See
  # * https://github.com/NixOS/nixpkgs/pull/164176#discussion_r828801621
  # * https://github.com/NixOS/nixpkgs/pull/288829#discussion_r1493852211
  # * https://github.com/NixOS/nixpkgs/pull/375186
  # for more info.
  postInstall = ''
    mkdir -p $out/${python.sitePackages}/jax_cuda12_plugin/cuda/bin
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "ptxas"} $out/${python.sitePackages}/jax_cuda12_plugin/cuda/bin
    ln -s ${lib.getExe' cudaPackages.cuda_nvcc "nvlink"} $out/${python.sitePackages}/jax_cuda12_plugin/cuda/bin
  '';

  dependencies = [ jax-cuda12-pjrt ];

  # jax-cuda12-plugin contains shared libraries that open other shared libraries via dlopen
  # and these implicit dependencies are not recognized by ldd or
  # autoPatchelfHook. That means we need to sneak them into rpath. This step
  # must be done after autoPatchelfHook and the automatic stripping of
  # artifacts. autoPatchelfHook runs in postFixup and auto-stripping runs in the
  # patchPhase.
  preInstallCheck = ''
    patchelf --add-rpath "${cudaLibPath}" $out/${python.sitePackages}/jax_cuda12_plugin/*.so
  '';

  pyproject = false;
  pythonImportsCheck = [ "jax_cuda12_plugin" ];

  meta = {
    description = "JAX Plugin for CUDA12";
    homepage = "https://github.com/jax-ml/jax/tree/main/jax_plugins/cuda";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.linux;
    # see CUDA compatibility matrix
    # https://jax.readthedocs.io/en/latest/installation.html#pip-installation-nvidia-gpu-cuda-installed-locally-harder
    broken = !(lib.versionAtLeast cudaPackages.cudnn.version "9.1");
  };
}
