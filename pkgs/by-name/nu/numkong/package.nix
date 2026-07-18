{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "numkong";
  version = "7.7.0";

  src = fetchFromGitHub {
    owner = "ashvardanian";
    repo = "NumKong";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JZafqqq3jDX+iim2DvyuavuvZ0wrPLIU+hcrOiT1L84=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  __structuredAttrs = true;

  meta = {
    description = "Portable mixed-precision math, linear-algebra, & retrieval library with 2000+ SIMD kernels for x86, Arm, RISC-V, LoongArch, Power, & WebAssembly";
    homepage = "https://github.com/ashvardanian/NumKong/";
    changelog = "https://github.com/ashvardanian/NumKong/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
