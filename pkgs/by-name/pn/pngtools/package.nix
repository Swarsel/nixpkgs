{
  lib,
  stdenv,
  fetchFromGitHub,
  libpng12,
}:

stdenv.mkDerivation {
  pname = "pngtools";
  version = "0-unstable-2022-03-14";

  src = fetchFromGitHub {
    owner = "mikalstill";
    repo = "pngtools";
    rev = "1ccca3a0f3f6882661bbafbfb62feb774ca195d1";
    sha256 = "sha256-W1XofOVTyfA7IbxOnTkWdOOZ00gZ4e0GOYl7nMtLIJk=";
  };

  buildInputs = [ libpng12 ];

  meta = {
    description = "PNG manipulation tools";
    homepage = "https://github.com/mikalstill/pngtools";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.all;
  };
}
