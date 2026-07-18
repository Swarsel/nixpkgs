{
  lib,
  stdenv,
  fetchurl,
  darwin,
  testers,
  zlib,
  apngSupport ? true,
}:

assert zlib != null;

let
  patchVersion = "1.6.58";
  patch_src = fetchurl {
    hash = "sha256-7ufeoi7VAoaAF5cchsY8TtHmCF3guuv9zD0zIvAPPrA=";
    url = "mirror://sourceforge/libpng-apng/libpng-${patchVersion}-apng.patch.gz";
  };
  whenPatched = lib.optionalString apngSupport;

  # libpng is a dependency of xcbuild. Avoid an infinite recursion by using a bootstrap stdenv
  # that does not propagate xcrun.
  stdenv' = if stdenv.hostPlatform.isDarwin then darwin.bootstrapStdenv else stdenv;
in
stdenv'.mkDerivation (finalAttrs: {
  pname = "libpng" + whenPatched "-apng";
  version = "1.6.58";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${finalAttrs.version}.tar.xz";
    hash = "sha256-KOtAP1Hw90BSSRMs7P6C6lwO+X8bMsWmWCiBSuDTR3U=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  postPatch =
    whenPatched "gunzip < ${patch_src} | patch -Np1"
    + lib.optionalString stdenv.hostPlatform.isFreeBSD ''

      sed -i 1i'int feenableexcept(int __mask);' contrib/libtests/pngvalid.c
    '';

  propagatedBuildInputs = [ zlib ];
  doCheck = true;
  outputBin = "dev";

  passthru = {
    inherit zlib;
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description =
      "Official reference implementation for the PNG file format" + whenPatched " with animation patch";

    homepage = "http://www.libpng.org/pub/png/libpng.html";
    changelog = "https://github.com/pnggroup/libpng/blob/v${finalAttrs.version}/CHANGES";
    license = lib.licenses.libpng2;
    maintainers = with lib.maintainers; [ vcunat ];
    platforms = lib.platforms.all;

    pkgConfigModules = [
      "libpng"
      "libpng16"
    ];
  };
})
