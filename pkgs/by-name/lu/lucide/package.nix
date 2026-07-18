{ lib, fetchurl }:
fetchurl rec {
  pname = "lucide";
  version = "0.563.0";
  downloadToTemp = true;
  hash = "sha256-dBE3gAmhffBsqZNp8rS4bzV8zIF538I1z/DRgk/oO2M=";

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    cp -a $downloadedFile $out/share/fonts/truetype/Lucide.ttf
  '';

  recursiveHash = true;
  url = "https://unpkg.com/lucide-static@${version}/font/Lucide.ttf";

  meta = {
    description = "Open-source icon library that provides 1000+ icons";
    homepage = "https://lucide.dev/";
    license = lib.licenses.isc;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = [ lib.maintainers.janTatesa ];
    platforms = lib.platforms.all;
    downloadPage = url;
  };
}
