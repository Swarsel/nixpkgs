{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ctypes-foreign,
  dune-configurator,
  posix-socket,
  srt,
}:

buildDunePackage (finalAttrs: {
  pname = "srt";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-srt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+1/TffqssRA9YR3KLfbAr/ZpDF5XUKw24gj4HWrhObU=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ctypes-foreign
    posix-socket
    srt
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "OCaml bindings for the libsrt library";
    homepage = "https://github.com/savonet/ocaml-srt";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      vbgl
      dandellion
    ];
  };
})
