{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
  xtrans,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libfs";
  version = "1.0.10";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libFS-${finalAttrs.version}.tar.xz";
    hash = "sha256-m6u9PIYGnJhWPaBEBF/cDs5OwMk9zdLGiqdOs0tPO3c=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    xorgproto
    xtrans
  ];

  configureFlags = lib.optional (
    stdenv.hostPlatform != stdenv.buildPlatform
  ) "--enable-malloc0returnsnull";

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libFS \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Font Service client library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libfs";

    license = with lib.licenses; [
      mitOpenGroup
      hpndSellVariant
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libfs" ];
  };
})
