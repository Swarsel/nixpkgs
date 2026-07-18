{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fetchpatch,
  perl,
  rdma-core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qperf";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "linux-rdma";
    repo = "qperf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-x9l8xqwMDHlXRZpWt3XiqN5xyCTV5rk8jp/ClRPPECI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-+7ckhUUB+7BG6qRKv0wgyIxkyvll2xjf3Wk1hpRsDo0=";
      name = "version-bump.patch";
      url = "https://github.com/linux-rdma/qperf/commit/34ec57ddb7e5ae1adfcfc8093065dff90b69a275.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    perl
    rdma-core
  ];

  buildInputs = [ rdma-core ];

  configurePhase = ''
    runHook preConfigure
    ./autogen.sh
    ./configure --prefix=$out
    runHook postConfigure
  '';

  postUnpack = ''
    patchShebangs .
  '';

  meta = {
    description = "Measure RDMA and IP performance";
    homepage = "https://github.com/linux-rdma/qperf";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ edwtjo ];
    platforms = lib.platforms.linux;
    mainProgram = "qperf";
  };
})
