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
  pname = "libxau";
  version = "1.0.12";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/libXau-${finalAttrs.version}.tar.xz";
    hash = "sha256-dNDk36PTmtiTnpm9o39ZZ6ulKCEQdoKEZNJ3fUd/wPs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ xorgproto ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

    updateScript = writeScript "update-${finalAttrs.pname}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts
      version="$(list-directory-versions --pname libXau \
        --url https://xorg.freedesktop.org/releases/individual/lib/ \
        | sort -V | tail -n1)"
      update-source-version ${finalAttrs.pname} "$version"
    '';
  };

  meta = {
    description = "Functions for handling Xauthority files and entries.";
    homepage = "https://gitlab.freedesktop.org/xorg/lib/libxau";
    license = lib.licenses.mitOpenGroup;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "xau" ];
  };
})
