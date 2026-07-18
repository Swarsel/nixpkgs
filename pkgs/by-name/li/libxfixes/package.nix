{
  lib,
  stdenv,
  fetchurl,
  libx11,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxfixes";
  version = "6.0.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXfixes-${finalAttrs.version}.tar.xz";
    hash = "sha256-OfEV1y2cX4ER5GhBZNPWjMH9Ifmyf/JAGwj938D0Cbo=";
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
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXfixes \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Xlib-based library for the XFIXES Extension";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxfixes";

    license = with lib.licenses; [
      hpndSellVariant
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xfixes" ];
  };
})
