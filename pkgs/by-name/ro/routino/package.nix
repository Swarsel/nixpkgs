{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  fetchpatch,
  perl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "routino";
  version = "3.4.3";

  src = fetchurl {
    url = "https://routino.org/download/routino-${finalAttrs.version}.tgz";
    hash = "sha256-TroGfTLJfKk4itbpfA9aPBDUiCk2ckDXjFE3XYzBHlQ=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    (fetchpatch {
      sha256 = "1b7hpa4sizansnwwxq1c031nxwdwh71pg08jl9z9apiab8pjsn53";
      url = "https://raw.githubusercontent.com/macports/macports-ports/18fd229516a46e7272003acbe555735b2a902db7/gis/routino/files/patch-Makefile_conf.diff";
    })
    (fetchpatch {
      sha256 = "1kigxcfr7977baxdsfvrw6q453cpqlzqakhj7av2agxkcvwyilpv";
      url = "https://raw.githubusercontent.com/macports/macports-ports/18fd229516a46e7272003acbe555735b2a902db7/gis/routino/files/patch-src_Makefile_dylib_extension.diff";
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile.conf \
      --subst-var-by PREFIX $out
  '';

  nativeBuildInputs = [ perl ];

  buildInputs = [
    zlib
    bzip2
  ];

  makeFlags = [ "prefix=$(out)" ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    CLANG = "1";
  };

  patchFlags = [ "-p0" ];

  meta = {
    description = "OpenStreetMap Routing Software";
    homepage = "http://www.routino.org/";
    changelog = "http://routino.org/software/NEWS.txt";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
