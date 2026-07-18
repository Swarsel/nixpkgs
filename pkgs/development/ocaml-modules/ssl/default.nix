{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  dune-configurator,
  ocaml,
  openssl,
  pkg-config,
}:

buildDunePackage rec {
  pname = "ssl";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-ssl";
    rev = "v${version}";
    hash = "sha256-gi80iwlKaI4TdAVnCyPG03qRWFa19DHdTrA0KMFBAc4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ openssl ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ alcotest ];

  preCheck = ''
    mkdir -p _build/default/tests/
    cp tests/digicert_certificate.pem _build/default/tests/
  '';

  __darwinAllowLocalNetworking = true;
  duneVersion = "3";

  meta = {
    description = "OCaml bindings for libssl";
    homepage = "http://savonet.rastageeks.org/";

    license = with lib.licenses; [
      lgpl21Plus
      ocamlLgplLinkingException
    ];

    maintainers = with lib.maintainers; [
      dandellion
    ];
  };
}
