{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vo-amrwbenc";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "mstorsjo";
    repo = "vo-amrwbenc";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-oHhoJAI47VqBGk9cO3G5oqnHpWxA2jnJs103MwcYj+w=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "VisualOn Adaptive Multi Rate Wideband (AMR-WB) encoder";
    homepage = "https://sourceforge.net/projects/opencore-amr/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
