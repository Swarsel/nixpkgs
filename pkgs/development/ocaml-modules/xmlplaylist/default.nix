{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  xmlm,
}:

buildDunePackage (finalAttrs: {
  pname = "xmlplaylist";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-xmlplaylist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mDmNixQ3vdOjCQr1jUaQ6XhvRkJ0Ob9RB+BGkSdftPQ=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ xmlm ];

  meta = {
    description = "Module to parse various RSS playlist formats";
    homepage = "https://github.com/savonet/ocaml-xmlplaylist";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
