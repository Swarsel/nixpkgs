{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctrtool";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "3DSGuy";
    repo = "Project_CTR";
    rev = "ctrtool-v${finalAttrs.version}";
    sha256 = "GvEzv97DqCsaDWVqDpajQRWYe+WM8xCYmGE0D3UcSrM=";
  };

  # workaround for https://github.com/3DSGuy/Project_CTR/issues/145
  env.NIX_CFLAGS_COMPILE = "-O0";

  preBuild = ''
    make -j $NIX_BUILD_CORES deps
  '';

  installPhase = "
    mkdir $out/bin -p
    cp bin/ctrtool${stdenv.hostPlatform.extensions.executable} $out/bin/
  ";

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/ctrtool";
  passthru.updateScript = gitUpdater { rev-prefix = "ctrtool-v"; };

  meta = {
    description = "Tool to extract data from a 3ds rom";
    homepage = "https://github.com/3DSGuy/Project_CTR";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "ctrtool";
  };

})
