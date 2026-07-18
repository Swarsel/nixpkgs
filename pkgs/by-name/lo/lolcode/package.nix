{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  fetchpatch,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {

  pname = "lolcode";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "justinmeza";
    repo = "lci";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VMBW3/sw+1kI6iuOckSPU1TIeY6QORcSfFLFkRYw3Gs=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-UwsR13lAkSz4gFHS28MyS9Nd7oyfQR+0BCp2lFs5UP4=";
      name = "cmake4-fix";
      url = "https://github.com/justinmeza/lci/commit/42ac17a22ddce737664b39a50442e6623a7e51a2.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    doxygen
  ];

  buildInputs = [ readline ];
  # Maybe it clashes with lci scientific logic software package...
  postInstall = "mv $out/bin/lci $out/bin/lolcode-lci";

  meta = {
    description = "Esoteric programming language";

    longDescription = ''
      LOLCODE is a funny esoteric  programming language, a bit Pascal-like,
      whose keywords are LOLspeak.
    '';

    homepage = "http://lolcode.org";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lolcode-lci";
  };

})
