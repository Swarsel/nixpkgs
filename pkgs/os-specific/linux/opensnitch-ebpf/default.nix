{
  lib,
  stdenv,
  bc,
  bison,
  clang-tools,
  elfutils,
  fetchpatch2,
  flex,
  kernel,
  llvmPackages,
  nixosTests,
  opensnitch,
}:

stdenv.mkDerivation rec {
  inherit (opensnitch) src;
  pname = "opensnitch_ebpf";
  version = "${opensnitch.version}-${kernel.version}";

  patches = [
    (fetchpatch2 {
      hash = "sha256-FCJfDhgmnm1GXPDaxr+YpVWTRrwBvjVzvGdZSFB6SqQ=";
      # fixes build failures on kernel >= 6.19 (#490127)
      # remove when added to a release
      name = "fix-kernel-6.19-build.patch";
      stripLen = 1;
      url = "https://github.com/evilsocket/opensnitch/commit/614537c92ec82f54f76a45fb406ad2fb6e6fa618.patch?full_index=1";
    })
  ];

  nativeBuildInputs = with llvmPackages; [
    bc
    bison
    clang
    clang-tools
    elfutils
    flex
    libllvm
  ];

  env.KERNEL_DIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/source";
  env.KERNEL_HEADERS = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.KERNEL_VER = kernel.modDirVersion;
  # We set -fno-stack-protector here to work around a clang regression.
  # This is fine - bpf programs do not use stack protectors
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=opensnitch-ebpf-module&id=984b952a784eb701f691dd9f2d45dfeb8d15053b
  env.NIX_CFLAGS_COMPILE = "-fno-stack-protector";

  installPhase = ''
    runHook preInstall

    for file in opensnitch*.o; do
      install -Dm644 "$file" "$out/etc/opensnitchd/$file"
    done

    runHook postInstall
  '';

  postFixup = ''
    # reduces closure size significantly (fixes https://github.com/NixOS/nixpkgs/issues/391351)
    for file in $out/etc/opensnitchd/*.o; do
      llvm-strip --strip-debug $file
    done
  '';

  extraConfig = ''
    CONFIG_UPROBE_EVENTS=y
  '';

  sourceRoot = "${src.name}/ebpf_prog";

  passthru.tests = {
    inherit (nixosTests) opensnitch;
  };

  meta = {
    description = "eBPF process monitor module for OpenSnitch";
    homepage = "https://github.com/evilsocket/opensnitch";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      onny
      grimmauld
    ];

    platforms = lib.platforms.linux;
  };
}
