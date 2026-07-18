{
  lib,
  stdenv,
  # Free MASM-compatible assembler
  asmc-linux,
  fetchzip,
  # For tests
  testers,
  # Unfree Open-Watcom licensed assembler
  uasm,
  # RAR code is under non-free unRAR license
  # see the meta.license section below for more details
  enableUnfree ? false,
  useAsmc ? !useUasm && stdenv.hostPlatform.isx86 && stdenv.hostPlatform.isLinux,
  useUasm ?
    enableUnfree
    && stdenv.hostPlatform.isx86
    && (stdenv.hostPlatform.isLinux || stdenv.hostPlatform.isWindows),
}:

let
  makefile = "../../cmpl_${
    if stdenv.hostPlatform.isDarwin then
      "mac"
    else if stdenv.cc.isClang then
      "clang"
    else
      "gcc"
  }${
    if stdenv.hostPlatform.isx86_64 then
      "_x64"
    else if stdenv.hostPlatform.isAarch64 then
      "_arm64"
    else if stdenv.hostPlatform.isi686 then
      "_x86"
    else
      ""
  }.mak";
in
stdenv.mkDerivation (finalAttrs: {
  inherit makefile;
  pname = "7zz";
  version = "26.01";

  src = fetchzip {
    url = "https://7-zip.org/a/7z${lib.replaceStrings [ "." ] [ "" ] finalAttrs.version}-src.tar.xz";

    hash =
      {
        free = "sha256-52+Gg66MOFmwYUVB0OO4PAtZJtQOkoVpxV7F9xBGy58=";
        unfree = "sha256-w0fk8EDusUYiOfrmIiUq+xevlwfQxMhjdPzfkHkOkR8=";
      }
      .${if enableUnfree then "unfree" else "free"};

    # remove the unRAR related code from the src drv
    # > the license requires that you agree to these use restrictions,
    # > or you must remove the software (source and binary) from your hard disks
    # https://fedoraproject.org/wiki/Licensing:Unrar
    postFetch = lib.optionalString (!enableUnfree) ''
      rm -r $out/CPP/7zip/Compress/Rar*
    '';

    stripRoot = false;
  };

  outputs = [
    "out"
    "doc"
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isMinGW ''
    substituteInPlace CPP/7zip/7zip_gcc.mak C/7zip_gcc_c.mak \
      --replace-fail windres.exe ${stdenv.cc.targetPrefix}windres
  '';

  nativeBuildInputs = lib.optionals useAsmc [ asmc-linux ] ++ lib.optionals useUasm [ uasm ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ]
  ++ lib.optionals useAsmc [
    "MY_ASM=asmc"
  ]
  ++ lib.optionals useUasm [
    "MY_ASM=uasm"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isx86 && !useAsmc && !useUasm) [
    "USE_ASM="
  ]
  # it's the compression code with the restriction, see DOC/License.txt
  ++ lib.optionals (!enableUnfree) [ "DISABLE_RAR_COMPRESS=true" ]
  ++ lib.optionals (stdenv.hostPlatform.isMinGW) [
    "IS_MINGW=1"
    "MSYSTEM=1"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-Wno-deprecated-copy-dtor"
    ]
    ++ lib.optionals stdenv.hostPlatform.isMinGW [
      "-Wno-conversion"
      "-Wno-unused-macros"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-declaration-after-statement"
      (lib.optionals (lib.versionAtLeast (lib.getVersion stdenv.cc.cc) "13") [
        "-Wno-reserved-identifier"
        "-Wno-unused-but-set-variable"
      ])
      (lib.optionals (lib.versionAtLeast (lib.getVersion stdenv.cc.cc) "16") [
        "-Wno-unsafe-buffer-usage"
        "-Wno-cast-function-type-strict"
      ])
      # These three probably started to appear with clang 20 or 21:
      "-Wno-c++-keyword"
      "-Wno-implicit-void-ptr-cast"
      "-Wno-nrvo"
    ]
  );

  preBuild = "cd CPP/7zip/Bundles/Alone2";

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin b/*/7zz${stdenv.hostPlatform.extensions.executable}
    install -Dm444 -t $out/share/doc/7zz ../../../../DOC/*.txt

    runHook postInstall
  '';

  enableParallelBuilding = true;
  setupHook = ./setup-hook.sh;

  passthru = {
    tests.version = testers.testVersion {
      command = "7zz --help";
      package = finalAttrs.finalPackage;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Command line version of the 7-Zip archiver utility";
    homepage = "https://7-zip.org";

    license =
      with lib.licenses;
      # 7zip code is largely lgpl2Plus
      # CPP/7zip/Compress/LzfseDecoder.cpp is bsd3
      [
        lgpl2Plus # and
        bsd3
      ]
      ++
        # and CPP/7zip/Compress/Rar* are unfree with the unRAR license restriction
        # the unRAR compression code is disabled by default
        lib.optionals enableUnfree [ unfreeRedistributable ];

    maintainers = with lib.maintainers; [
      anna328p
      jk
      peterhoeg
    ];

    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "7zz";
  };
})
