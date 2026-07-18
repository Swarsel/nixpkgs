{
  lib,
  stdenv,
  fetchurl,
  libx11,
  meson,
  ninja,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxkbfile";
  version = "1.2.0";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libxkbfile-${finalAttrs.version}.tar.xz";
    hash = "sha256-f3GITl+vVvsOgj84SFmc+bWpr85RyQmCuutk9jUjPr8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    xorgproto
    libx11
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
    description = "XKB file handling routines";

    longDescription = ''
      libxkbfile is used by the X servers and utilities to parse the XKB configuration data files.
    '';

    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxkbfile";

    license = with lib.licenses; [
      hpnd
      mitOpenGroup
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xkbfile" ];
  };
})
