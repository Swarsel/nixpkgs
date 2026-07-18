{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  effects,
  lightyear,
}:
build-idris-package {
  pname = "tlhydra";
  version = "2017-13-26";

  src = fetchFromGitHub {
    owner = "Termina1";
    repo = "tlhydra";
    rev = "3fc9049447d9560fe16f4d36a2f2996494ac2b33";
    sha256 = "1y3gcbc1ypv00vwa0w3v0n6ckf7gnz26xsfmgnidsaxzff3y0ymh";
  };

  idrisDeps = [
    effects
    contrib
    lightyear
  ];

  meta = {
    description = "Idris parser and serializer/deserealizer for TL language";
    homepage = "https://github.com/Termina1/tlhydra";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
