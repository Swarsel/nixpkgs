{
  lib,
  stdenv,
  fetchurl,
  libice,
  libuuid,
  pkg-config,
  testers,
  writeScript,
  xorgproto,
  xtrans,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libsm";
  version = "1.2.6";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libSM-${finalAttrs.version}.tar.xz";
    hash = "sha256-vnwKvbFcv9KaxiVzwcguh3+dQEetFTIefql9HkPYNb4=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libice
    libuuid
    xorgproto
    xtrans
  ];

  propagatedBuildInputs = [
    # needs to be propagated because of header file dependencies
    libice
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libSM \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "X Session Management Library";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libsm";

    license = with lib.licenses; [
      mit
      mitOpenGroup
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "sm" ];
  };
})
