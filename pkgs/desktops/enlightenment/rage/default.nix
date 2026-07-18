{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
  efl,
  gst_all_1,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "rage";
  version = "0.4.0";

  src = fetchurl {
    url = "https://download.enlightenment.org/rel/apps/${pname}/${pname}-${version}.tar.xz";
    sha256 = "03yal7ajh57x2jhmygc6msf3gzvqkpmzkqzj6dnam5sim8cq9rbw";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    efl
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];

  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "Video and audio player along the lines of mplayer";
    homepage = "https://enlightenment.org/";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      matejc
    ];

    platforms = lib.platforms.linux;
    mainProgram = "rage";
    teams = [ lib.teams.enlightenment ];
  };
}
