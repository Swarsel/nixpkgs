{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xml_dtd_412,
  docbook_xsl,
  fetchpatch,
  libassuan,
  libiconv,
  libxslt,
  libxt,
  nix-update-script,
  openssl,
  pcsclite,
  pkg-config,
  readline,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opensc";
  version = "0.27.1";

  src = fetchFromGitHub {
    owner = "OpenSC";
    repo = "OpenSC";
    tag = finalAttrs.version;
    hash = "sha256-s/3bIhPGa3+SKjMh0CNgsU3nOkhEaxPTpmEbc6VIn3Q=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-S8PeXCRAUlkKUPYOl/n5+4QIqWOZtHX3yEDnpFhJO8k=";
      name = "CVE-2026-10275.patch";
      url = "https://github.com/OpenSC/OpenSC/commit/814f745b3b6d100295f65f1935edd33d520d33ab.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    libxslt # xsltproc
  ];

  buildInputs = [
    zlib
    readline
    openssl
    libassuan
    libxt
    libiconv
    docbook_xml_dtd_412
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin) pcsclite;

  configureFlags = [
    "--enable-zlib"
    "--enable-readline"
    "--enable-openssl"
    "--enable-pcsc"
    "--enable-sm"
    "--enable-man"
    "--enable-doc"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-xsl-stylesheetsdir=${docbook_xsl}/xml/xsl/docbook"
  ]
  ++
    lib.optional (!stdenv.hostPlatform.isDarwin)
      "--with-pcsc-provider=${lib.getLib pcsclite}/lib/libpcsclite${stdenv.hostPlatform.extensions.sharedLibrary}";

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  installFlags = [
    "sysconfdir=$(out)/etc"
    "completiondir=$(out)/etc"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=^([0-9\\.]+)$" ]; };

  meta = {
    description = "Set of libraries and utilities to access smart cards";
    homepage = "https://github.com/OpenSC/OpenSC/wiki";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.michaeladler ];
    platforms = lib.platforms.all;
  };
})
