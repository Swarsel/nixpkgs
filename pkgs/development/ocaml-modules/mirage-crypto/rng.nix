{
  lib,
  stdenv,
  buildDunePackage,
  digestif,
  dune-configurator,
  duration,
  logs,
  mirage-crypto,
  ohex,
  ounit2,
  randomconv,
}:

buildDunePackage {
  inherit (mirage-crypto) version src;
  pname = "mirage-crypto-rng";

  # test_entropy relies on timer jitter and is flaky on x86_64-darwin.
  postPatch = lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ''
    substituteInPlace tests/dune \
      --replace-fail \
        '(enabled_if (and (<> %{architecture} "arm64") (<> %{architecture} "riscv")))' \
        '(enabled_if false)'
  '';

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    digestif
    mirage-crypto
    duration
    logs
  ];

  doCheck = true;

  checkInputs = [
    ohex
    ounit2
    randomconv
  ];

  minimalOCamlVersion = "4.14";

  meta = mirage-crypto.meta // {
    description = "Cryptographically secure PRNG";
  };
}
