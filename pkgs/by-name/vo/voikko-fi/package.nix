{
  lib,
  fetchFromGitHub,
  foma,
  libvoikko,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "voikko-fi";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "voikko";
    repo = "corevoikko";
    tag = "rel-voikko-fi-${finalAttrs.version}";
    hash = "sha256-yYV8DHhILpcAG9gbEO67fdrX44Z2hOqkLbp9bBTSNuk=";
  };

  nativeBuildInputs = [
    python3
    foma
    libvoikko
  ];

  enableParallelBuilding = true;
  installTargets = "vvfst-install DESTDIR=$(out)/share/voikko-fi";
  sourceRoot = "${finalAttrs.src.name}/voikko-fi";

  meta = {
    description = "Description of Finnish morphology written for libvoikko";
    homepage = "https://voikko.puimula.org";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ lajp ];
    platforms = lib.platforms.unix;
  };
})
