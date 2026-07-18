{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wolfram-for-jupyter-kernel";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "WolframResearch";
    repo = "WolframLanguageForJupyter";
    rev = "v${finalAttrs.version}";
    sha256 = "19d9dvr0bv7iy0x8mk4f576ha7z7h7id39nyrggwf9cp7gymxf47";
  };

  # no tests
  doCheck = false;

  installPhase = ''
    patchShebangs ./configure-jupyter.wls
    mkdir -p $out/share/Wolfram
    cp -r {WolframLanguageForJupyter,images,extras,LICENSE} $out/share/Wolfram
  '';

  dontConfigure = true;

  meta = {
    description = "Jupyter kernel for Wolfram Language";
    homepage = "https://github.com/WolframResearch/WolframLanguageForJupyter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fbeffa ];
    platforms = lib.platforms.all;
  };
})
