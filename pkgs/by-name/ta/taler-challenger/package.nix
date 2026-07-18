{
  lib,
  stdenv,
  autoreconfHook,
  curl,
  fetchgit,
  gnunet,
  jansson,
  libgcrypt,
  libgnurl,
  libmicrohttpd,
  libpq,
  libsodium,
  libtool,
  pkg-config,
  runtimeShell,
  taler-exchange,
  taler-merchant,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taler-challenger";
  version = "1.3.0";

  src = fetchgit {
    url = "https://git-www.taler.net/challenger.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oomrqpA/V2sNTRzFbHS7rnZdTIs8w+SRYsa9AYDFn5o=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    libgcrypt
    pkg-config
    texinfo
  ];

  buildInputs = [
    curl
    gnunet
    jansson
    libgcrypt
    libgnurl
    libmicrohttpd
    libpq
    libsodium
    libtool
    taler-exchange
    taler-merchant
  ];

  preFixup = ''
    substituteInPlace $out/bin/challenger-{dbconfig,send-post.sh} \
      --replace-fail "/bin/bash" "${runtimeShell}"
  '';

  # https://git-www.taler.net/challenger.git/tree/bootstrap
  preAutoreconf = ''
    # Generate Makefile.am in contrib/
    pushd contrib
    rm -f Makefile.am
    find wallet-core/challenger/ -type f -printf '  %p \\\n' | sort > Makefile.am.ext
    # Remove extra '\' at the end of the file
    truncate -s -2 Makefile.am.ext
    cat Makefile.am.in Makefile.am.ext >> Makefile.am
    # Prevent accidental editing of the generated Makefile.am
    chmod -w Makefile.am
    popd
  '';

  meta = {
    description = "OAuth 2.0-based authentication service that validates user can receive messages at a certain address";
    homepage = "https://git-www.taler.net/challenger.git";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ ngi ];
  };
})
