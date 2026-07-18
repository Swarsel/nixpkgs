{
  lib,
  fetchFromGitHub,
  alsa-lib,
  buildDunePackage,
  dune-configurator,
}:

buildDunePackage (finalAttrs: {
  pname = "alsa";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-alsa";
    rev = finalAttrs.version;
    sha256 = "1qy22g73qc311rmv41w005rdlj5mfnn4yj1dx1jhqzr31zixl8hj";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ alsa-lib ];
  minimalOCamlVersion = "4.02";

  meta = {
    description = "OCaml interface for libasound2";
    homepage = "https://github.com/savonet/ocaml-alsa";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
