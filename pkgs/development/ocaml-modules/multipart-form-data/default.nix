{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  lwt,
  lwt_ppx,
  stringext,
}:

buildDunePackage (finalAttrs: {
  pname = "multipart-form-data";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "cryptosense";
    repo = "multipart-form-data";
    rev = finalAttrs.version;
    hash = "sha256-3MYJDvVbPIv/JDiB9nKcLRFC5Qa0afyEfz7hk8MWRII=";
  };

  buildInputs = [ lwt_ppx ];

  propagatedBuildInputs = [
    lwt
    stringext
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";

  meta = {
    description = "Parser for multipart/form-data (RFC2388)";
    homepage = "https://github.com/cryptosense/multipart-form-data";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
