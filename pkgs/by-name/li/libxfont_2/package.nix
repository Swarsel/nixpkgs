{
  lib,
  stdenv,
  fetchurl,
  freetype,
  libfontenc,
  # for inheriting the meta attributes
  libxfont_1,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
  xtrans,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxfont_2";
  version = "2.0.7";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXfont2-${finalAttrs.version}.tar.xz";
    hash = "sha256-i3uC/eukh2m2lDPo4/u5hKX2vzaLDV9Hq+7EnePljvs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libfontenc
    xorgproto
    freetype
    xtrans
    zlib
  ];

  propagatedBuildInputs = [ xorgproto ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXfont2 \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    inherit (libxfont_1.meta) description homepage license;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xfont2" ];
  };
})
