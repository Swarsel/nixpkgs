{
  lib,
  stdenv,
  fetchFromGitHub,
  inkscape,
  xcursorgen,
}:
stdenv.mkDerivation {
  pname = "volantes-cursors";
  version = "2022-08-27";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo = "volantes-cursors";
    rev = "b13a4bbf6bd1d7e85fadf7f2ecc44acc198f8d01";
    hash = "sha256-vJe1S+YHrUBwJSwt2+InTu5ho2FOtz7FjDxu0BIA1Js=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    inkscape
    xcursorgen
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  makeTargets = [ "build" ];

  meta = {
    description = "Classic cursor theme with a flying style";
    homepage = "https://www.pling.com/p/1356095/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ jordanisaacs ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64; # build timeout
  };
}
