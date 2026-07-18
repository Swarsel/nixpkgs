{ fetchurl, alephone }:

alephone.makeWrapper {
  pname = "pathways-into-darkness";
  version = "1.1.1";
  desktopName = "Pathways-Into-Darkness";

  zip = fetchurl {
    hash = "sha256-j/x1Mp2snZAwttaffuaTU8II/zcrm4+4PrrYwpnsA3U=";
    url = "http://simplici7y.com/version/file/1185/AOPID_v1.1.1.zip";
  };

  meta = {
    description = ''Port of the 1993 mac game "Pathways Into Darkness" by Bungie to the Aleph One engine'';
    homepage = "http://simplici7y.com/items/aleph-one-pathways-into-darkness";
  };

}
