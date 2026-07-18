{
  lib,
  stdenv,
  fetchFromGitHub,
  afflib,
  ant,
  autoreconfHook,
  fetchpatch,
  jdk,
  libewf,
  openssl,
  perl,
  stripJavaArchivesHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sleuthkit";
  version = "4.14.0"; # Note: when updating don't forget to also update the rdeps outputHash

  src = fetchFromGitHub {
    owner = "sleuthkit";
    repo = "sleuthkit";
    rev = "sleuthkit-${finalAttrs.version}";
    hash = "sha256-WvGVEDuhpmcyPOaihDruBbQbcj7s+Zkt2/D5CIsu0u8=";
  };

  patches = [
    # Fix build with gcc 15
    (fetchpatch {
      hash = "sha256-/mCal0EVTM2dM5ok3OmAXQ1HiaCUi0lmhavIuwxVEMA=";
      url = "https://github.com/sleuthkit/sleuthkit/commit/8d710c36a947a2666bbef689155831d76fff56b9.patch";
    })
    (fetchpatch {
      hash = "sha256-ZEeN0jp5cRi6dOpWlcGYm0nLLu5b56ivdR+WrhnhCz0=";
      url = "https://github.com/sleuthkit/sleuthkit/commit/f78bd37db6be72f8f4d444d124be4e26488dce4b.patch";
    })
  ];

  postPatch = ''
    substituteInPlace tsk/img/ewf.cpp --replace libewf_handle_read_random libewf_handle_read_buffer_at_offset
  '';

  nativeBuildInputs = [
    autoreconfHook
    ant
    jdk
    perl
    stripJavaArchivesHook
  ];

  buildInputs = [
    afflib
    libewf
    openssl
    zlib
  ];

  # Hack to fix the RPATH
  preFixup = ''
    rm -rf */.libs
  '';

  enableParallelBuilding = true;

  postUnpack = ''
    export IVY_HOME="$NIX_BUILD_TOP/.ant"
    export ANT_ARGS="-Doffline=true -Ddefault-jar-location=$IVY_HOME/lib"

    # pre-positioning these jar files allows -Doffline=true to work
    mkdir -p ${finalAttrs.src.name}/{bindings,case-uco}/java $IVY_HOME
    cp -r ${finalAttrs.rdeps}/bindings/java/lib ${finalAttrs.src.name}/bindings/java
    chmod -R 755 ${finalAttrs.src.name}/bindings/java
    cp -r ${finalAttrs.rdeps}/case-uco/java/lib ${finalAttrs.src.name}/case-uco/java
    chmod -R 755 ${finalAttrs.src.name}/case-uco/java
    cp -r ${finalAttrs.rdeps}/lib $IVY_HOME
    chmod -R 755 $IVY_HOME
  '';

  # Fetch libraries using a fixed output derivation
  rdeps = stdenv.mkDerivation {
    inherit (finalAttrs) src;

    nativeBuildInputs = [
      ant
      jdk
    ];

    buildPhase = ''
      export IVY_HOME=$NIX_BUILD_TOP/.ant
      pushd bindings/java
      ant retrieve-deps
      popd
      pushd case-uco/java
      ant get-ivy-dependencies
      popd
    '';

    installPhase = ''
      mkdir -m 755 -p $out/bindings/java
      cp -r bindings/java/lib $out/bindings/java
      mkdir -m 755 -p $out/case-uco/java
      cp -r case-uco/java/lib $out/case-uco/java
      cp -r $IVY_HOME/lib $out
      chmod -R 755 $out/lib
    '';

    # unpack, build, install
    dontConfigure = true;
    name = "sleuthkit-${finalAttrs.version}-deps";
    outputHash = "sha256-HfO8yWlL16NuXQ+NWIHwii69Vfb1vvSmNC3+6p0ALdg=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  meta = {
    description = "Forensic/data recovery tool";
    homepage = "https://www.sleuthkit.org/";
    changelog = "https://github.com/sleuthkit/sleuthkit/blob/${finalAttrs.src.rev}/NEWS.txt";
    license = lib.licenses.ipl10;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # dependencies
    ];

    maintainers = with lib.maintainers; [
      raskin
      gfrascadorio
    ];

    platforms = lib.platforms.unix;
  };
})
