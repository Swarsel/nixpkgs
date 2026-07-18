{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ip2location-c";
  version = "8.7.0";

  src = fetchFromGitHub {
    owner = "ip2location";
    repo = "IP2Location-C-Library";
    rev = finalAttrs.version;
    sha256 = "sha256-kp0tNZPP9u2xxFOmBAdivsVLtyF66o38H6eRrs2/S/Y=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  # Checks require a database, which require registration (although sample
  # databases are available, downloading them for just 1 test seems excessive):
  doCheck = false;
  enableParallelBuilding = true;

  meta = {
    description = "Library to look up locations of host names and IP addresses";

    longDescription = ''
      A C library to find the country, region, city,coordinates,
      zip code, time zone, ISP, domain name, connection type, area code,
      weather, MCC, MNC, mobile brand name, elevation and usage type of
      any IP address or host name in the IP2Location databases.
    '';

    homepage = "https://www.ip2location.com/developers/c";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ip2location";
  };
})
