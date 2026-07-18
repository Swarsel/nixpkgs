{
  stdenv,
  fetchFromGitHub,
  bpp-core,
  bpp-phyl,
  bpp-popgen,
  bpp-seq,
  cmake,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (bpp-core) version postPatch;
  pname = "bppsuite";

  src = fetchFromGitHub {
    owner = "BioPP";
    repo = "bppsuite";
    rev = "v${finalAttrs.version}";
    sha256 = "1wdwcgczqbc3m116vakvi0129wm3acln3cfc7ivqnalwvi6lrpds";
  };

  nativeBuildInputs = [
    cmake
    texinfo
  ];

  buildInputs = [
    bpp-core
    bpp-seq
    bpp-phyl
    bpp-popgen
  ];

  meta = bpp-core.meta // {
    homepage = "https://github.com/BioPP/bppsuite";
    changelog = "https://github.com/BioPP/bppsuite/blob/master/ChangeLog";
  };
})
