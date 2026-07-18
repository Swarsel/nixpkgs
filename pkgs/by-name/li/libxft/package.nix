{
  lib,
  stdenv,
  fetchurl,
  fontconfig,
  freetype,
  libx11,
  libxrender,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxft";
  version = "2.3.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXft-${finalAttrs.version}.tar.xz";
    hash = "sha256-YKJbeJRe1pMmNbO7GJmlF9Md90VuaYZ/+6J/if85dvU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
    libx11
    libxrender
    xorgproto
  ];

  propagatedBuildInputs = [
    xorgproto
    # header file dependencies
    freetype
    fontconfig
    libxrender
  ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXft \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X FreeType library";

    longDescription = ''
      libxft is the client side font rendering library, using libfreetype, libx11, and the
      X Render extension to display anti-aliased text.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxft";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xft" ];
  };
})
