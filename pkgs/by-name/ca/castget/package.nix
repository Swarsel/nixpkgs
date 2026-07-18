{
  lib,
  stdenv,
  fetchFromGitHub,
  # native
  autoreconfHook,
  # host
  curl,
  glib,
  glibcLocales,
  id3lib,
  libxml2,
  pkg-config,
  taglib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "castget";
  # Using unstable version since it doesn't require `ronn`, see:
  # https://github.com/mlj/castget/commit/218734296e2efc53071e0dbd3c4d59930b571aae
  version = "2.0.1-unstable-2026-02-04";

  src = fetchFromGitHub {
    owner = "mlj";
    repo = "castget";
    rev = "218734296e2efc53071e0dbd3c4d59930b571aae";
    hash = "sha256-GEfsGOTBkorPWLGP3eNbuiGFwDUgb4Gu6ykyS3/RNOg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    # See comment on locale above
    glibcLocales
    pkg-config
  ];

  buildInputs = [
    curl
    glib
    id3lib
    libxml2
    taglib
  ];

  # without this, the build fails because of an encoding issue with the manual page.
  # https://stackoverflow.com/a/17031697/4935114
  # This requires glibcLocales to be present in the build so it will have an impact.
  # See https://github.com/NixOS/nixpkgs/issues/8398
  preBuild = ''
    export LC_ALL="en_US.UTF-8";
  '';

  meta = {
    description = "Simple, command-line based RSS enclosure downloader";

    longDescription = ''
      castget is a simple, command-line based RSS enclosure downloader. It is
      primarily intended for automatic, unattended downloading of podcasts.
    '';

    homepage = "https://castget.johndal.com/";
    changelog = "https://github.com/mlj/castget/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
    mainProgram = "castget";
  };
})
