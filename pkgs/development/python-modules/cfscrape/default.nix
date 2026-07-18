{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
}:

buildPythonPackage {
  pname = "cfscrape";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Anorov";
    repo = "cloudflare-scrape";
    rev = "9692fe7ff3c17b76ddf0f4d50d3dba7d1791c9c6";
    hash = "sha256-uO8lBZonjk+mlFYoNSaz+GIN/W9yf8VL9OQ7MKfsMgI=";
  };

  propagatedBuildInputs = [ requests ];
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python module to bypass Cloudflare's anti-bot page";
    homepage = "https://github.com/Anorov/cloudflare-scrape";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
