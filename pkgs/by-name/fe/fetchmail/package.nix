{
  lib,
  stdenv,
  fetchurl,
  openssl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fetchmail";
  version = "6.6.6";

  src = fetchurl {
    url = "mirror://sourceforge/fetchmail/fetchmail-${finalAttrs.version}.tar.xz";
    hash = "sha256-2pn4xXPE2eY/STx+JERxJq6iW1O0wHbseSZodOKbGXU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    python3
  ];

  configureFlags = [ "--with-ssl=${openssl.dev}" ];

  meta = {
    description = "Full-featured remote-mail retrieval and forwarding utility";

    longDescription = ''
      A full-featured, robust, well-documented remote-mail retrieval and
      forwarding utility intended to be used over on-demand TCP/IP links
      (such as SLIP or PPP connections). It supports every remote-mail
      protocol now in use on the Internet: POP2, POP3, RPOP, APOP, KPOP,
      all flavors of IMAP, ETRN, and ODMR. It can even support IPv6 and
      IPSEC.
    '';

    homepage = "https://www.fetchmail.info/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "fetchmail";
  };
})
