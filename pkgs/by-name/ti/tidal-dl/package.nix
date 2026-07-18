{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tidal-dl";
  version = "2022.10.31.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-b2AAsiI3n2/v6HC37fMI/d8UcxZxsWM+fnWvdajHrOg=";
  };

  propagatedBuildInputs = with python3Packages; [ aigpy ];
  format = "setuptools";

  meta = {
    description = "Application that lets you download videos and tracks from Tidal";
    homepage = "https://github.com/yaronzz/Tidal-Media-Downloader";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.misterio77 ];
    platforms = lib.platforms.all;
    mainProgram = "tidal-dl";
  };
})
