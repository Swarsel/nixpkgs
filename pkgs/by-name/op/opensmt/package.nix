{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  flex,
  gmpxx,
  gtest,
  libedit,
  nix-update-script,
  readline,
  enableReadline ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opensmt";
  version = "2.9.2";

  src = fetchFromGitHub {
    owner = "usi-verification-and-security";
    repo = "opensmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xKpYABMn2bsXRg2PMjiMhsx6+FbAsxitLRnmqa1kmu0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    bison
    flex
  ];

  buildInputs = [
    libedit
    gmpxx
    gtest
  ]
  ++ lib.optional enableReadline readline;

  preConfigure = ''
    substituteInPlace test/CMakeLists.txt --replace-fail \
      'FetchContent_MakeAvailable' '#FetchContent_MakeAvailable'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Satisfiability modulo theory (SMT) solver";
    homepage = "https://github.com/usi-verification-and-security/opensmt";
    license = if enableReadline then lib.licenses.gpl2Plus else lib.licenses.mit;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "opensmt";
    broken = with stdenv.hostPlatform; (isLinux && isAarch64);
  };
})
