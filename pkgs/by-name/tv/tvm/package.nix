{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tvm";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "incubator-tvm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+YnxYIGaPMgfLDsQEiCpqGuJRBTFEbXWI1L2JdnUyfI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "End to End Deep Learning Compiler Stack for CPUs, GPUs and accelerators";
    homepage = "https://tvm.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ adelbertc ];
    platforms = lib.platforms.all;
  };
})
