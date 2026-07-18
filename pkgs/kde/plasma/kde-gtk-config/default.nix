{
  lib,
  gsettings-desktop-schemas,
  mkKdeDerivation,
  pkg-config,
  procps,
  qtsvg,
  replaceVars,
  sass,
  wrapGAppsHook3,
  xsettingsd,
}:
mkKdeDerivation {
  pname = "kde-gtk-config";

  # The gtkconfig KDED module will crash the daemon if the GSettings schemas
  # aren't found.
  patches = [
    ./0001-gsettings-schemas-path.patch
    (replaceVars ./dependency-paths.patch {
      pgrep = lib.getExe' procps "pgrep";
      xsettingsd = lib.getExe xsettingsd;
    })
  ];

  preConfigure = ''
    NIX_CFLAGS_COMPILE+=" -DGSETTINGS_SCHEMAS_PATH=\"$GSETTINGS_SCHEMAS_PATH\""
  '';

  # Hardcoded as QStrings, which are UTF-16 so Nix can't pick these up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${procps} ${xsettingsd}" > $out/nix-support/depends
  '';

  dontWrapGApps = true; # There is nothing to wrap
  extraBuildInputs = [ qtsvg ];
  extraCmakeFlags = [ "-DGLIB_SCHEMAS_DIR=${gsettings-desktop-schemas.out}/" ];

  extraNativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    sass
  ];
}
