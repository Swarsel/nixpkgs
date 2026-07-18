{
  lib,
  stdenv,
  fetchFromRadicle,
  gitMinimal,
  jq,
  nixosTests,
  radicle-node,
  rustPlatform,
  sqlite,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radicle-ci-broker";
  version = "0.30.0";

  src = fetchFromRadicle {
    repo = "zwTxygwuz5LDGBq255RA2CbNGrz8";
    tag = "v${finalAttrs.version}";
    hash = "sha256-30+s//C9uMpGgA976RRduHmnmF6YEYmmG+V5P/1TYhA=";
    leaveDotGit = true;
    node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV";

    postFetch = ''
      git -C $out rev-parse --short HEAD > $out/.git_head
      rm -rf $out/.git
    '';

    seed = "seed.radicle.dev";
  };

  postPatch = ''
    substituteInPlace build.rs \
      --replace-fail "let hash = " "let hash = \"$(<$src/.git_head)\"; "

    substituteInPlace ci-broker.md \
      --replace-fail 'PATH: /bin' "" \
      --replace-fail '"PATH": "/bin"' ""
  '';

  cargoHash = "sha256-9DzdeJcjl8IpmDR+kXdbEHrGi/5e9P26HsZJ9OPZRSA=";

  nativeCheckInputs = [
    jq
    gitMinimal
    sqlite
    radicle-node
    writableTmpDirAsHomeHook
  ];

  checkFlags = [ "--skip=acceptance_criteria_for_upgrades" ];

  preCheck = ''
    ln -s "$PWD/target/${stdenv.hostPlatform.rust.rustcTarget}/$cargoBuildType" target/debug

    rad auth --alias alice --stdin </dev/null
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    tests = { inherit (nixosTests) radicle-ci-broker; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Radicle CI broker";
    homepage = "https://radicle.network/nodes/seed.radicle.dev/rad:zwTxygwuz5LDGBq255RA2CbNGrz8";
    changelog = "https://radicle.network/nodes/seed.radicle.dev/rad:zwTxygwuz5LDGBq255RA2CbNGrz8/tree/NEWS.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    mainProgram = "cib";
    teams = [ lib.teams.radicle ];
  };
})
