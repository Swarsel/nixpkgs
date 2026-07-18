{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxau,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxext";
  version = "1.3.7";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXext-${finalAttrs.version}.tar.xz";
    hash = "sha256-bGQ8cDXNrPZ6/WjyXQG5DviJ1UbJ/NfArffCz5Hjoy0=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    xorgproto
  ];

  propagatedBuildInputs = [
    xorgproto
    libxau
  ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXext \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Xlib-based library for common extensions to the X11 protocol";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxext";

    license = with lib.licenses; [
      mitOpenGroup
      x11
      hpnd
      hpndSellVariant
      hpndDocSell
      hpndDoc
      mit
      isc
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xext" ];
  };
})
