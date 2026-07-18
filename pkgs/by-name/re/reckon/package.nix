{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  file,
  makeWrapper,
  reckon,
  testers,
}:

stdenv.mkDerivation rec {
  pname = "reckon";
  version = (import ./gemset.nix).reckon.version;
  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      env = bundlerEnv {
        gemdir = ./.;
        name = "${pname}-${version}-gems";
      };
    in
    ''
      runHook preInstall
      mkdir -p $out/bin
      makeWrapper ${env}/bin/reckon $out/bin/reckon \
        --prefix PATH : ${lib.makeBinPath [ file ]}
      runHook postInstall
    '';

  dontUnpack = true;

  passthru = {
    tests.version = testers.testVersion {
      version = "${version}";
      package = reckon;
    };

    updateScript = bundlerUpdateScript "reckon";
  };

  meta = {
    description = "Flexibly import bank account CSV files into Ledger for command line accounting";
    changelog = "https://github.com/cantino/reckon/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nicknovitski ];
    platforms = lib.platforms.unix;
    mainProgram = "reckon";
  };
}
