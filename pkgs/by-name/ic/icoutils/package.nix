{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  libpng,
  makeWrapper,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "icoutils";
  version = "0.32.3";

  src = fetchurl {
    url = "mirror://savannah/icoutils/icoutils-${finalAttrs.version}.tar.bz2";
    sha256 = "1q66cksms4l62y0wizb8vfavhmf7kyfgcfkynil3n99s0hny1aqp";
  };

  patches = [
    # Fixes a linker failure with newer versions of ld64 due to not supporting nested archives.
    (fetchpatch {
      hash = "sha256-4YCI+SYT2bCBNegkpN5jcfi6gOeec65TmCABr98HHB4=";
      url = "https://git.savannah.nongnu.org/cgit/icoutils.git/patch/?id=aa3572119bfe34484025f37dbbc4d5070f735908";
    })
    # Fix build with GCC 15 / C23.
    # https://savannah.nongnu.org/bugs/index.php?66812
    (fetchpatch {
      hash = "sha256-XQXhc1GkKhm4RJZPvkV8DYULziuBo0Dpt6hscM2Qcus=";
      url = "https://git.savannah.nongnu.org/cgit/icoutils.git/patch/?id=298da402990ebe1279fb82b63ae2dc66ad78fd36";
    })
  ];

  postPatch = ''
    patchShebangs extresso/extresso
    patchShebangs extresso/extresso.in
    patchShebangs extresso/genresscript
    patchShebangs extresso/genresscript.in
  '';

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
  ];

  buildInputs = [
    libpng
    perl
  ];

  propagatedBuildInputs = [ perlPackages.LWP ];

  preFixup = ''
    wrapProgram $out/bin/extresso --prefix PERL5LIB : $PERL5LIB
    wrapProgram $out/bin/genresscript --prefix PERL5LIB : $PERL5LIB
  '';

  meta = {
    description = "Set of programs to deal with Microsoft Windows(R) icon and cursor files";
    homepage = "https://www.nongnu.org/icoutils/";
    license = lib.licenses.gpl3Plus;
    platforms = with lib.platforms; linux ++ darwin;
  };
})
