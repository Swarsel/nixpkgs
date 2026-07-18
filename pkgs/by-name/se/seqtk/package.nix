{
  lib,
  stdenv,
  fetchFromGitHub,
  isa-l,
  libdeflate,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seqtk";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "lh3";
    repo = "seqtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQYBs3hUlV9fr8F2SL//houKKEq0nFViq9ulOppRMcM=";
  };

  buildInputs = [
    zlib
    libdeflate
    isa-l
  ];

  makeFlags = [
    "CC:=$(CC)"
    "BINDIR=$(out)/bin"
  ];

  preInstall = ''
    mkdir -p "$out/bin"
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Toolkit for processing sequences in FASTA/Q formats";
    homepage = "https://github.com/lh3/seqtk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bwlang ];
    platforms = lib.platforms.all;
    mainProgram = "seqtk";
  };
})
