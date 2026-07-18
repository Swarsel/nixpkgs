{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  firebird,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flamerobin";
  version = "0.9.14";

  src = fetchFromGitHub {
    owner = "mariuz";
    repo = "flamerobin";
    tag = finalAttrs.version;
    hash = "sha256-IwJEFF3vP0BC9PoMoY+XPLT+ygXnFXP/TWaqjdQWs8s=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    wxwidgets_3_2
    boost
    firebird
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Database administration tool for Firebird RDBMS";
    homepage = "https://github.com/mariuz/flamerobin";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ uralbash ];
    platforms = lib.platforms.unix;
    mainProgram = "flamerobin";
  };
})
