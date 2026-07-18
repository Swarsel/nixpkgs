{
  lib,
  stdenv,
  fetchurl,
  checksumType ? "built-in",
  libmhash ? null,
  openssl ? null,
}:

assert checksumType == "mhash" -> libmhash != null;
assert checksumType == "openssl" -> openssl != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "netrw";
  version = "1.3.2";

  src = fetchurl {
    sha256 = "1gnl80i5zkyj2lpnb4g0q0r5npba1x6cnafl2jb3i3pzlfz1bndr";

    urls = [
      "https://mamuti.net/files/netrw/netrw-${finalAttrs.version}.tar.bz2"
      "http://www.sourcefiles.org/Networking/FTP/Other/netrw-${finalAttrs.version}.tar.bz2"
    ];
  };

  buildInputs =
    lib.optional (checksumType == "mhash") libmhash ++ lib.optional (checksumType == "openssl") openssl;

  configureFlags = [
    # This is to add "#include" directives for stdlib.h, stdio.h and string.h.
    "ac_cv_header_stdc=yes"

    "--with-checksum=${checksumType}"
  ];

  meta = {
    description = "Simple tool for transporting data over the network";
    homepage = "https://mamuti.net/netrw/index.en.html";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
