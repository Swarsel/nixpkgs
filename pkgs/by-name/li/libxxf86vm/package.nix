{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxxf86vm";
  version = "1.1.7";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXxf86vm-${finalAttrs.version}.tar.xz";
    hash = "sha256-rlDA9mngr1pnzEzQ9U8h1kpk0mYK+IPoDpXT/lG5Rdg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXxf86vm \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Extension library for the XFree86-VidMode X extension";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxxf86vm";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xxf86vm" ];
  };
})
