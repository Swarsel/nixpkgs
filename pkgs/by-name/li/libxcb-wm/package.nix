{
  lib,
  stdenv,
  fetchurl,
  libxcb,
  m4,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxcb-wm";
  version = "0.4.2";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/xcb-util-wm-${finalAttrs.version}.tar.xz";
    hash = "sha256-YsNOIdBiZGh/rqftv2NjLJ8E1V5yEUqkpXu5Xk+Iigs=";
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
    xorgproto
  ];

  propagatedBuildInputs = [ libxcb ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname xcb-util-wm \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "XCB client and window-manager helpers for ICCCM & EWMH.";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcb-wm";
    license = lib.licenses.x11;
    maintainers = [ ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "xcb-ewmh"
      "xcb-icccm"
    ];
  };
})
