{
  lib,
  stdenv,
  fetchurl,
  bzip2,
  fetchpatch,
}:

let
  major = "1.1";
  version = "${major}.13";
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "pbzip2";

  src = fetchurl {
    url = "https://launchpad.net/pbzip2/${major}/${finalAttrs.version}/+download/pbzip2-${finalAttrs.version}.tar.gz";
    sha256 = "1rnvgcdixjzbrmcr1nv9b6ccrjfrhryaj7jwz28yxxv6lam3xlcg";
  };

  patches = [
    # https://libcxx.llvm.org/ReleaseNotes/19.html#deprecations-and-removals
    # https://bugs.launchpad.net/pbzip2/+bug/2081588
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-dvXdp+5S41akavy+mvPGHpUxHxenXS7bbTVBVkIJj0s=";
      url = "https://github.com/freebsd/freebsd-ports/raw/974d3ff054965d2bd2ab884a0579ed06c5a08b07/archivers/pbzip2/files/patch-BZ2StreamScanner.cpp";
    })
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-/twP8HyHP4cAVgb5cUPq0CgDxUgDYPdd9haH9wDOrz8=";
      url = "https://github.com/freebsd/freebsd-ports/raw/974d3ff054965d2bd2ab884a0579ed06c5a08b07/archivers/pbzip2/files/patch-BZ2StreamScanner.h";
    })
  ];

  postPatch = ''
    substituteInPlace pbzip2.cpp \
      --replace-fail '"PRIuMAX"' '" PRIuMAX "'
  '';

  buildInputs = [ bzip2 ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Parallel implementation of bzip2 for multi-core machines";
    homepage = "http://compression.ca/pbzip2/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
