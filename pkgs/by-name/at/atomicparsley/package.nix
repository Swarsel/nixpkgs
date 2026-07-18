{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atomicparsley";
  version = "20240608.083822.1ed9031";

  src = fetchFromGitHub {
    owner = "wez";
    repo = "atomicparsley";
    tag = finalAttrs.version;
    sha256 = "sha256-VhrOMpGNMkNNYjcfCqlHI8gdApWr1ThtcxDwQ6gyV/g=";
  };

  postPatch = ''
    patchShebangs tests/test.sh
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib ];
  doCheck = true;

  # copying files so that we dont need to patch the test.sh
  checkPhase = ''
    (
    cp AtomicParsley ../tests
    cd ../tests
    mkdir tests
    mv *.mp4 tests
    ./test.sh
    )
  '';

  installPhase = ''
    runHook preInstall
    install -D AtomicParsley $out/bin/AtomicParsley
    runHook postInstall
  '';

  meta = {
    description = "CLI program for reading, parsing and setting metadata into MPEG-4 files";
    homepage = "https://github.com/wez/atomicparsley";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pjones ];
    platforms = lib.platforms.unix;
    mainProgram = "AtomicParsley";
  };
})
