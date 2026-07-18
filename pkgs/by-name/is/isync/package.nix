{
  lib,
  stdenv,
  autoreconfHook,
  cyrus-sasl-xoauth2,
  cyrus_sasl,
  db,
  fetchgit,
  makeWrapper,
  openssl,
  perl,
  pkg-config,
  zlib,
  # Disabled by default as XOAUTH2 is an "OBSOLETE" SASL mechanism and this relies
  # on a package that isn't really maintained anymore:
  withCyrusSaslXoauth2 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "isync";
  version = "1.5.1";

  src = fetchgit {
    url = "https://git.code.sf.net/p/isync/isync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l0jL4CzAdFtQGekbywic1Kuihy3ZQi4ozhSEcbJI0t0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    perl
  ]
  ++ lib.optionals withCyrusSaslXoauth2 [ makeWrapper ];

  buildInputs = [
    openssl
    db
    cyrus_sasl
    zlib
  ];

  # Fixes "Fatal: buffer too small" error
  # see https://sourceforge.net/p/isync/mailman/isync-devel/thread/87fsevvebj.fsf%40steelpick.2x.cz/
  env.NIX_CFLAGS_COMPILE = "-DQPRINTF_BUFF=4000";
  doCheck = true;

  postInstall = lib.optionalString withCyrusSaslXoauth2 ''
    wrapProgram "$out/bin/mbsync" \
        --prefix SASL_PATH : "${
          lib.makeSearchPath "lib/sasl2" [
            cyrus-sasl-xoauth2
            cyrus_sasl.out
          ]
        }"
  '';

  autoreconfPhase = ''
    echo "${finalAttrs.version}" > VERSION
    ./autogen.sh
  '';

  meta = {
    description = "Free IMAP and MailDir mailbox synchronizer";

    longDescription = ''
      mbsync (formerly isync) is a command line application which synchronizes
      mailboxes. Currently Maildir and IMAP4 mailboxes are supported. New
      messages, message deletions and flag changes can be propagated both ways.
    '';

    homepage = "https://isync.sourceforge.io";
    changelog = "https://sourceforge.net/p/isync/isync/ci/v${finalAttrs.version}/tree/NEWS";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Necoro
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mbsync";
  };
})
