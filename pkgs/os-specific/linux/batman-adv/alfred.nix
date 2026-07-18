{
  lib,
  stdenv,
  fetchurl,
  gpsd,
  libcap,
  libnl,
  pkg-config,
}:

let
  cfg = import ./version.nix;
in

stdenv.mkDerivation rec {
  inherit (cfg) version;
  pname = "alfred";

  src = fetchurl {
    url = "https://downloads.open-mesh.org/batman/releases/batman-adv-${version}/${pname}-${version}.tar.gz";
    sha256 = cfg.sha256.${pname};
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gpsd
    libcap
    libnl
  ];

  preBuild = ''
    makeFlags="PREFIX=$out"
  '';

  meta = {
    description = "B.A.T.M.A.N. routing protocol in a linux kernel module for layer 2, information distribution tool";
    homepage = "https://www.open-mesh.org/projects/batman-adv/wiki/Wiki";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = with lib.platforms; linux;
  };
}
