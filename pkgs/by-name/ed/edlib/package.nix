{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "edlib";
  version = "1.3.9.post1";

  src = fetchFromGitHub {
    owner = "Martinsos";
    repo = "edlib";
    tag = finalAttrs.version;
    hash = "sha256-XejxohLVdBBzpYZ//OpqC1ActmCaZ8tunJyhOYtZmKQ=";
  };

  patches = [
    # Bump minimum CMake version to 3.20
    (fetchpatch {
      hash = "sha256-Efbv8XYF1jOz6MypIyhfFJGQQt8gTYNZRd+R8ukIf3o=";
      name = "bump-cmake-version.patch";
      url = "https://github.com/Martinsos/edlib/commit/47359e591f3861f12105fa8e72242de64d5597c4.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [ cmake ];
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    bin/runTests
    runHook postCheck
  '';

  meta = {
    description = "Lightweight, fast C/C++ library for sequence alignment using edit distance";
    homepage = "https://martinsos.github.io/edlib";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
})
