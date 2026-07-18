{
  lib,
  stdenv,
  # "Configurable" options
  bqn-interpreter,
  callPackage,
  fixDarwinDylibNames,
  libffi,
  mbqn-source,
  pkg-config,
  enableLibcbqn ? ((stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isDarwin) && !enableReplxx),
  # Boolean flags
  enableReplxx ? false,
  generateBytecode ? false,
}:

let
  sources = callPackage ./sources.nix { };
in
stdenv.mkDerivation {
  inherit (sources.cbqn) version src;
  pname = "cbqn" + lib.optionalString (!generateBytecode) "-standalone";

  outputs = [
    "out"
  ]
  ++ lib.optionals enableLibcbqn [
    "lib"
    "dev"
  ];

  postPatch = ''
    sed -i '/SHELL =.*/ d' makefile
    patchShebangs build/build
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    libffi
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  buildFlags = [
    # interpreter binary
    "o3"
    "notui=1" # display build progress in a plain-text format
    "REPLXX=${if enableReplxx then "1" else "0"}"
    "version=${sources.cbqn.version}"
  ]
  ++ lib.optionals stdenv.hostPlatform.avx2Support [
    "has=avx2"
  ]
  ++ lib.optionals enableLibcbqn [
    # embeddable interpreter as a shared lib
    "shared-o3"
  ];

  preBuild = ''
    mkdir -p build/singeliLocal/
    cp -r ${sources.singeli.src}/* build/singeliLocal/
  ''
  + (
    if generateBytecode then
      ''
        mkdir -p build/bytecodeLocal/gen
        ${bqn-interpreter} ./build/genRuntime ${mbqn-source} build/bytecodeLocal/
      ''
    else
      ''
        mkdir -p build/bytecodeLocal/gen
        cp -r ${sources.cbqn-bytecode.src}/* build/bytecodeLocal/
      ''
  )
  + lib.optionalString enableReplxx ''
    mkdir -p build/replxxLocal/
    cp -r ${sources.replxx.src}/* build/replxxLocal/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/
    cp BQN -t $out/bin/
    # note guard condition for case-insensitive filesystems
    [ -e $out/bin/bqn ] || ln -s $out/bin/BQN $out/bin/bqn
    [ -e $out/bin/cbqn ] || ln -s $out/bin/BQN $out/bin/cbqn
  ''
  + lib.optionalString enableLibcbqn ''
    install -Dm644 include/bqnffi.h -t "$dev/include"
    install -Dm755 libcbqn${stdenv.hostPlatform.extensions.sharedLibrary} -t "$lib/lib"
  ''
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    # main test suite from mlochbaum/BQN
    $out/bin/BQN ${mbqn-source}/test/this.bqn

    # run tests in test/cases/
    $out/bin/BQN test/run.bqn lint

    runHook postInstallCheck
  '';

  dontConfigure = true;

  meta = {
    description = "BQN implementation in C";
    homepage = "https://github.com/dzaima/CBQN/";

    license = with lib.licenses; [
      # https://github.com/dzaima/CBQN?tab=readme-ov-file#licensing
      asl20
      boost
      gpl3Only
      lgpl3Only
      mit
      mpl20
    ];

    maintainers = with lib.maintainers; [
      detegr
      shnarazk
      sternenseemann
    ];

    platforms = lib.platforms.all;
    mainProgram = "cbqn";
  };
}
