{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mailcheck";
  version = "1.91.2";

  src = fetchurl {
    url = "mirror://sourceforge/mailcheck/mailcheck_${finalAttrs.version}.tar.gz";
    sha256 = "0p0azaxsnjvjbg41ycicc1i0kzw6jiynq8k49cfkdhlckxfdm9kc";
  };

  patches = [ ./mailcheck-Makefile.patch ];

  meta = {
    description = "Simple command line tool to check for new messages";

    longDescription = ''
      A simple command line tool to check for new mail in local mbox and
      maildir and remote POP3 and IMAP mailboxes.
    '';

    homepage = "https://mailcheck.sourceforge.net/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ kovirobi ];
    platforms = lib.platforms.linux;
    mainProgram = "mailcheck";
  };
})
