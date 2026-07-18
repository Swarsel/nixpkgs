{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  libpng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pngtoico";
  version = "1.0";

  src = fetchurl {
    url = "mirror://kernel/software/graphics/pngtoico/pngtoico-${finalAttrs.version}.tar.gz";
    sha256 = "1xb4aa57sjvgqfp01br3dm72hf7q0gb2ad144s1ifrs09215fgph";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-MeRV4FL37Wq7aFRnjbxPokcBKmPM+h94cnFJmdvHAt0=";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/media-gfx/pngtoico/files/pngtoico-1.0.1-libpng15.patch?id=dec60bb6900d6ebdaaa6aa1dcb845b30b739f9b5";
    })
  ];

  buildInputs = [ libpng ];

  configurePhase = ''
    runHook preConfigure

    sed -i s,/usr/local,$out, Makefile

    runHook postConfigure
  '';

  meta = {
    description = "Small utility to convert a set of PNG images to Microsoft ICO format";
    homepage = "https://www.kernel.org/pub/software/graphics/pngtoico/";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; linux;
    mainProgram = "pngtoico";
  };
})
