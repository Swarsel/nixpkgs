{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  cairo,
  cppunit,
  fetchNpmDeps,
  kdePackages,
  libcap,
  libpng,
  libreoffice-collabora,
  nodejs,
  npmHooks,
  pam,
  pango,
  perl,
  pixman,
  pkg-config,
  poco,
  python3,
  rsync,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "collabora-desktop";
  version = "25.04.9.2-2";

  src = fetchFromGitHub {
    owner = "CollaboraOnline";
    repo = "online";
    tag = "coda-${finalAttrs.version}";
    hash = "sha256-5SKtZvdtYoAsTlEseGsW+ndnD45bjTga3FPpDEldaRY=";
  };

  patches = [
    # permissions fix for templates
    ./0001-template-copy-permissions-fix.patch
  ];

  postPatch = ''
    cp ${./package-lock.json} ${finalAttrs.env.npmRoot}/package-lock.json

    patchShebangs browser/util/*.py coolwsd-systemplate-setup scripts/*
    substituteInPlace configure.ac --replace-fail '/usr/bin/env python3' python3

    # workaround for QtWebEngine crash when loading 'cell' cursor
    substituteInPlace browser/css/spreadsheet.css \
      --replace-warn "cursor: cell" "cursor: crosshair"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    perl
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    python3
    python3.pkgs.lxml
    python3.pkgs.polib
    rsync

    # from CollaboraOnline/nix-build-support
    (stdenv.mkDerivation {
      src = kdePackages.qtbase;

      buildPhase = ''
        mkdir -p $out
        ln -s ${kdePackages.qtbase}/libexec $out/bin
      '';

      name = "qtlibexec";
    })
    kdePackages.qttools
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtwebengine

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
    "--enable-qtapp"
    "--disable-werror"
    "--enable-silent-rules"
    "--with-lo-path=${finalAttrs.passthru.libreoffice}/lib/collaboraoffice"
    "--with-lokit-path=${finalAttrs.passthru.libreoffice.src}/include"
    "--enable-silent-rules"
    "--disable-ssl"
    "--with-info-url=https://collaboraoffice.com/"
  ];

  env = {
    npmDeps = fetchNpmDeps {
      # TODO: Use upstream `npm-shrinkwrap.json` once it's fixed
      # https://github.com/CollaboraOnline/online/issues/9644
      postPatch = ''
        cp ${./package-lock.json} package-lock.json
      '';

      hash = "sha256-03ycmv27icEASJZCUSz8OqEAOr9MVgEKkfHN4ddbQNg=";
      unpackPhase = "true";
    };

    npmRoot = "browser";
  };

  # handle flags with spaces safely
  preConfigure = ''
    configureFlagsArray+=(
      "--with-vendor=Collabora Productivity Limited"
      "--with-app-name=Collabora Office"
    )
  '';

  postInstall = ''
    cp --no-preserve=mode ${finalAttrs.passthru.libreoffice}/lib/collaboraoffice/LICENSE.html $out/LICENSE.html
    python3 scripts/insert-coda-license.py $out/LICENSE.html CODA-THIRDPARTYLICENSES.html
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  passthru = {
    libreoffice = libreoffice-collabora.override {
      variant = "collabora-coda";
      withFonts = true;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Collaborative Office for desktop, based on LibreOffice technology";
    homepage = "https://www.collaboraonline.com/collabora-office/";
    changelog = "https://www.collaboraonline.com/blog/";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "coda-qt";
    teams = [ lib.teams.ngi ];
  };
})
