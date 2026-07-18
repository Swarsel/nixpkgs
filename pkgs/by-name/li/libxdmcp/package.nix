{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libxdmcp";
  version = "1.1.5";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXdmcp-${finalAttrs.version}.tar.xz";
    hash = "sha256-2KUiKCjDratwrfaaVYPx0y617OBDBPf4OStqNTqiIow=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ xorgproto ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXdmcp \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Display Manager Control Protocol library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxdmcp";
    license = lib.licenses.mitOpenGroup;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xdmcp" ];
  };
})
