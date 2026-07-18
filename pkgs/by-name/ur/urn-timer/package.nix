{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  imagemagick,
  jansson,
  nixosTests,
  pkg-config,
  unstableGitUpdater,
  wrapGAppsHook3,
  xxd,
}:

stdenv.mkDerivation {
  pname = "urn-timer";
  version = "0-unstable-2026-01-18";

  src = fetchFromGitHub {
    owner = "paoloose";
    repo = "urn";
    rev = "e1c96fff0ee9763d35b0370deb4cbbbf805acdba";
    hash = "sha256-Iwne0R8qxrk7hvpUUD98cFwr+Izfw7dAqd0HFtwJ2KU=";
  };

  nativeBuildInputs = [
    xxd
    pkg-config
    imagemagick
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    jansson
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  passthru.tests.nixosTest = nixosTests.urn-timer;

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/paoloose/urn.git";
  };

  meta = {
    description = "Split tracker / timer for speedrunning with GTK+ frontend";
    homepage = "https://github.com/paoloose/urn";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "urn-gtk";
  };
}
