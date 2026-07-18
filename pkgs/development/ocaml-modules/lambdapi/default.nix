{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  camlp-streams,
  cmdliner,
  dedukti,
  dream,
  fetchpatch,
  lwt_ppx,
  menhir,
  pratter,
  sedlex,
  stdlib-shims,
  timed,
  why3,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "lambdapi";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/Deducteam/lambdapi/releases/download/${finalAttrs.version}/lambdapi-${finalAttrs.version}.tbz";
    hash = "sha256-EGau0mGP2OakAMUUfb9V6pd86NP+LlGKxnhcZ3WhuL4=";
  };

  patches = [
    # Compatibility with cmdliner ≥ 2
    (fetchpatch {
      hash = "sha256-9CkvH1o81T9LP+IPogKGhoiIDP76/nRfq59ttU7r0fI=";
      url = "https://github.com/Deducteam/lambdapi/commit/8e27c0f668915fbd49e32bdac246d6d515a64dd0.patch";
    })
  ];

  nativeBuildInputs = [
    dream
    menhir
  ];

  buildInputs = [ lwt_ppx ];

  propagatedBuildInputs = [
    camlp-streams
    cmdliner
    dream
    pratter
    sedlex
    stdlib-shims
    timed
    why3
    yojson
  ];

  doCheck = false; # anomaly: Sys_error("/homeless-shelter/.why3.conf: No such file or directory")

  checkInputs = [
    alcotest
    dedukti
  ];

  minimalOCamlVersion = "4.14";

  meta = {
    description = "Proof assistant based on the λΠ-calculus modulo rewriting";
    homepage = "https://github.com/Deducteam/lambdapi";
    changelog = "https://github.com/Deducteam/lambdapi/raw/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.cecill21;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
