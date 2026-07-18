{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  ocplib-endian,
}:

buildDunePackage (finalAttrs: {
  pname = "msgpck";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "vbmithr";
    repo = "ocaml-msgpck";
    rev = "${finalAttrs.version}";
    hash = "sha256-gBHIiicmk/5KBkKzRKyV0ymEH8dGCZG8vfE0mtpcDCM=";
  };

  propagatedBuildInputs = [ ocplib-endian ];
  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "Fast MessagePack (http://msgpack.org) library";
    homepage = "https://github.com/vbmithr/ocaml-msgpck";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
