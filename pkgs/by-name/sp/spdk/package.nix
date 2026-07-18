{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoconf,
  automake,
  cunit,
  dpdk,
  elfutils,
  ensureNewerSourcesForZipFilesHook,
  fuse3,
  jansson,
  libaio,
  libbsd,
  libnl,
  libpcap,
  libtool,
  libuuid,
  nasm,
  ncurses,
  numactl,
  openssl,
  pkg-config,
  python3,
  runtimeShell,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "spdk";
  version = "26.01";

  src = fetchFromGitHub {
    owner = "spdk";
    repo = "spdk";
    tag = "v${version}";
    hash = "sha256-E52VozjnoGnIC7viXrsualaaKXiUU9Fx8zGylTjBzX0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs .
    # Override uv pip install command to use hatchling directly without downloading dependencies
    substituteInPlace python/Makefile \
      --replace-fail "uv pip install --prefix=\$(CONFIG_PREFIX)" \
                     "python3 -m pip install --no-deps --no-build-isolation --prefix=\$(CONFIG_PREFIX)"
  '';

  nativeBuildInputs = [
    python3
    python3.pkgs.pip
    python3.pkgs.hatchling
    python3.pkgs.wheel
    python3.pkgs.wrapPython
    pkg-config
    ensureNewerSourcesForZipFilesHook
  ];

  buildInputs = [
    cunit
    dpdk
    fuse3
    jansson
    libaio
    libbsd
    elfutils
    libuuid
    libpcap
    libnl
    numactl
    openssl
    ncurses
    zlib
    zstd
    nasm
    autoconf
    automake
    libtool
  ];

  propagatedBuildInputs = [
    python3.pkgs.configshell-fb
  ];

  configureFlags = [
    "--with-dpdk=${dpdk}"
    "--with-crypto"
  ]
  ++ lib.optional (!stdenv.hostPlatform.isStatic) "--with-shared";

  env.NIX_CFLAGS_COMPILE = "-mssse3"; # Necessary to compile.

  # Required for the vendored isa-l version to find nasm
  preConfigure = ''
    export AS=nasm
  '';

  postCheck = ''
    python3 -m spdk
  '';

  # spdk does shenanigans with patchelf, so we need to stop them from messing with rpath
  preInstall = ''
    patchelf() { true; }
    export -f patchelf
  '';

  postInstall = ''
    unset patchelf

    # Clean up rpaths to remove /build references to the vendored isa-l and isa-l_crypto libs
    for f in $(find $out/lib $out/bin -executable -type f 2>/dev/null); do
      if patchelf --print-rpath "$f" 2>/dev/null | grep /build; then
        echo "Stripping rpath of $f"
        newrp=$(patchelf --print-rpath "$f" | sed -r "s|/build[^:]*:||g")
        patchelf --set-rpath "$newrp" "$f"
      fi
    done

    # SPDK scripts assume that they can read the includes also relative to the scripts.
    # Therefore we are not copying them into $out/share.
    mkdir $out/scripts
    cp  ./scripts/common.sh ./scripts/setup.sh $out/scripts
    cat > $out/bin/spdk-setup << EOF
    #!${runtimeShell}
    exec $out/scripts/setup.sh "\$@"
    EOF
    chmod +x  $out/bin/spdk-setup
  '';

  postFixup = ''
    wrapPythonPrograms
    ${lib.optionalString (!stdenv.hostPlatform.isStatic) ''
      # .pc files are not working properly with static linking and might just confuse other build systems
      rm $out/lib/*.a
    ''}
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Set of libraries for fast user-mode storage";
    homepage = "https://spdk.io/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ths-on ];
    platforms = [ "x86_64-linux" ];
  };
}
