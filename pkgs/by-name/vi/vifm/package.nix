{
  lib ? null,
  stdenv,
  fetchurl,
  file,
  gitUpdater,
  groff,
  libx11,
  makeWrapper,
  ncurses,
  perl, # used to generate help tags
  pkg-config,
  which,
  # adds support for handling removable media (vifm-media). Linux only!
  mediaSupport ? false,
  python3 ? null,
  udisks ? null,
}:

let
  isFullPackage = mediaSupport;
in
stdenv.mkDerivation (finalAttrs: {
  pname = if isFullPackage then "vifm-full" else "vifm";
  version = "0.14.4";

  src = fetchurl {
    url = "https://github.com/vifm/vifm/releases/download/v${finalAttrs.version}/vifm-${finalAttrs.version}.tar.bz2";
    hash = "sha256-QLwy7BDYKa2j0Cl9M81PMCxSC7QxKH1UT8CgWuRf2xs=";
  };

  postPatch = ''
    # Avoid '#!/usr/bin/env perl' references to build help.
    patchShebangs --build src/helpztags
  '';

  nativeBuildInputs = [
    perl
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    ncurses
    libx11
    file
    which
    groff
  ];

  postFixup =
    let
      path = lib.makeBinPath [
        udisks
        (python3.withPackages (p: [ p.dbus-python ]))
      ];

      wrapVifmMedia = "wrapProgram $out/share/vifm/vifm-media --prefix PATH : ${path}";
    in
    ''
      ${lib.optionalString mediaSupport wrapVifmMedia}
    '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    ignoredVersions = "beta";
    rev-prefix = "v";
    url = "https://github.com/vifm/vifm.git";
  };

  meta = {
    description = "Vi-like file manager${lib.optionalString isFullPackage "; Includes support for optional features"}";
    homepage = "https://vifm.info/";
    changelog = "https://github.com/vifm/vifm/blob/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = if mediaSupport then lib.platforms.linux else lib.platforms.unix;
    mainProgram = "vifm";
    downloadPage = "https://vifm.info/downloads.shtml";
  };
})
