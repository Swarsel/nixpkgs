{
  lib,
  stdenv,
  fetchurl,
  gwenhywfar,
  pcsclite,
  pkg-config,
  zlib,
}:

let
  inherit ((import ./sources.nix).libchipcard) hash releaseId version;
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "libchipcard";

  src = fetchurl {
    inherit hash;
    url = "https://www.aquamaniac.de/rdm/attachments/download/${releaseId}/libchipcard-${version}.tar.gz";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gwenhywfar
    pcsclite
    zlib
  ];

  makeFlags = [ "crypttokenplugindir=$(out)/lib/gwenhywfar/plugins/ct" ];

  meta = {
    description = "Library for access to chipcards";
    homepage = "https://www.aquamaniac.de/rdm/projects/libchipcard";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ aszlig ];
    platforms = lib.platforms.linux;
  };
}
