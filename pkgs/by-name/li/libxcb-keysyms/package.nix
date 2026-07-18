{
  lib,
  stdenv,
  fetchurl,
  libxcb,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxcb-keysyms";
  version = "0.4.1";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/xcb-util-keysyms-${finalAttrs.version}.tar.xz";
    hash = "sha256-fCYKUpRBKu1CnfHaL4r9O9B7fLo/7HcvuhWmE6bVxjg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxcb
    xorgproto
  ];

  propagatedBuildInputs = [ libxcb ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname xcb-util-keysyms \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Standard X key constants and conversion to/from keycodes";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcb-keysyms";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xcb-keysyms" ];
  };
})
