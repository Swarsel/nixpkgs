{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  fetchpatch2,
  ncurses,
  python3,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spades";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "ablab";
    repo = "spades";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BlZjfZKtCm1kWNPjdth3pYFN0plU7xfTsFotPefzzMY=";
  };

  patches = [
    # Add missing <cstdint> for uint{8,64}_t to fix build with gcc 15.
    (fetchpatch2 {
      hash = "sha256-yAQVqE6DwPe+GZ4VR1cGytaO8NmHz6TUG7EdtbxIuTU=";
      relative = "src";
      url = "https://github.com/ablab/spades/commit/10b6af96ead72fdb19e8e524aa24bdcff9986e76.patch?full_index=1";
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2
    ncurses
    python3
    readline
  ];

  cmakeFlags = [
    "-DZLIB_ENABLE_TESTS=OFF"
    "-DSPADES_BUILD_INTERNAL=OFF"
  ];

  preConfigure = ''
    # The CMakeListsInternal.txt file should be empty in the release tarball
    echo "" > CMakeListsInternal.txt
  '';

  doCheck = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "St. Petersburg genome assembler, a toolkit for assembling and analyzing sequencing data";
    homepage = "http://ablab.github.io/spades";
    changelog = "https://github.com/ablab/spades/blob/${finalAttrs.version}/changelog.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ bzizou ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isMusl;
    downloadPage = "https://github.com/ablab/spades";
  };
})
