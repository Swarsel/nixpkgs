{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxt,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxmu";
  version = "1.3.1";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXmu-${finalAttrs.version}.tar.xz";
    hash = "sha256-gamelMRQHoHEJ8uqShF0i1hJM+lLehVoMMNiElaFe8Q=";
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
    libxext
    libxt
  ];

  propagatedBuildInputs = [
    xorgproto
    libx11
    libxt
  ];

  buildFlags = [ "BITMAP_DEFINES='-DBITMAPDIR=\"/no-such-path\"'" ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXmu \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X miscellaneous utility routines library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxmu";

    license = with lib.licenses; [
      mitOpenGroup
      hpnd
      x11
      isc
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "xmu"
      "xmuu"
    ];
  };
})
