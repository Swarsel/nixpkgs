{
  lib,
  stdenv,
  fetchgit,
  libgit2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stagit";
  version = "1.2";

  src = fetchgit {
    url = "git://git.codemadness.org/stagit";
    rev = finalAttrs.version;
    sha256 = "sha256-mVYR8THGGfaTsx3aaSbQBxExRo87K47SD+PU5cZ8z58=";
  };

  buildInputs = [ libgit2 ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Git static site generator";
    homepage = "https://git.codemadness.org/stagit/file/README.html";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jb55
      sikmir
    ];

    platforms = lib.platforms.all;
  };
})
