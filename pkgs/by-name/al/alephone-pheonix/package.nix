{ fetchurl, alephone }:

alephone.makeWrapper {
  pname = "marathon-pheonix";
  version = "1.3";
  desktopName = "Marathon-Pheonix";

  zip = fetchurl {
    hash = "sha256-EicLN54di18sarKyJm2GaEJJIsvaRmlHS/TUiT6YBuQ=";
    url = "http://simplici7y.com/version/file/998/Marathon_Phoenix_1.3.zip";
  };

  meta = {
    description = "35-level single player major Marathon conversion";
    homepage = "http://www.simplici7y.com/items/marathon-phoenix-2";
  };

}
