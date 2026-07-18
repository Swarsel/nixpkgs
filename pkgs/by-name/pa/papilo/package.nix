{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  onetbb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "papilo";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "papilo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VHOwr3uIhurab1zI9FeecBXZIp1ee2pk8fhVak6H0+A=";
  };

  # skip SEGFAULT tests
  postPatch =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace test/CMakeLists.txt \
        --replace-fail '"matrix-buffer"' "" \
        --replace-fail '"vector-comparisons"' "" \
        --replace-fail '"matrix-comparisons"' "" \
        --replace-fail '"presolve-activity-is-updated-correctly-huge-values"' "" \
        --replace-fail '"problem-comparisons"' "" \
        --replace-fail "Boost_IOSTREAMS_FOUND" "FALSE"
    ''
    + (lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ''
      substituteInPlace test/CMakeLists.txt \
        --replace-fail '"happy-path-replace-variable"' ""
    '');

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    onetbb
  ];

  propagatedBuildInputs = [ onetbb ];
  doCheck = true;

  meta = {
    description = "Parallel Presolve for Integer and Linear Optimization";
    homepage = "https://scipopt.org/";
    license = with lib.licenses; [ lgpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "papilo";
  };
})
