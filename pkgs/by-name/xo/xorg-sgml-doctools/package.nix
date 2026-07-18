{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  testers,
  writeScript,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xorg-sgml-doctools";
  version = "1.12.1";

  src = fetchurl {
    url = "mirror://xorg/individual/doc/xorg-sgml-doctools-${finalAttrs.version}.tar.xz";
    hash = "sha256-Cl1UwHBrTonVrNTUVds3RatK0mvmJ8zgFbkK1AO1bW8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname ${finalAttrs.pname} \
        --url https://xorg.freedesktop.org/releases/individual/doc \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "SGML entities and XML/CSS stylesheets used in X.Org docs";
    homepage = "https://gitlab.freedesktop.org/xorg/doc/xorg-sgml-doctools";

    license = with lib.licenses; [
      mit
      hpndSellVariant
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xorg-sgml-doctools" ];
  };
})
