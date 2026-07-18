{
  lib,
  stdenv,
  coreutils,
  makeWrapper,
  notmuch,
  perl,
  perlPackages,
}:

stdenv.mkDerivation {
  pname = "notmuch-mutt";
  version = notmuch.version;
  src = notmuch.src;
  outputs = [ "out" ];
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    perl
  ]
  ++ (with perlPackages; [
    FileRemove
    DigestSHA1
    Later
    MailBox
    MailMaildir
    MailTools
    StringShellQuote
    TermReadLineGnu
  ]);

  installPhase = ''
    ${coreutils}/bin/install -Dm755 \
      ./contrib/notmuch-mutt/notmuch-mutt \
      $out/bin/notmuch-mutt

    wrapProgram $out/bin/notmuch-mutt \
      --prefix PERL5LIB : $PERL5LIB
  '';

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  meta = {
    description = "Mutt support for notmuch";
    homepage = "https://notmuchmail.org/";
    license = with lib.licenses; gpl3;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
    mainProgram = "notmuch-mutt";
  };
}
