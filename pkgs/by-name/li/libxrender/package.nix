{
  lib,
  stdenv,
  fetchurl,
  libx11,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxrender";
  version = "0.9.12";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXrender-${finalAttrs.version}.tar.xz";
    hash = "sha256-uDISjaSLOcjWCCJEgXQ0A60Wkb9OVU5L6cF03xcdG5c=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    libx11
  ];

  propagatedBuildInputs = [
    xorgproto
    libx11
  ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXrender \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Xlib library for the Render Extension to the X11 protocol";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxrender";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xrender" ];
  };
})
