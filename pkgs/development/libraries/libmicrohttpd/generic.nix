{
  lib,
  stdenv,
  curl,
  gnutls,
  libgcrypt,
  libiconv,
  libintl,
  pkg-config,
  src,
  version,
  meta ? { },
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "libmicrohttpd";

  outputs = [
    "out"
    "dev"
    "devdoc"
    "info"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgcrypt
    curl
    gnutls
    libiconv
    libintl
  ];

  # Disabled because the tests can time-out.
  doCheck = false;

  preCheck = ''
    # Since `localhost' can't be resolved in a chroot, work around it.
    sed -i -e 's/localhost/127.0.0.1/g' src/test*/*.[ch]
  '';

  enableParallelBuilding = true;

  meta =

    {
      description = "Embeddable HTTP server library";

      longDescription = ''
        GNU libmicrohttpd is a small C library that is supposed to make
        it easy to run an HTTP server as part of another application.
      '';

      homepage = "https://www.gnu.org/software/libmicrohttpd/";
      license = lib.licenses.lgpl2Plus;
      maintainers = with lib.maintainers; [ fpletz ];
      platforms = lib.platforms.unix;
    }
    // meta;
})
