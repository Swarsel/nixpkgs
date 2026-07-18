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
  pname = "libxinerama";
  version = "1.1.6";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXinerama-${finalAttrs.version}.tar.xz";
    hash = "sha256-0A/BWZwwPcXLwSK4BovcdAXW/LGQYPRZf8Ub06i+Udc=";
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
    libxext
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
      version="$(list-directory-versions --pname libXinerama \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Library for Xinerama extension to X11 Protocol";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxinerama";

    license = with lib.licenses; [
      mit
      mitOpenGroup
      x11NoPermitPersons
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xinerama" ];
  };
})
