{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  linenoise,
  sqlite,
  cliSupport ? true,
  enableLTO ? stdenv.cc.isGNU,
  httpSupport ? true,
  linenoiseSupport ? cliSupport,
}:

assert enableLTO -> stdenv.cc.isGNU;

stdenv.mkDerivation (finalAttrs: {
  pname = "dictu";
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "dictu-lang";
    repo = "dictu";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Tahi2K8Q/KPc9MN7yWhkqp/MzXfzJzrGSsvnTCyI03U=";
  };

  patches = [
    ./0001-force-sqlite-to-be-found.patch
  ];

  postPatch = lib.optionalString (!enableLTO) ''
    sed -i src/CMakeLists.txt \
        -e 's/-flto/${lib.optionalString stdenv.cc.isGNU "-Wno-error=format-truncation"}/'
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    sqlite
  ]
  ++ lib.optional httpSupport curl
  ++ lib.optional linenoiseSupport linenoise;

  cmakeFlags = [
    "-DBUILD_CLI=${if cliSupport then "ON" else "OFF"}"
    "-DDISABLE_HTTP=${if httpSupport then "OFF" else "ON"}"
    "-DDISABLE_LINENOISE=${if linenoiseSupport then "OFF" else "ON"}"
  ]
  ++ lib.optionals enableLTO [
    # TODO: LTO with LLVM
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
  ];

  # bcrypt magic value triggers gcc 15 -Wunterminated-string-initialization.
  env.NIX_CFLAGS_COMPILE = "-Wno-error=unterminated-string-initialization";

  postBuild = ''
    cd .. # move out of cmakeBuildDir
  '';

  doCheck = cliSupport;

  preCheck = ''
    sed -i tests/runTests.du \
        -e '/http/d'
    sed -i tests/path/realpath.du \
        -e 's/usr/build/g'
    sed -i tests/path/isDir.du \
        -e "s,/usr/bin,$PWD," \
        -e '/home/d'
  '';

  checkPhase = ''
    runHook preCheck
    ./dictu tests/runTests.du
  '';

  installPhase = ''
    mkdir -p $out
    cp -r src/include $out/include
    mkdir -p $out/lib
    cp build/src/libdictu_api* $out/lib
  ''
  + lib.optionalString cliSupport ''
    install -Dm755 dictu $out/bin/dictu
  '';

  meta = {
    description = "High-level dynamically typed, multi-paradigm, interpreted programming language";
    homepage = "https://dictu-lang.com";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "dictu";
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/staging-next/dictu.x86_64-darwin
  };
})
