{
  lib,
  alephone,
  requireFile,
}:

alephone.makeWrapper {
  pname = "apotheosis-x";
  version = "1.1";
  desktopName = "Marathon-Apotheosis-X";
  sourceRoot = "Apotheosis X 1.1";

  zip = requireFile {
    hash = "sha256-4Y/RQQeN4VTpig8ZyxUpVHwzN8W8ciTBCkSzND8SMbs=";
    name = "Apotheosis_X_1.1.zip";
    url = "https://www.moddb.com/mods/apotheosis-x/downloads";
  };

  meta = {
    description = "Total conversion for Marathon Infinity running on the Aleph One engine";
    homepage = "https://simplici7y.com/items/apotheosis-x-5";
    license = lib.licenses.unfree;
  };
}
