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
  pname = "libice";
  version = "1.1.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libICE-${finalAttrs.version}.tar.xz";
    hash = "sha256-l05O1BQiXrPHFphd+XCfTajSKmeiiQBmvG38ia0phiU=";
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
    xtrans
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libICE \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Inter-Client Exchange Library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libice";
    license = lib.licenses.mitOpenGroup;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "ice" ];
  };
})
