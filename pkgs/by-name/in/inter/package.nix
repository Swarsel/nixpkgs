{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "inter";
  version = "4.1";

  src = fetchzip {
    url = "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
    hash = "sha256-5vdKKvHAeZi6igrfpbOdhZlDX2/5+UvzlnCQV6DdqoQ=";
    stripRoot = false;
  };

  postPatch = ''
    rm extras/ -rf
  '';

  nativeBuildInputs = [ installFonts ];
  dontInstallWebfonts = true;

  meta = {
    description = "Typeface specially designed for user interfaces";
    homepage = "https://rsms.me/inter/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ demize ];
    platforms = lib.platforms.all;
  };
}
