{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  cppunit,
  fetchNpmDeps,
  fetchpatch,
  libcap,
  libpng,
  libreoffice-collabora,
  nodejs,
  npmHooks,
  pam,
  pango,
  pixman,
  pkg-config,
  poco,
  python3,
  rsync,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "collabora-online";
  version = "25.04.9-4";

  src = fetchFromGitHub {
    owner = "CollaboraOnline";
    repo = "online";
    tag = "cp-${finalAttrs.version}";
    hash = "sha256-+9dGNNduWq4+jxlVd49PDllIyI7vfYmFlly/t70eNtg=";
  };

  patches = [
    ./fix-file-server-regex.patch
  ];

  postPatch = ''
    cp ${./package-lock.json} ${finalAttrs.npmRoot}/package-lock.json

    patchShebangs browser/util/*.py coolwsd-systemplate-setup scripts/*
    substituteInPlace configure.ac --replace-fail '/usr/bin/env python3' python3
  '';

  nativeBuildInputs = [
    autoreconfHook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    python3
    python3.pkgs.lxml
    python3.pkgs.polib
    rsync
  ];

  buildInputs = [
    cairo
    cppunit
    libcap
    libpng
    pam
    pango
    pixman
    poco
    zstd
  ];

  configureFlags = [
    "--disable-setcap"
    "--disable-werror"
    "--enable-silent-rules"
    "--with-lo-path=${libreoffice-collabora}/lib/collaboraoffice"
    "--with-lokit-path=${libreoffice-collabora.src}/include"
  ];

  # Copy dummy self-signed certificates provided for testing.
  postInstall = ''
    cp etc/ca-chain.cert.pem etc/cert.pem etc/key.pem $out/etc/coolwsd
  '';

  enableParallelBuilding = true;

  npmDeps = fetchNpmDeps {
    # TODO: Use upstream `npm-shrinkwrap.json` once it's fixed
    # https://github.com/CollaboraOnline/online/issues/9644
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    hash = "sha256-c78C5yt/RH4jmjZpaBskV+1u4wTTVJoWjFqq6eNUVOA=";
    unpackPhase = "true";
  };

  npmRoot = "browser";

  passthru = {
    libreoffice = libreoffice-collabora; # Used by NixOS module.
  };

  meta = {
    description = "Collaborative online office suite based on LibreOffice technology";
    homepage = "https://www.collaboraonline.com";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.xzfc ];
    platforms = lib.platforms.linux;
  };
})
