{
  lib,
  stdenv,
  fetchurl,
  flex,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wcslib";
  version = "8.9";

  src = fetchurl {
    url = "ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-${finalAttrs.version}.tar.bz2";
    hash = "sha256-gqwJzlCRsL8Gzsj1ze7B2r4dBrpd+3/yvbDBaASIgHs=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ flex ];
  # error: call to undeclared library function 'snprintf'
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-include stdio.h";

  # DOCDIR is set to the path $out/share/doc/wcslib, and DOCLINK points
  # to the same location.
  # `$(LN_S) $(notdir $(DOCDIR)) $(DOCLINK)` effectively running:
  # `ln -s wcslib $out/share/doc/wcslib`
  # This produces a broken link because the target location already exists
  postInstall = ''
    rm $out/share/doc/wcslib/wcslib
  '';

  enableParallelBuilding = true;

  meta = {
    description = "World Coordinate System library for astronomy";

    longDescription = ''
      Library for world coordinate systems for spherical geometries
      and their conversion to image coordinate systems. This is the
      standard library for this purpose in astronomy.
    '';

    homepage = "https://www.atnf.csiro.au/people/mcalabre/WCS/";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      returntoreality
    ];

    platforms = lib.platforms.unix;
  };
})
