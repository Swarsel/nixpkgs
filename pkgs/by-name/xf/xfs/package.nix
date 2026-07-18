{
  lib,
  stdenv,
  fetchurl,
  libxfont_2,
  pkg-config,
  writeScript,
  xorgproto,
  xtrans,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xfs";
  version = "1.2.2";

  src = fetchurl {
    url = "mirror://xorg/individual/app/xfs-${finalAttrs.version}.tar.xz";
    hash = "sha256-twvUYzHiQbMOXgDb3C6rt/P4iAzUQkSs3hPXl20Jjsw=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxfont_2
    xorgproto
    xtrans
  ];

  passthru = {
    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname ${finalAttrs.pname} \
        --url https://xorg.freedesktop.org/releases/individual/app/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Font Server, for X11 core protocol fonts";
    homepage = "https://gitlab.freedesktop.org/xorg/app/xfs";

    license = with lib.licenses; [
      mitOpenGroup
      hpndSellVariant
      x11
      hpnd
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xfs";
    broken = stdenv.hostPlatform.isStatic;
  };
})
