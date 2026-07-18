{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cctools,
  darwin,
  libffi,
  libiconv,
  libx11,
  lz4,
  ncurses,
  testers,
  writableTmpDirAsHomeHook,
  zlib,
  zuo,
}:
let
  inherit (stdenv.hostPlatform) extensions;

  arch =
    {
      "aarch64-darwin" = "tarm64osx";
      "aarch64-linux" = "tarm64le";
      "aarch64-windows" = "tarm64nt";
      "x86-linux" = "ti3le";
      "x86_64-linux" = "ta6le";
      "x86_64-windows" = "ta6nt";
    }
    .${stdenv.hostPlatform.system}
      or (throw "Unsupported host system, try checking https://cisco.github.io/ChezScheme/release_notes/latest/release_notes.html to see if ${stdenv.hostPlatform.system} is supported");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chez-scheme";
  version = "10.4.1";

  src = fetchFromGitHub {
    owner = "cisco";
    repo = "ChezScheme";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7b7I+g4h05BRI2lLAlwlIBw5KxKAai1lU8TESACaSYg=";
    # Vendored nanopass and stex
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
      darwin.autoSignDarwinBinariesHook
    ];

  buildInputs = [
    ncurses
    libiconv
    zlib
    lz4
    libffi
  ]
  ++ lib.optionals stdenv.hostPlatform.isUnix [
    libx11
  ];

  configureFlags = [
    # Skip submodule update
    "--as-is"
    # Threaded version
    "--threads"
    "--installprefix=${placeholder "out"}"
    "--installman=${placeholder "out"}/share/man"
    "--installabsolute"
    "--enable-libffi"
    "CC_FOR_BUILD=${lib.getExe buildPackages.stdenv.cc}"
    # Use Nixpkgs dependencies
    "ZUO=zuo"
    "ZLIB=${zlib}/lib/libz${extensions.sharedLibrary}"
    "LZ4=${lz4.lib}/lib/liblz4${extensions.sharedLibrary}"
    # Append to CFLAGS or else get errors
    # Don't set CFLAGS so it can do some detections stuff
    "CFLAGS+=${lib.optionalString stdenv.cc.isGNU "-Wno-error=format-truncation"}"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "--cross"
    "-m=${arch}"
  ];

  doCheck = false; # Filesystem checks are impure
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  # ** Clean up some of the examples from the build output.
  postInstall = ''
    rm -rf $out/lib/csv${finalAttrs.version}/examples
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    echo "(exit)" | "$out/bin/scheme"
  '';

  configurePlatforms = [ ]; # So it doesn't add the default --build --host flags

  depsBuildBuild = [
    zuo # Used as the build driver
  ];

  dontAddPrefix = true;
  /*
    ** Set to use Nixpkgs dependencies when possible
    ** instead of vendored dependencies.
    **
    ** Carefully set a manual workarea argument, so that we
    ** can later easily find the machine type that we built Chez
    ** for.
  */
  enableParallelBuilding = true;
  enableParallelChecking = true;
  setupHook = ./setup-hook.sh;

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Powerful and incredibly fast R6RS Scheme compiler";
    homepage = "https://cisco.github.io/ChezScheme/";
    changelog = "https://cisco.github.io/ChezScheme/release_notes/v${finalAttrs.version}/release_notes.html";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      thoughtpolice
      RossSmyth
    ];

    platforms = lib.platforms.all;
    mainProgram = "scheme";
  };
})
