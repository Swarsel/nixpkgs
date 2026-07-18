{
  lib,
  stdenv,
  fetchCrate,
  libiconv,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fst";
  version = "0.4.3";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-x2rvLMOhatMWU2u5GAdpYy2uuwZLi3apoE6aaTF+M1g=";
    crateName = "fst-bin";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  cargoHash = "sha256-zO2RYJpTyFFEQ+xZH4HU0CPaeiy6G3uq/qOwPawYSkk=";
  doInstallCheck = true;

  installCheckPhase = ''
    csv="$(mktemp)"
    fst="$(mktemp)"
    printf "abc,1\nabcd,1" > "$csv"
    $out/bin/fst map "$csv" "$fst" --force
    $out/bin/fst fuzzy "$fst" 'abc'
    $out/bin/fst --help > /dev/null
  '';

  meta = {
    description = "Represent large sets and maps compactly with finite state transducers";
    homepage = "https://github.com/BurntSushi/fst";

    license = with lib.licenses; [
      unlicense # or
      mit
    ];

    maintainers = with lib.maintainers; [ rmcgibbo ];
    mainProgram = "fst";
  };
})
