{
  lib,
  stdenv,
  fetchFromGitHub,
  avrdude,
  binaryen,
  buildGo126Module,
  gdb,
  go_1_26,
  llvmPackages_20,
  makeWrapper,
  openocd,
  runCommand,
  xar,
  tinygoTests ? [ "smoketest" ],
}:

let
  # nixpkgs typically updates default llvm and go versions faster than tinygo releases
  # which ends up breaking this build. Use fixed versions for each release.
  buildGoModule = buildGo126Module;
  go = go_1_26;
  llvmMajor = lib.versions.major llvm.version;
  inherit (llvmPackages_20)
    llvm
    clang
    compiler-rt
    lld
    ;

  # only doing this because only on darwin placing clang.cc in nativeBuildInputs
  # doesn't build
  bootstrapTools = runCommand "tinygo-bootstrap-tools" { } ''
    mkdir -p $out
    ln -s ${lib.getBin clang.cc}/bin/clang $out/clang-${llvmMajor}
  '';
in

buildGoModule (finalAttrs: {
  inherit tinygoTests;
  pname = "tinygo";
  version = "0.41.1";

  src = fetchFromGitHub {
    owner = "tinygo-org";
    repo = "tinygo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Zpvhx+xgC/Cjdm3zSpntLKOT4HsBU7lPWdLumWeFyw=";
    fetchSubmodules = true;

    # The public hydra server on `hydra.nixos.org` is configured with
    # `max_output_size` of 3GB. The purpose of this `postFetch` step
    # is to stay below that limit and save 4.1GiB and 428MiB in output
    # size respectively. These folders are not referenced in tinygo.
    postFetch = ''
      rm -r $out/lib/cmsis-svd/data/{SiliconLabs,Freescale}
    '';
  };

  patches = [
    ./0001-GNUmakefile.patch
  ];

  postPatch = ''
    # Borrow compiler-rt builtins from our source
    # See https://github.com/tinygo-org/tinygo/pull/2471
    mkdir -p lib/compiler-rt-builtins
    cp -a ${compiler-rt.src}/compiler-rt/lib/builtins/* lib/compiler-rt-builtins/

    substituteInPlace GNUmakefile \
      --replace "build/release/tinygo/bin" "$out/bin" \
      --replace "build/release/" "$out/share/"
  '';

  nativeBuildInputs = [
    makeWrapper
    lld
  ];

  buildInputs = [
    llvm
    clang.cc
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ xar ];

  vendorHash = "sha256-OO8o/s71jZIypfYZCLT6jwUPyQJ89AKg3DfzTrbrD/A=";

  preBuild = ''
    export PATH=${bootstrapTools}:$PATH
    export HOME=$TMPDIR

    ldflags=("''$ldflags[@]/\"-buildid=\"")
  '';

  postBuild = ''
    # Move binary
    mkdir -p build
    mv $GOPATH/bin/tinygo build/tinygo

    make gen-device -j $NIX_BUILD_CORES

    export TINYGOROOT=$(pwd)
  '';

  doCheck = (stdenv.buildPlatform.canExecute stdenv.hostPlatform);
  nativeCheckInputs = [ binaryen ];

  checkPhase = lib.optionalString (tinygoTests != [ ] && tinygoTests != null) ''
    make ''${tinygoTests[@]} TINYGO="$(pwd)/build/tinygo" MD5SUM=md5sum XTENSA=0
  '';

  installPhase = ''
    runHook preInstall

    make build/release USE_SYSTEM_BINARYEN=1

    wrapProgram $out/bin/tinygo \
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps}

    runHook postInstall
  '';

  allowGoReference = true;

  ldflags = [
    "-X github.com/tinygo-org/tinygo/goenv.TINYGOROOT=${placeholder "out"}/share/tinygo"
    "-X github.com/tinygo-org/tinygo/goenv.clangResourceDir=${clang.cc.lib}/lib/clang/${llvmMajor}"
  ];

  # GDB upstream does not support ARM darwin
  runtimeDeps = [
    go
    clang.cc
    lld
    avrdude
    openocd
    binaryen
  ]
  ++ lib.optionals (!(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64)) [ gdb ];

  # Output contains static libraries for different arm cpus
  # and stripping could mess up these so only strip the compiler
  stripDebugList = [ "bin" ];
  subPackages = [ "." ];
  tags = [ "llvm${llvmMajor}" ];

  meta = {
    description = "Go compiler for small places";
    homepage = "https://tinygo.org/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      muscaln
    ];
  };
})
