{
  lib,
  stdenv,
  fetchurl,
  curl,
  desktopToDarwinBundle,
  docbook_xml_dtd_45,
  docbook_xsl,
  file,
  gdk-pixbuf,
  geoclue2,
  gexiv2,
  gpsbabel,
  gpsd,
  gtk3,
  intltool,
  itstool,
  json-glib,
  libnova,
  liboauth,
  libxml2,
  libxslt,
  mapnik,
  nettle,
  pkg-config,
  sqlite,
  wrapGAppsHook3,
  xxd,
  xz,
  yelp-tools,
  withGeoClue ? true,
  withGeoTag ? true,
  withMBTiles ? true,
  withMagic ? true,
  withMapnik ? false,
  withMd5Hash ? true,
  withOAuth ? true,
  withRealtimeGPSTracking ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "viking";
  version = "1.11";

  src = fetchurl {
    url = "mirror://sourceforge/viking/viking-${finalAttrs.version}.tar.bz2";
    hash = "sha256-/iHVwRHvIId9HNlbGkvDT6rp3ToXuskj9BjhJxo8/JE=";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_45
    docbook_xsl
    intltool
    itstool
    libxslt
    pkg-config
    wrapGAppsHook3
    xxd
    yelp-tools
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    curl
    gdk-pixbuf
    gtk3
    json-glib
    libnova
    libxml2
    xz # liblzma
  ]
  ++ lib.optional withGeoClue geoclue2
  ++ lib.optional withGeoTag gexiv2
  ++ lib.optional withMagic file
  ++ lib.optional withMapnik mapnik
  ++ lib.optional withMBTiles sqlite
  ++ lib.optional withMd5Hash nettle
  ++ lib.optional withOAuth liboauth
  ++ lib.optional withRealtimeGPSTracking gpsd;

  configureFlags = [
    (lib.enableFeature withGeoClue "geoclue")
    (lib.enableFeature withGeoTag "geotag")
    (lib.enableFeature withMagic "magic")
    (lib.enableFeature withMapnik "mapnik")
    (lib.enableFeature withMBTiles "mbtiles")
    (lib.enableFeature withMd5Hash "nettle")
    (lib.enableFeature withOAuth "oauth")
    (lib.enableFeature withRealtimeGPSTracking "realtime-gps-tracking")
  ];

  doCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ gpsbabel ]}
    )
  '';

  meta = {
    description = "GPS data editor and analyzer";

    longDescription = ''
      Viking is a free/open source program to manage GPS data.  You
      can import and plot tracks and waypoints, show Openstreetmaps
      and/or Terraserver maps under it, download geocaches for an area
      on the map, make new tracks and waypoints, see real-time GPS
      position, etc.
    '';

    homepage = "https://sourceforge.net/projects/viking/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pSub
      sikmir
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "viking";
  };
})
