{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxfixes,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxdamage";
  version = "1.1.7";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXdamage-${finalAttrs.version}.tar.xz";
    hash = "sha256-EnBn9SHT7kZ7l7yxRa66EHjiRU1EjodI65hNWzl73iQ=";
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
    libxfixes
  ];

  propagatedBuildInputs = [ xorgproto ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXdamage \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Damage Extension library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxdamage";
    license = lib.licenses.hpndSellVariant;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xdamage" ];
  };
})
