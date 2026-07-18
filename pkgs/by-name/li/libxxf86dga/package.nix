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
  pname = "libxxf86dga";
  version = "1.1.7";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXxf86dga-${finalAttrs.version}.tar.xz";
    hash = "sha256-s75bRE0yTLbg9LUBmklyyZ6jNsy4q3lo7M7+zZF//eY=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  propagatedBuildInputs = [ xorgproto ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXxf86dga \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Client library for the XFree86-DGA extension";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxxf86dga";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xxf86dga" ];
  };
})
