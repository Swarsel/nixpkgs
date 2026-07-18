{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sregex";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "openresty";
    repo = "sregex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HZ9O/3BQHHrTVLLlU0o1fLHxyRSesBhreT3IdGHnNsg=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "CC:=$(CC)"
  ];

  meta = {
    description = "Non-backtracking NFA/DFA-based Perl-compatible regex engine matching on large data streams";
    homepage = "https://github.com/openresty/sregex";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "sregex-cli";
  };
})
