{
  lib,
  stdenv,
  fetchgit,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "webdump";
  version = "0.2";

  src = fetchgit {
    url = "git://git.codemadness.org/webdump";
    tag = finalAttrs.version;
    hash = "sha256-YtgZkAnbQkIr2fhUYpSp/PaduuBFjxIkrkaROxrmT/0=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "HTML to plain-text converter for webpages";
    homepage = "https://www.codemadness.org/git/webdump";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ eyenx ];
    mainProgram = "webdump";
  };
})
