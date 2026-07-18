{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

{
  # : string
  description,
  # : list Maintainer
  maintainers,
  # : string
  pname,
  # : string
  sha256,
  # : string
  version,
  # : license
  license ? lib.licenses.isc,
  # : string
  owner ? "~humm",
  # : string
  rev ? "v${version}",
}:

let
  manDir = "${placeholder "out"}/share/man";

  src = fetchFromSourcehut {
    inherit owner rev sha256;
    repo = pname;
  };
in

stdenv.mkDerivation {
  inherit pname version src;

  makeFlags = [
    "MAN_DIR=${manDir}"
  ];

  dontBuild = true;

  meta = {
    inherit description license maintainers;
    inherit (src.meta) homepage;
    platforms = lib.platforms.all;
  };
}
