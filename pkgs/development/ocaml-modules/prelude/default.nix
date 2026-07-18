{
  lib,
  buildDunePackage,
  fetchzip,
}:

buildDunePackage (finalAttrs: {
  pname = "prelude";
  version = "0.5";

  # upstream git repo is misconfigured and cannot be cloned
  src = fetchzip {
    url = "https://git.zapashcanon.fr/zapashcanon/prelude/archive/${finalAttrs.version}.tar.gz";
    hash = "sha256-lti+q1U/eEasAXo0O5YEu4iw7947V9bdvSHA0IEMS8M=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.13";

  meta = {
    description = "Library to enforce good stdlib practices";
    homepage = "https://ocaml.org/p/prelude/";
    changelog = "https://git.zapashcanon.fr/zapashcanon/prelude/src/tag/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://git.zapashcanon.fr/zapashcanon/prelude";
  };
})
