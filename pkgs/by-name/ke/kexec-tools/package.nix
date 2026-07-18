{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fetchpatch,
  gitUpdater,
  nixosTests,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "kexec-tools";
  version = "2.0.32";

  src = fetchurl {
    sha256 = "sha256-j4FCKl/SNiz2ywAbUR5TVWXtDzLC9EUfteto/tZxCl0=";

    urls = [
      "mirror://kernel/linux/utils/kernel/kexec/${pname}-${version}.tar.xz"
      "http://horms.net/projects/kexec/kexec-tools/${pname}-${version}.tar.xz"
    ];
  };

  patches = [
  ]
  ++ lib.optionals (stdenv.hostPlatform.isPower64 && stdenv.hostPlatform.isAbiElfv2) [
    # Use ELFv2 ABI on ppc64be
    (fetchpatch {
      sha256 = "19wzfwb0azm932v0vhywv4221818qmlmvdfwpvvpfyw4hjsc2s1l";
      url = "https://raw.githubusercontent.com/void-linux/void-packages/6c1192cbf166698932030c2e3de71db1885a572d/srcpkgs/kexec-tools/patches/ppc64-elfv2.patch";
    })
  ]
  ++ lib.optional (stdenv.hostPlatform.useLLVM or false) ./fix-purgatory-llvm-libunwind.patch;

  buildInputs = [
    zlib
    zstd
  ];

  configureFlags = [ "BUILD_CC=${buildPackages.stdenv.cc.targetPrefix}cc" ];

  # Prevent kexec-tools from using uname to detect target, which is wrong in
  # cases like compiling for aarch32 on aarch64
  configurePlatforms = [
    "build"
    "host"
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  hardeningDisable = [
    "format"
    "pic"
    "relro"
  ];

  passthru = {
    tests.kexec = nixosTests.kexec;

    updateScript = gitUpdater {
      allowedVersions = "^([0-9]+\\.){2}[0-9]+$";
      rev-prefix = "v";
      url = "https://git.kernel.org/pub/scm/utils/kernel/kexec/kexec-tools.git";
    };
  };

  meta = {
    description = "Tools related to the kexec Linux feature";
    homepage = "http://horms.net/projects/kexec/kexec-tools";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;

    badPlatforms = [
      "microblaze-linux"
      "microblazeel-linux"
      "riscv64-linux"
      "riscv32-linux"
      "sparc-linux"
      "sparc64-linux"
      "powerpc-linux"
    ];

    mainProgram = "kexec";
  };
}
