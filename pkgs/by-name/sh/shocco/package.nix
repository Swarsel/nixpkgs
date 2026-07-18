{
  lib,
  stdenv,
  fetchFromGitHub,
  perlPackages,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shocco";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "rtomayko";
    repo = "shocco";
    rev = finalAttrs.version;
    sha256 = "1nkwcw9fqf4vyrwidqi6by7nrmainkjqkirkz3yxmzk6kzwr38mi";
  };

  buildInputs = [
    perlPackages.TextMarkdown
    python3.pkgs.pygments
  ];

  prePatch = ''
    # Don't change $PATH
    substituteInPlace configure --replace PATH= NIRVANA=
  '';

  meta = {
    description = "Quick-and-dirty, literate-programming-style documentation generator for / in POSIX shell";
    homepage = "https://rtomayko.github.io/shocco/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.all;
    mainProgram = "shocco";
  };
})
