{
  lib,
  stdenv,
  fetchurl,
  libxcb,
  libxcb-image,
  libxcb-render-util,
  m4,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxcb-cursor";
  version = "0.1.6";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/xcb-util-cursor-${finalAttrs.version}.tar.xz";
    hash = "sha256-/euL0SeHNRm+XMcNzQ07XTO2Z4dyAPmSWln9ytj3qTM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    m4
  ];

  buildInputs = [
    libxcb
    libxcb-image
    libxcb-render-util
    xorgproto
  ];

  propagatedBuildInputs = [ libxcb ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname xcb-util-cursor \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "XCB port of libxcursor";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcb-cursor";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xcb-cursor" ];
  };
})
