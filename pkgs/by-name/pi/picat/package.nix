{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  zlib,
}:

stdenv.mkDerivation {
  pname = "picat";
  version = "3.9#4";

  src = fetchurl {
    url = "https://picat-lang.org/download/picat394_src.tar.gz";
    hash = "sha256-dAYiV2zG2Z01qBshsqORL9oR2NvNnRavvGSDaOEJdDk=";
  };

  patches = [
    # Fix build with GCC 15
    # https://github.com/picat-lang/Picat/pull/1
    (fetchpatch {
      hash = "sha256-21F35CVNgX4Zj0pK0zUyJaVpK0e399lQXD7vQf7GXgQ=";
      url = "https://github.com/picat-lang/Picat/commit/c50265dc565f1637e3d22c92b4bf9c4c79d57a03.patch";
    })
  ];

  buildInputs = [ zlib ];

  env.ARCH =
    {
      aarch64-darwin = "mac64";
      aarch64-linux = "linux64";
      x86_64-cygwin = "cygwin64";
      x86_64-linux = "linux64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  buildPhase = ''
    runHook preBuild

    cd emu
    make -j $NIX_BUILD_CORES -f Makefile.$ARCH

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp picat $out/bin/
    cp -r ../doc $out/share/doc
    cp -r ../exs $out/share/examples

    runHook postInstall
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Logic-based programming language";
    homepage = "http://picat-lang.org/";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      earldouglas
      thoughtpolice
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-cygwin"
      "aarch64-darwin"
    ];

    mainProgram = "picat";
  };
}
