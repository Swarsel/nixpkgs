{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "mparser";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "murmour";
    repo = "mparser";
    tag = finalAttrs.version;
    hash = "sha256-fUJMLy1Yn+y79mqDF0VwtrOi8z9jKBOjZk+QbMJOQZo=";
  };

  meta = {
    description = "Simple monadic parser combinator OCaml library";
    homepage = "https://github.com/murmour/mparser";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
