{
  lib,
  stdenv,
  fetchFromGitHub,
  openfst,
  pkg-config,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "phonetisaurus";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "AdolfVonKleist";
    repo = "phonetisaurus";
    rev = version;
    sha256 = "1b18s5zz0l0fhqh9n9jnmgjz2hzprwzf6hx5a12zibmmam3qyriv";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    python3
    openfst
  ];

  enableParallelBuilding = true;

  meta = {
    inherit (src.meta) homepage;
    description = "Framework for Grapheme-to-phoneme models for speech recognition using the OpenFst framework";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.unix;
  };
}
