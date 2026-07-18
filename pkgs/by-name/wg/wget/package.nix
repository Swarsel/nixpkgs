{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
  libiconv,
  libidn2,
  libintl,
  libpsl,
  libuuid,
  lzip,
  nukeReferences,
  openssl,
  pcre2,
  perlPackages,
  pkg-config,
  python3,
  zlib,
  withLibpsl ? false,
  withOpenssl ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wget";
  version = "1.25.0";

  src = fetchurl {
    url = "mirror://gnu/wget/wget-${finalAttrs.version}.tar.lz";
    hash = "sha256-GSJcx1awoIj8gRSNxqQKDI8ymvf9hIPxx7L+UPTgih8=";
  };

  outputs = [
    "out"
    "man"
    "info"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-ZnCLK9ILpHMqpmI39sBl3Q3NRNc/H8jukvBrECqJ6OI=";
      name = "fix-cve-2026-58471";
      url = "https://gitlab.com/gnuwget/wget/-/commit/c2640fe5171c59f87c58dc9fcb195b2d18b010ee.patch";
    })
    (fetchpatch {
      hash = "sha256-aR5lW8t6ME2Os/NPXjFaUbNr3QuiUSQKsa2Zk292mrk=";
      name = "fix-cve-2026-58470";
      url = "https://gitlab.com/gnuwget/wget/-/commit/43d3ba9336bc94937e6fae2365c6ffd30c34ffcf.patch";
    })
    (fetchpatch {
      hash = "sha256-lkHQufl8XFZ1Ig8EoRUw3JuCgDPQod9PKAIsTBWzvm4=";
      name = "fix-cve-2026-58469";
      url = "https://gitlab.com/gnuwget/wget/-/commit/37a40fcb450153f69537c7cbc2a7a4fb0b6f7826.patch";
    })
    (fetchpatch {
      hash = "sha256-FAlglKTZili9Y4ivSRLOEaOgektFmq4u6yyH+8WzQao=";
      name = "fix-cve-2026-58472";
      url = "https://gitlab.com/gnuwget/wget/-/commit/dd692d9cea5335b181d877ae917fe6e75587a812.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    pkg-config
    perlPackages.perl
    lzip
    nukeReferences
  ];

  buildInputs = [
    libidn2
    zlib
    pcre2
    libuuid
    libiconv
    libintl
  ]
  ++ lib.optional withOpenssl openssl
  ++ lib.optional withLibpsl libpsl
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    perlPackages.perl
  ];

  configureFlags = [
    (lib.withFeatureAs withOpenssl "ssl" "openssl")
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # https://lists.gnu.org/archive/html/bug-wget/2021-01/msg00076.html
    "--without-included-regex"
  ];

  preConfigure = ''
    patchShebangs doc
  '';

  preBuild = ''
    # avoid runtime references to build-only depends
    make -C src version.c
    nuke-refs src/version.c
  '';

  doCheck = true;

  nativeCheckInputs = [
    perlPackages.HTTPDaemon
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    perlPackages.IOSocketSSL
  ];

  preCheck = ''
    patchShebangs tests fuzz

    # Work around lack of DNS resolution in chroots.
    for i in "tests/"*.pm "tests/"*.px
    do
      sed -i "$i" -e's/localhost/127.0.0.1/g'
    done
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # depending on the underlying filesystem, some tests
    # creating exotic file names fail
    for f in tests/Test-ftp-iri.px \
      tests/Test-ftp-iri-fallback.px \
      tests/Test-ftp-iri-recursive.px \
      tests/Test-ftp-iri-disabled.px \
      tests/Test-iri-disabled.px \
      tests/Test-iri-list.px ;
    do
      # just return magic "skip" exit code 77
      sed -i 's/^exit/exit 77 #/' $f
    done
  '';

  __darwinAllowLocalNetworking = true;
  enableParallelBuilding = true;

  meta = {
    description = "Tool for retrieving files using HTTP, HTTPS, and FTP";

    longDescription = ''
      GNU Wget is a free software package for retrieving files using HTTP,
      HTTPS and FTP, the most widely-used Internet protocols.  It is a
      non-interactive commandline tool, so it may easily be called from
      scripts, cron jobs, terminals without X-Windows support, etc.
    '';

    homepage = "https://www.gnu.org/software/wget/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.all;
    mainProgram = "wget";
  };
})
