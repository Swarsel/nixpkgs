{
  lib,
  fetchFromGitHub,
  bash,
  bashInteractive,
  bpftools,
  buildGoModule,
  clang,
  fd,
  glibc,
  gnutls,
  go-bindata,
  libpcap,
  llvmPackages,
  mariadb,
  nix-update-script,
  nspr,
  openssl,
  postgresql,
  zsh,
  kernel ? null,
  withNonBTF ? false,
}:

buildGoModule rec {
  pname = "ecapture";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "gojue";
    repo = "ecapture";
    tag = "v${version}";
    hash = "sha256-GWz+zlaP+kNF0G3hZJ2GJXusihGgEpxVdOlgAiHIH4s=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace user/config/config_gnutls_linux.go \
      --replace-fail 'return errors.New("cant found Gnutls so load path")' 'gc.Gnutls = "${lib.getLib gnutls}/lib/libgnutls.so.30"' \
      --replace-fail '"errors"' ' '

    substituteInPlace user/module/probe_bash.go \
      --replace-fail '/bin/bash' '${lib.getExe bashInteractive}'

    substituteInPlace user/config/config_bash.go \
      --replace-fail '/bin/bash' '${lib.getExe bashInteractive}'

    substituteInPlace user/config/config_nspr_linux.go \
      --replace-fail '/usr/lib/firefox/libnspr4.so' '${lib.getLib nspr}/lib/libnspr4.so'

    substituteInPlace user/config/config_zsh.go \
      --replace-fail '/bin/zsh' '${lib.getExe zsh}'

    substituteInPlace user/module/probe_zsh.go \
      --replace-fail '/bin/zsh' '${lib.getExe zsh}'

    substituteInPlace cli/cmd/postgres.go \
      --replace-fail '/usr/bin/postgres' '${postgresql}/bin/postgres'

    substituteInPlace cli/cmd/mysqld.go \
      --replace-fail '/usr/sbin/mariadbd' '${mariadb}/bin/mariadbd'

    substituteInPlace user/module/probe_mysqld.go \
      --replace-fail '/usr/sbin/mariadbd' '${mariadb}/bin/mariadbd'

    substituteInPlace user/config/config_openssl_linux.go \
      --replace-fail 'return errors.New("cant found openssl so load path")' 'oc.Openssl = "${lib.getLib openssl}/lib/libssl.so.3"' \
      --replace-fail '"errors"' ' '
  '';

  nativeBuildInputs = [
    llvmPackages.libllvm
    clang
    fd
    bpftools
    go-bindata
  ];

  buildInputs = [
    newlibpcap
    glibc.static
    glibc
  ];

  vendorHash = "sha256-esBALagv8J4UPYAzV2x3joF0MUxco4OHDFlL32yXe6E=";

  env.CGO_LDFLAGS = toString [
    "-lpcap"
    "-lpthread"
    "-static"
  ];

  postConfigure = ''
    sed -i '/git/d' Makefile
    sed -i '/git/d' variables.mk

    substituteInPlace Makefile \
      --replace-fail '/bin/bash' '${lib.getExe bash}'
  ''
  + lib.optionalString withNonBTF ''
    substituteInPlace variables.mk \
      --replace-fail "-emit-llvm" "-emit-llvm -I${kernel.dev}/lib/modules/${kernel.modDirVersion}/build/include -Wno-error=implicit-function-declaration"
    KERN_BUILD_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build KERN_SRC_PATH=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source make ebpf_noncore
  ''
  + ''
    make ebpf
    go-bindata -pkg assets -o "assets/ebpf_probe.go" $(find user/bytecode -name "*.o" -printf "./%p ")
  '';

  checkFlags =
    let
      skippedTests = [
        "TestCheckLatest"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  hardeningDisable = [
    "zerocallusedregs"
  ];

  ldflags = [
    "-extldflags '-static'"
    "-linkmode=external"
  ];

  newlibpcap = libpcap.overrideAttrs (previousAttrs: {
    configureFlags = previousAttrs.configureFlags ++ [ "--without-libnl" ];
  });

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Capture SSL/TLS text content without CA certificate Using eBPF";
    homepage = "https://ecapture.cc";
    changelog = "https://github.com/gojue/ecapture/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "ecapture";
  };
}
