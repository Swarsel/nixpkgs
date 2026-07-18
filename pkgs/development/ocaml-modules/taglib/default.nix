{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  pkg-config,
  taglib_1,
  zlib,
}:

buildDunePackage rec {
  pname = "taglib";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-taglib";
    rev = "v${version}";
    sha256 = "sha256-tAvzVr0PW1o0kKFxdi/ks4obqnyBm8YfiiFupXZkUho=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    taglib_1
    zlib
  ];

  minimalOCamlVersion = "4.05.0"; # Documented version 4.02.0. 4.05.0 actually required.

  meta = {
    description = "Bindings for the taglib library which provides functions for reading tags in headers of audio files";
    homepage = "https://github.com/savonet/ocaml-taglib";

    license = with lib.licenses; [
      lgpl21Plus
      ocamlLgplLinkingException
    ]; # GNU Library Public License 2 Linking Exception

    maintainers = with lib.maintainers; [ dandellion ];
  };
}
