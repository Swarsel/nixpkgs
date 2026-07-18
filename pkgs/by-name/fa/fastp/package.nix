{
  lib,
  stdenv,
  fetchFromGitHub,
  isa-l,
  libdeflate,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastp";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "OpenGene";
    repo = "fastp";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0hLq6r/XcYkF1J9LpiQ+qxh5MN4vDTRr5JibnIsq2J0=";
  };

  buildInputs = [
    zlib
    libdeflate
    isa-l
  ];

  installPhase = ''
    install -D fastp $out/bin/fastp
  '';

  meta = {
    description = "Ultra-fast all-in-one FASTQ preprocessor";
    homepage = "https://github.com/OpenGene/fastp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = lib.platforms.x86_64;
    mainProgram = "fastp";
  };
})
