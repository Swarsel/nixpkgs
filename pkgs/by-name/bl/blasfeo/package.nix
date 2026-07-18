{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  withTarget ? "GENERIC",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blasfeo";
  version = "0.1.4.2";

  src = fetchFromGitHub {
    owner = "giaf";
    repo = "blasfeo";
    rev = finalAttrs.version;
    hash = "sha256-p1pxqJ38h6RKXMg1t+2RHlfmRKPuM18pbUarUx/w9lw=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-bH5xUKAjNFCO9rRc655BcMiUesNFFln+iEPC5JHcQAU=";
      name = "blasfeo-fix-cmake-4.patch";
      url = "https://github.com/giaf/blasfeo/commit/75078e2b6153d1c8bc5329e83a82d4d4d3eefd76.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DTARGET=${withTarget}" ];

  meta = {
    description = "Basic linear algebra subroutines for embedded optimization";
    homepage = "https://github.com/giaf/blasfeo";
    changelog = "https://github.com/giaf/blasfeo/blob/${finalAttrs.version}/Changelog.txt";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
