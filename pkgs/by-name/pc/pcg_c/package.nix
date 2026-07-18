{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pcg-c";
  version = "0.94";

  src = fetchzip {
    url = "https://www.pcg-random.org/downloads/pcg-c-${finalAttrs.version}.zip";
    sha256 = "0smm811xbvs03a5nc2668zd0178wnyri2h023pqffy767bpy1vlv";
  };

  patches = [
    ./prefix-variable.patch
  ];

  preInstall = ''
    sed -i s,/usr/local,$out, Makefile
    mkdir -p $out/lib $out/include
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Family of better random number generators";

    longDescription = ''
      PCG is a family of simple fast space-efficient statistically good
      algorithms for random number generation. Unlike many general-purpose RNGs,
      they are also hard to predict.
    '';

    homepage = "https://www.pcg-random.org/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.linus ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isi686; # https://github.com/imneme/pcg-c/issues/11
  };
})
