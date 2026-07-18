{
  lib,
  stdenv,
  fetchurl,
  apr,
  aprutil,
  autoreconfHook,
  ldns,
  libical,
  nss,
  openssl,
  p11-kit,
  pkg-config,
  txt2man,
  unbound,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "redwax-tool";
  version = "1.0.0";

  src = fetchurl {
    url = "https://archive.redwax.eu/dist/rt/redwax-tool-${finalAttrs.version}/redwax-tool-${finalAttrs.version}.tar.gz";
    hash = "sha256-KIVr0FnCmZUuxenXCvAlLxQVQJ5XndAidVaiGevENoM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    txt2man
    which
  ];

  buildInputs = [
    openssl
    nss
    p11-kit
    libical
    ldns
    unbound
    apr
    aprutil
  ];

  configureFlags = [
    "--with-openssl"
    "--with-nss"
    "--with-p11-kit"
    "--with-libical"
    "--with-ldns"
    "--with-unbound"
    "--with-bash-completion-dir=yes"
  ];

  meta = {
    description = "Universal certificate conversion tool";

    longDescription = ''
      Read certificates and keys from your chosen sources, filter the
      certificates and keys you're interested in, write those
      certificates and keys to the destinations of your choice.
    '';

    homepage = "https://redwax.eu/rt/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ astro ];
    mainProgram = "redwax-tool";
  };
})
