{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc-full,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rep";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "eraserhd";
    repo = "rep";
    rev = "v${finalAttrs.version}";
    sha256 = "pqmISVm3rYGxRuwKieVpRwXE8ufWnBHEA6h2hrob51s=";
  };

  postPatch = ''
    substituteInPlace rc/rep.kak --replace '$(rep' '$('"$out/bin/rep"
  '';

  nativeBuildInputs = [
    asciidoc-full
  ];

  makeFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Single-shot nREPL client";
    homepage = "https://github.com/eraserhd/rep";
    license = lib.licenses.epl10;
    maintainers = [ lib.maintainers.eraserhd ];
    platforms = lib.platforms.all;
    mainProgram = "rep";
  };
})
