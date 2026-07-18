{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  perl,
  zlib,
}:

stdenv.mkDerivation rec {
  src = fetchurl {
    url = "${meta.homepage}${name}.tar.gz";
    hash = "sha256-cxD11YdA0h1tIVwReWWGAu99qXqBa8FJfIdkvpeqvqM=";
  };

  patches = [ ./remove-shared-library-checks.patch ];
  postPatch = "patchShebangs .";
  strictDeps = true;

  nativeBuildInputs = [
    perl
    zlib
  ];

  buildInputs = [
    perl
    zlib
  ];

  env.PERL_USE_UNSAFE_INC = "1";

  preBuild = lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
    make CC='${buildPackages.stdenv.cc}/bin/cc -I${lib.getDev buildPackages.zlib}/include -L${buildPackages.zlib}/lib' find_sizes
    mv find_sizes find_sizes_build
    make clean

    substituteInPlace Makefile --replace "./find_sizes" "./find_sizes_build"
    substituteInPlace Makefile --replace "ar cr" "${lib.getBin stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}ar cr"
    substituteInPlace Makefile --replace "ranlib" "${lib.getBin stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}ranlib"
    substituteInPlace Makefile --replace "STRIP=strip" "STRIP=${lib.getBin stdenv.cc.bintools.bintools}/bin/${stdenv.cc.targetPrefix}strip"
  '';

  postInstall = ''
    patchShebangs --update $out/bin/multispell
  '';

  __structuredAttrs = true;
  name = "${passthru.pname}-${passthru.version}";

  passthru = {
    pname = "hspell";
    version = "1.4";
  };

  meta = {
    description = "Hebrew spell checker";
    homepage = "http://hspell.ivrix.org.il/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.all;
  };
}
