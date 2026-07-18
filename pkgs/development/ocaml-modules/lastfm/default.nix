{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  re,
  xmlplaylist,
}:

buildDunePackage (finalAttrs: {
  pname = "lastfm";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-lastfm";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-1te9B2+sUmkT/i2K5ueswWAWpvJf9rXob0zR4CMOJlg=";
  };

  propagatedBuildInputs = [
    re
    xmlplaylist
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "OCaml API to lastfm radio and audioscrobbler";
    homepage = "https://github.com/savonet/ocaml-lastfm";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
