{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxfixes,
  libxrender,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxcursor";
  version = "1.2.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXcursor-${finalAttrs.version}.tar.xz";
    hash = "sha256-/elALdTP552nHi2Wu5gK/F5v9Pin10wVnhlmr7KywsA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    libx11
    libxfixes
    libxrender
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXcursor \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X11 Cursor management library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcursor";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xcursor" ];
  };
})
