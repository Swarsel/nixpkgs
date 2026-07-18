{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  c-ares,
  cppunit,
  gnutls,
  libssh2,
  libxml2,
  nixosTests,
  pkg-config,
  sphinx,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aria2";
  version = "1.37.0";

  src = fetchFromGitHub {
    owner = "aria2";
    repo = "aria2";
    rev = "release-${finalAttrs.version}";
    sha256 = "sha256-xbiNSg/Z+CA0x0DQfMNsWdA+TATyX6dCeW2Nf3L3Kfs=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "doc"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    sphinx
  ];

  buildInputs = [
    gnutls
    c-ares
    libxml2
    sqlite
    zlib
    libssh2
  ];

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
    "--enable-libaria2"
    "--with-bashcompletiondir=${placeholder "bin"}/share/bash-completion/completions"
  ];

  doCheck = false; # needs the net
  nativeCheckInputs = [ cppunit ];
  enableParallelBuilding = true;

  prePatch = ''
    patchShebangs --build doc/manual-src/en/mkapiref.py
  '';

  passthru.tests = {
    aria2 = nixosTests.aria2;
  };

  meta = {
    description = "Lightweight, multi-protocol, multi-source, command-line download utility";
    homepage = "https://aria2.github.io";
    changelog = "https://github.com/aria2/aria2/releases/tag/release-${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      koral
      timhae
    ];

    platforms = lib.platforms.unix;
    mainProgram = "aria2c";
  };
})
