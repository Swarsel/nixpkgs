{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  mafft,
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mafft";
  version = "7.526";

  src = fetchFromGitLab {
    owner = "sysimm";
    repo = "mafft";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VNe00r12qEkLEbpZdJCe5xZ73JA3uAmuAeG+eSeRDI0=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-g89cFcnrLMlU/RLhS1kzCYPd5BWaH7wdz6tR+Ys3bVE=";
      name = "reduce-extern-symbols-alpine-compat";
      url = "https://gitlab.com/sysimm/mafft/-/commit/aa3b7d54e0a05c5ed7d665c094c3d89f2b6a907f.patch";
    })
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "PREFIX=$(out)"
  ];

  preBuild = ''
    cd ./core
    make clean
  '';

  passthru.tests = {
    simple = runCommand "${finalAttrs.pname}-test" { } ''
      mkdir $out
      cd ${finalAttrs.src}/test
      ${lib.getExe mafft} sample > $out/test.fftns2
      ${lib.getExe mafft} --maxiterate 100  sample > $out/test.fftnsi
      ${lib.getExe mafft} --globalpair sample > $out/test.gins1
      ${lib.getExe mafft} --globalpair --maxiterate 100  sample > $out/test.ginsi
      ${lib.getExe mafft} --localpair sample > $out/test.lins1
      ${lib.getExe mafft} --localpair --maxiterate 100  sample > $out/test.linsi
      diff $out/test.fftns2 sample.fftns2
      diff $out/test.fftnsi sample.fftnsi
      diff $out/test.gins1 sample.gins1
      diff $out/test.ginsi sample.ginsi
      diff $out/test.lins1 sample.lins1
    '';
  };

  meta = {
    description = "Multiple alignment program for amino acid or nucleotide sequences";
    homepage = "https://mafft.cbrc.jp/alignment/software/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.unix;
  };
})
