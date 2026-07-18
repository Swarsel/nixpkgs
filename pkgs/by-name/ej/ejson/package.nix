{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ejson";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "ejson";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-s/VeBajNZI0XNs1PwWMpHAF0Wrh1/ZQUvUZBnUCoPBM=";
  };

  vendorHash = "sha256-JeZkiiqNmDsuQSA6hCboasApRlTmw/+fgTAp5WbgdDg=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Small library to manage encrypted secrets using asymmetric encryption";
    homepage = "https://github.com/Shopify/ejson";
    license = lib.licenses.mit;
    mainProgram = "ejson";
  };
})
