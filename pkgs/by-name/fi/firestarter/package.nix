{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  cmake,
  fetchzip,
  git,
  glibc,
  glibc_multi,
  pkg-config,
  cudaPackages ? { },
  withCuda ? false,
}:

let
  inherit (cudaPackages) cudatoolkit;

  hwloc = stdenv.mkDerivation rec {
    pname = "hwloc";
    version = "2.2.0";

    src = fetchzip {
      url = "https://download.open-mpi.org/release/hwloc/v${lib.versions.majorMinor version}/hwloc-${version}.tar.gz";
      sha256 = "1ibw14h9ppg8z3mmkwys8vp699n85kymdz20smjd2iq9b67y80b6";
    };

    outputs = [
      "out"
      "lib"
      "dev"
      "doc"
      "man"
    ];

    nativeBuildInputs = [ pkg-config ];

    configureFlags = [
      "--enable-static"
      "--disable-libudev"
      "--disable-shared"
      "--disable-doxygen"
      "--disable-libxml2"
      "--disable-cairo"
      "--disable-io"
      "--disable-pci"
      "--disable-opencl"
      "--disable-cuda"
      "--disable-nvml"
      "--disable-gl"
      "--disable-libudev"
      "--disable-plugin-dlopen"
      "--disable-plugin-ltdl"
    ];

    enableParallelBuilding = true;
  };

in
stdenv.mkDerivation rec {
  pname = "firestarter";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "tud-zih-energy";
    repo = "FIRESTARTER";
    tag = "v${version}";
    sha256 = "1ik6j1lw5nldj4i3lllrywqg54m9i2vxkxsb2zr4q0d2rfywhn23";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace lib/nitro/CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 3.2)' 'cmake_minimum_required(VERSION 3.10)'
    substituteInPlace lib/json/CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 3.1)' 'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    cmake
    git
    pkg-config
  ]
  ++ lib.optionals withCuda [
    addDriverRunpath
  ];

  buildInputs = [
    hwloc
  ]
  ++ (
    if withCuda then
      [
        glibc_multi
        cudatoolkit
      ]
    else
      [ glibc.static ]
  );

  cmakeFlags = [
    "-DFIRESTARTER_BUILD_HWLOC=OFF"
    "-DCMAKE_C_COMPILER_WORKS=1"
    "-DCMAKE_CXX_COMPILER_WORKS=1"
  ]
  ++ lib.optionals withCuda [
    "-DFIRESTARTER_BUILD_TYPE=FIRESTARTER_CUDA"
  ];

  env = lib.optionalAttrs withCuda {
    NIX_LDFLAGS = "-L${cudatoolkit}/lib/stubs";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp src/FIRESTARTER${lib.optionalString withCuda "_CUDA"} $out/bin/
    runHook postInstall
  '';

  postFixup = lib.optionalString withCuda ''
    addDriverRunpath $out/bin/FIRESTARTER_CUDA
  '';

  meta = {
    description = "Processor Stress Test Utility";
    homepage = "https://tu-dresden.de/zih/forschung/projekte/firestarter";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      astro
      marenz
    ];

    platforms = lib.platforms.linux;
    mainProgram = "FIRESTARTER";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
}
