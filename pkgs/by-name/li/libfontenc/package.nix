{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libfontenc";
  version = "1.1.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libfontenc-${finalAttrs.version}.tar.xz";
    hash = "sha256-nYOScFyxCAPV/h0n0jbLqz9mTiaEHOAZFru+Qwzyc+I=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    zlib
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname ${finalAttrs.pname} \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X font encoding library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libfontenc";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "fontenc" ];
  };
})
