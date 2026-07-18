{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libao,
}:

buildDunePackage (finalAttrs: {
  pname = "ao";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-ao";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-HhJdb4i9B4gz3emgDCDT4riQuAsY4uP/47biu7EZ+sk=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ libao ];

  meta = {
    description = "OCaml bindings for libao";
    homepage = "https://github.com/savonet/ocaml-ao";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
