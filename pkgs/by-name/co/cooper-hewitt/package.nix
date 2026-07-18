{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "cooper-hewitt";
  version = "unstable-2014-06-09";

  src = fetchzip {
    url = "https://web.archive.org/web/20221004145117/https://www.cooperhewitt.org/wp-content/uploads/fonts/CooperHewitt-OTF-public.zip";
    hash = "sha256-bTlEXQeYNNspvnNdvQhJn6CNBrcSKYWuNWF/N6+3Vb0=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Contemporary sans serif, with characters composed of modified-geometric curves and arches";
    homepage = "https://www.cooperhewitt.org/open-source-at-cooper-hewitt/cooper-hewitt-the-typeface-by-chester-jenkins/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
}
