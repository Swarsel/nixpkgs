{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gperftools,
  withGPerfTools ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sentencepiece";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "sentencepiece";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-q0JgMxoD9PLqr6zKmOdrK2A+9RXVDub6xy7NOapS+vs=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  # https://github.com/google/sentencepiece/issues/754
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '\$'{exec_prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace '\$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = lib.optionals withGPerfTools [ gperftools ];

  # On Darwin, non-static build segfaults on python module import.
  # See: https://github.com/NixOS/nixpkgs/issues/466092
  cmakeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-DSPM_ENABLE_SHARED=OFF"
  ];

  meta = {
    description = "Unsupervised text tokenizer for Neural Network-based text generation";
    homepage = "https://github.com/google/sentencepiece";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ pashashocky ];
    platforms = lib.platforms.unix;
  };
})
