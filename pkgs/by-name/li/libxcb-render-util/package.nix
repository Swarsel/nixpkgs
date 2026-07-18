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
  pname = "libxcb-render-util";
  version = "0.3.10";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/xcb-util-renderutil-${finalAttrs.version}.tar.xz";
    hash = "sha256-PhXU8OItjdv7ufXXfbQ+rNejBAKb8lphZsxjyqltBLo=";
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
      version="$(list-directory-versions --pname xcb-util-renderutil \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "XCB convenience functions for the Render extension";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxcb-render-util";

    license = with lib.licenses; [
      hpndSellVariant
      x11
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xcb-renderutil" ];
  };
})
