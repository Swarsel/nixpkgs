{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxfixes,
  libxrandr,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxpresent";
  version = "1.0.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXpresent-${finalAttrs.version}.tar.xz";
    hash = "sha256-TlshtIEiBqSyIwE2Bq4xFwUCwQQwOHd6Hvj3DAnTdgI=";
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
    libxfixes
    libxrandr
  ];

  propagatedBuildInputs = [
    xorgproto
    # header includes dependencies
    libxfixes
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXpresent \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "library for the X Present Extension";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxpresent";

    license = with lib.licenses; [
      hpndSellVariant
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xpresent" ];
  };
})
