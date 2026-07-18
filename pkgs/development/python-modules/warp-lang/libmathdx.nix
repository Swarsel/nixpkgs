{
  lib,
  fetchurl,
  _cuda,
  cudaPackages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  # NOTE: The version used should match the version Warp requires:
  # https://github.com/NVIDIA/warp/blob/${version}/deps/libmathdx-deps.packman.xml
  pname = "libmathdx";
  version = "0.2.3";

  src =
    let
      baseURL = "https://developer.nvidia.com/downloads/compute/cublasdx/redist/cublasdx";
      cudaMajorVersion = cudaPackages.cudaMajorVersion; # only 12, 13 supported
      cudaVersion = "${cudaMajorVersion}.0"; # URL example: ${baseURL}/cuda12/${name}-${version}-cuda12.0.zip
      name = lib.concatStringsSep "-" [
        finalAttrs.pname
        "Linux"
        stdenvNoCC.hostPlatform.parsed.cpu.name
        finalAttrs.version
        "cuda${cudaVersion}"
      ];

      # nix-hash --type sha256 --to-sri $(nix-prefetch-url "https://...")
      hashes = {
        "12" = {
          aarch64-linux = "sha256-d/aBC+zU2ciaw3isv33iuviXYaLGLdVDdzynGk9SFck=";
          x86_64-linux = "sha256-CHIH0s4SnA67COtHBkwVCajW/3f0VxNBmuDLXy4LFIg=";
        };

        "13" = {
          aarch64-linux = "sha256-TetJbMts8tpmj5PV4+jpnUHMcooDrXUEKL3aGWqilKI=";
          x86_64-linux = "sha256-wLJLbRpQWa6QEm8ibm1gxt3mXvkWvu0vEzpnqTIvE1M=";
        };
      };
    in
    lib.mapNullable (
      hash:
      fetchurl {
        inherit hash name;
        url = "${baseURL}/cuda${cudaMajorVersion}/${name}.tar.gz";
      }
    ) (hashes.${cudaMajorVersion}.${stdenvNoCC.hostPlatform.system} or null);

  outputs = [
    "out"
    "static"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    tar -xzf "$src" -C "$out"

    mkdir -p "$static"
    moveToOutput "lib/libmathdx_static.a" "$static"

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  meta = {
    description = "Library used to integrate cuBLASDx and cuFFTDx into Warp";
    homepage = "https://developer.nvidia.com/cublasdx-downloads";

    license = with lib.licenses; [
      # By downloading and using the software, you agree to fully
      # comply with the terms and conditions of the NVIDIA Software
      # License Agreement.
      _cuda.lib.licenses.math_sdk_sla

      # Some of the libmathdx routines were written by or derived
      # from code written by Meta Platforms, Inc. and affiliates and
      # are subject to the BSD License.
      bsd3

      # Some of the libmathdx routines were written by or derived from
      # code written by Victor Zverovich and are subject to the following
      # license:
      mit
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ yzx9 ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
