{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  frei0r,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "frei0r";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-frei0r";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eh/ymZO/3a1z6uvZdnXgma/7AU2NBVs2lddA+R/kuQA=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ frei0r ];

  meta = {
    description = "Bindings for the frei0r API which provides video effects";
    homepage = "https://github.com/savonet/ocaml-frei0r";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
