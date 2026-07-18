{
  lib,
  fetchFromGitHub,
  libxml2,
  pkgs,
  ...
}:

{
  pname = "gerbil-libxml";
  version = "unstable-2023-09-23";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ libxml2 ];
  gerbil-package = "clan";
  gerbilInputs = [ ];
  git-version = "b08e5d8";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-libxml";
    rev = "b08e5d8fe4688a162824062579ce152a10adb4cf";
    sha256 = "1zfccqaibwy2b3srwmwwgv91dwy1xl18cfimxhcsxl6mxvgm61pd";
  };

  softwareName = "Gerbil-LibXML";
  version-path = "";

  meta = {
    description = "libxml bindings for Gerbil";
    homepage = "https://github.com/mighty-gerbils/gerbil-libxml";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
