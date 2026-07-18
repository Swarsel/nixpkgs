{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  eigen,
  fetchpatch,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eigenrand";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "bab2min";
    repo = "EigenRand";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mrpkWIb6kfLvppmIfzhjF1/3m1zSd8XG1D07V6Zjlu0=";
  };

  patches = [
    # ref. https://github.com/bab2min/EigenRand/pull/61 merged upstream
    (fetchpatch {
      hash = "sha256-2KivLlyYGSRZurtxLghNfWwUNEUNWZdC6q+H65EPLnQ=";
      name = "support-eigen-341.patch";
      url = "https://github.com/bab2min/EigenRand/commit/8114df93b4c8a84a4f853380f0875a2c9d683cd0.patch";
    })
  ];

  # Avoid downloading googletest: we already have it.
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "FetchContent_MakeAvailable(googletest)" \
      "add_subdirectory(${gtest.src} googletest SYSTEM)"

    # broken by https://gitlab.com/libeigen/eigen/-/merge_requests/688
    # ref. https://github.com/NixOS/nixpkgs/pull/364362
    rm test/test_mv.cpp
  '';

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ eigen ];
  cmakeFlags = [ "-DCMAKE_CTEST_ARGUMENTS=--exclude-regex;EigenRand-test" ];
  doCheck = true;
  checkInputs = [ gtest ];

  postInstall = ''
    # Remove installed tests and googletest stuff
    rm -rf $out/bin $out/include/gmock $out/include/gtest $out/lib
  '';

  meta = {
    description = "Fastest Random Distribution Generator for Eigen";
    homepage = "https://github.com/bab2min/EigenRand";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
    platforms = lib.platforms.unix;
  };
})
