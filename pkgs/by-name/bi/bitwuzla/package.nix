{
  lib,
  stdenv,
  fetchFromGitHub,
  aiger,
  btor2tools,
  cadical,
  cmake,
  cryptominisat,
  git,
  gmp,
  gtest,
  kissat,
  meson,
  mpfr,
  ninja,
  pkg-config,
  python3,
  symfpu,
  zlib,
  cadical' ? cadical.override { version = "2.1.3"; },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bitwuzla";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "bitwuzla";
    repo = "bitwuzla";
    tag = finalAttrs.version;
    hash = "sha256-3uStLdDFhXVgqzremUPRbxPUcl0IqVg5MRLltgm8rCA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    git
    ninja
    cmake
  ];

  buildInputs = [
    cadical'
    cryptominisat
    btor2tools
    symfpu
    gmp
    zlib
    kissat
    aiger
    mpfr
  ];

  mesonFlags = [
    # note: the default value for default_library fails to link dynamic dependencies
    # but setting it to shared works even in pkgsStatic
    "-Ddefault_library=shared"
    "-Dcryptominisat=true"
    "-Dkissat=true"
    "-Daiger=true"

    (lib.strings.mesonEnable "testing" finalAttrs.finalPackage.doCheck)
  ];

  # two tests fail on darwin
  doCheck = stdenv.hostPlatform.isLinux;
  nativeCheckInputs = [ python3 ];
  checkInputs = [ gtest ];
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    export needle=11011110101011011011111011101111

    cat > file.smt2 <<EOF
    (declare-fun a () (_ BitVec 32))
    (assert (= a #b$needle))
    (check-sat)
    (get-model)
    EOF

    # check each backend
    (
    set -euxo pipefail;
    $out/bin/bitwuzla -S cms -j 3 -m file.smt2 | tee /dev/stderr | grep $needle;
    $out/bin/bitwuzla -S cadical -m file.smt2 | tee /dev/stderr | grep $needle;
    $out/bin/bitwuzla -S kissat -m file.smt2 | tee /dev/stderr | grep $needle;
    )

    runHook postInstallCheck
  '';

  __structuredAttrs = true;

  meta = {
    description = "SMT solver for fixed-size bit-vectors, floating-point arithmetic, arrays, and uninterpreted functions";
    homepage = "https://bitwuzla.github.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ symphorien ];
    platforms = lib.platforms.unix;
    mainProgram = "bitwuzla";
  };
})
