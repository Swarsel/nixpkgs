{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  config,
  cudaPackages,
  expat,
  libx11,
  ncurses,
  numactl,
  pciutils,
  pkg-config,
  enableCuda ? config.cudaSupport,
  x11Support ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hwloc";
  version = "2.14.0";

  src = fetchFromGitHub {
    owner = "open-mpi";
    repo = "hwloc";
    tag = "hwloc-${finalAttrs.version}";
    hash = "sha256-lbh8tkKeUcHta7/q9TuHQhccyWjkBgrC5fVifFJqQyY=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "doc"
    "man"
  ];

  # XXX: libx11 is not directly needed, but needed as a propagated dep of Cairo.
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ]
  ++ lib.optionals enableCuda [ cudaPackages.cuda_nvcc ];

  buildInputs = [
    expat
    ncurses
  ]
  ++ lib.optionals x11Support [
    cairo
    libx11
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ numactl ]
  ++ lib.optionals enableCuda [ cudaPackages.cuda_cudart ];

  # Since `libpci' appears in `hwloc.pc', it must be propagated.
  propagatedBuildInputs = lib.optional stdenv.hostPlatform.isLinux pciutils;

  configureFlags = [
    "--localstatedir=/var"
    "--enable-netloc"
  ];

  # Checks disabled because they're impure (hardware dependent) and
  # fail on some build machines.
  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    if [ -d "${numactl}/lib64" ]; then
      numalibdir="${numactl}/lib64"
    else
      numalibdir="${numactl}/lib"
      test -d "$numalibdir"
    fi

    sed -i "$lib/lib/libhwloc.la" \
      -e "s|-lnuma|-L$numalibdir -lnuma|g"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Portable abstraction of hierarchical architectures for high-performance computing";

    longDescription = ''
      hwloc provides a portable abstraction (across OS,
      versions, architectures, ...) of the hierarchical topology of
      modern architectures, including NUMA memory nodes, sockets,
      shared caches, cores and simultaneous multithreading.  It also
      gathers various attributes such as cache and memory
      information.  It primarily aims at helping high-performance
      computing applications with gathering information about the
      hardware so as to exploit it accordingly and efficiently.

      hwloc may display the topology in multiple convenient
      formats.  It also offers a powerful programming interface to
      gather information about the hardware, bind processes, and much
      more.
    '';

    homepage = "https://www.open-mpi.org/projects/hwloc/";
    # https://www.open-mpi.org/projects/hwloc/license.php
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      fpletz
      markuskowa
    ];

    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isCygwin;
  };
})
