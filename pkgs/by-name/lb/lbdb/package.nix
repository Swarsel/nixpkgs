{
  lib,
  stdenv,
  fetchurl,
  abook,
  bsd-finger,
  gnupg,
  goobook,
  khard,
  mu,
  perl,
  withAbook ? true,
  withGnupg ? true,
  withGoobook ? true,
  withKhard ? true,
  withMu ? true,
}:

let
  perl' = perl.withPackages (
    p: with p; [
      AuthenSASL
      ConvertASN1
      IOSocketSSL
      perlldap
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lbdb";
  version = "0.57";

  src = fetchurl {
    url = "https://www.spinnaker.de/lbdb/download/lbdb-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-IS/i5A317T5Ulrxegh5LBoOmyVI7iIXn6HtjS8+SOog=";
  };

  patches = [
    ./add-methods-to-rc.patch
  ];

  buildInputs = [
    perl'
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) bsd-finger
  ++ lib.optional withAbook abook
  ++ lib.optional withGnupg gnupg
  ++ lib.optional withGoobook goobook
  ++ lib.optional withKhard khard
  ++ lib.optional withMu mu;

  configureFlags =
    [ ]
    ++ lib.optional withAbook "--with-abook"
    ++ lib.optional withGnupg "--with-gpg"
    ++ lib.optional withGoobook "--with-goobook"
    ++ lib.optional withKhard "--with-khard"
    ++ lib.optional withMu "--with-mu";

  meta = {
    description = "Little Brother's Database";
    homepage = "https://www.spinnaker.de/lbdb/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      kaiha
      bfortz
    ];

    platforms = lib.platforms.all;
  };
})
