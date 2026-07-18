{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gzip,
  libx11,
  libxext,
  libxt,
  ncompress,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxpm";
  version = "3.5.19";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXpm-${finalAttrs.version}.tar.xz";
    hash = "sha256-rTV21okiGjncco8ODcAsp7tqDXJMmnf9G/oemvg76QA=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    gettext
  ];

  buildInputs = [
    xorgproto
    libx11
    libxext
    libxt
  ];

  propagatedBuildInputs = [
    libx11
  ];

  env = {
    XPM_PATH_COMPRESS = lib.makeBinPath [ ncompress ];
    XPM_PATH_GZIP = lib.makeBinPath [ gzip ];
    XPM_PATH_UNCOMPRESS = lib.makeBinPath [ gzip ];
  };

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXpm \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Pixmap (XPM) image file format library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxpm";

    license = with lib.licenses; [
      x11
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "sxpm";
    pkgConfigModules = [ "xpm" ];
  };
})
