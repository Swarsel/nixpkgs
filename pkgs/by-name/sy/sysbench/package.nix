{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf269,
  autoreconfHook,
  libaio,
  libmysqlclient,
  luajit,
  pkg-config,
  sysbench,
  # For testing:
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sysbench";
  version = "1.0.20";

  src = fetchFromGitHub {
    owner = "akopytov";
    repo = "sysbench";
    rev = finalAttrs.version;
    sha256 = "1sanvl2a52ff4shj62nw395zzgdgywplqvwip74ky8q7s6qjf5qy";
  };

  # We cannot use the regular nixpkgs ck here, since it has very
  # different performance characteristics than the vendored one.
  # On the downside the vendored libck version require more fixes for cross-compilation.
  # Sysbench related on statically linked vendored libck.
  postPatch = ''
    substituteInPlace \
      third_party/concurrency_kit/ck/configure \
        --replace-fail \
          'COMPILER=`./.1 2> /dev/null`' \
          "COMPILER=${
            if stdenv.cc.isGNU then
              "gcc"
            else if stdenv.cc.isClang then
              "clang"
            else
              throw "Unsupported compiler"
          }" \
        --replace-fail \
          'PLATFORM=`uname -m 2> /dev/null`' \
          "PLATFORM=${stdenv.hostPlatform.parsed.cpu.name}"
    substituteInPlace \
      third_party/concurrency_kit/ck/src/Makefile.in \
        --replace-fail \
          "ar rcs" \
          "${stdenv.cc.targetPrefix}ar rcs"
  '';

  # Build fails with autoconf 2.73
  nativeBuildInputs = [
    autoconf269
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libmysqlclient
    luajit
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libaio ];

  configureFlags = [
    # The bundled version does not build on aarch64-darwin:
    # https://github.com/akopytov/sysbench/issues/416
    "--with-system-luajit"
    "--with-mysql-includes=${lib.getDev libmysqlclient}/include/mysql"
    "--with-mysql-libs=${libmysqlclient}/lib/mysql"
  ];

  depsBuildBuild = [ pkg-config ];
  enableParallelBuilding = true;

  passthru.tests = {
    versionTest = testers.testVersion {
      package = sysbench;
    };
  };

  meta = {
    description = "Modular, cross-platform and multi-threaded benchmark tool";

    longDescription = ''
      sysbench is a scriptable multi-threaded benchmark tool based on LuaJIT.
      It is most frequently used for database benchmarks, but can also be used
      to create arbitrarily complex workloads that do not involve a database
      server.
    '';

    homepage = "https://github.com/akopytov/sysbench";
    changelog = "https://github.com/akopytov/sysbench/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "sysbench";
    downloadPage = "https://github.com/akopytov/sysbench/releases/tag/${finalAttrs.version}";
  };
})
