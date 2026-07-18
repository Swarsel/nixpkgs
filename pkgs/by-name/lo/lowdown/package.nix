{
  lib,
  stdenv,
  fetchurl,
  bmake,
  dieHook,
  fixDarwinDylibNames,
  lix,
  lowdown-unsandboxed,
  # for passthru.tests
  nix,
  which,
  enableDarwinSandbox ? true,
  enableShared ? !stdenv.hostPlatform.isStatic,
  enableStatic ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation rec {
  pname = "lowdown${
    lib.optionalString (stdenv.hostPlatform.isDarwin && !enableDarwinSandbox) "-unsandboxed"
  }";

  version = "3.0.1";

  src = fetchurl {
    url = "https://kristaps.bsd.lv/lowdown/snapshots/lowdown-${version}.tar.gz";
    sha512 = "fe68e1b7ff23f3992398356d7aa9a330dfd7b72e22bea9a91eeef74182b209ecea0c9f3e2b2216e1a07b2358da2b746238ec9cbbdeebdd3551cef14dd2d79f46";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  # https://github.com/kristapsdz/lowdown/pull/171
  patches = [ ./fix-cygwin-build.patch ];

  nativeBuildInputs = [
    which
    dieHook
    bmake # Uses FreeBSD's dialect
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];

  makeFlags = [
    "bins" # prevents shared object from being built unnecessarily
  ]
  ++ lib.optionals stdenv.hostPlatform.isCygwin [
    "EXESUFFIX=.exe"
    "LINKER_SOSUFFIX=dll"
    "LIB_SO=cyglowdown.dll"
    "IMPLIB=liblowdown.dll.a"
    "LDFLAGS=-Wl,--out-implib,liblowdown.dll.a"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isCygwin "-D_GNU_SOURCE";
  # Fix rpath change on darwin to avoid failure like:
  #     error: install_name_tool: changing install names or
  #     rpaths can't be redone for: liblowdown.1.dylib (for architecture
  #     arm64) because larger
  #   https://github.com/NixOS/nixpkgs/pull/344532#issuecomment-238475791
  env.NIX_CFLAGS_LINK = lib.optionalString stdenv.hostPlatform.isDarwin "-headerpad_max_install_names";

  # The Darwin sandbox calls fail inside Nix builds, presumably due to
  # being nested inside another sandbox.
  preConfigure = lib.optionalString (stdenv.hostPlatform.isDarwin && !enableDarwinSandbox) ''
    echo 'HAVE_SANDBOX_INIT=0' > configure.local
  '';

  doCheck = !stdenv.hostPlatform.isDarwin || !enableDarwinSandbox;

  postInstall = lib.optionalString stdenv.hostPlatform.isCygwin ''
    mkdir -p "$lib"/bin
    mv "$lib"/lib/*.dll "$lib"/bin/
    chmod +x "$lib"/bin/*.dll
  '';

  doInstallCheck = !stdenv.hostPlatform.isDarwin || !enableDarwinSandbox;

  installCheckPhase = ''
    runHook preInstallCheck

    echo '# TEST' > test.md
    $out/bin/lowdown test.md | grep '[hH]1'

    runHook postInstallCheck
  '';

  checkTarget = "regress";

  configurePhase = ''
    runHook preConfigure
    ./configure PREFIX=''${!outputDev} \
                BINDIR=''${!outputBin}/bin \
                LIBDIR=''${!outputLib}/lib \
                MANDIR=''${!outputMan}/share/man
    runHook postConfigure
  '';

  installTargets = [
    "install"
  ]
  ++ lib.optionals enableShared [
    "install_shared"
  ]
  ++ lib.optionals enableStatic [
    "install_static"
  ];

  passthru.tests = {
    # most important consumers in nixpkgs
    inherit nix lix lowdown-unsandboxed;
  };

  meta = {
    description = "Simple markdown translator";
    homepage = "https://kristaps.bsd.lv/lowdown/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
  };
}
