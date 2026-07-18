{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  installShellFiles,
  nix-update-script,
  nixosTests,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
let
  pname = "rqbit";

  version = "8.1.1";

  src = fetchFromGitHub {
    owner = "ikatson";
    repo = "rqbit";
    rev = "v${version}";
    hash = "sha256-5ErcI3hwC2EgxsjgEVlbHP1MzBf/LndpgTfynQGc29s=";
  };

  rqbit-webui = buildNpmPackage {
    inherit version src nodejs;
    pname = "rqbit-webui";
    npmDepsHash = "sha256-vib8jpf7Jn1qv0m/dWJ4TbisByczNbtEd8hIM5ll2Q8=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dist
      cp -r dist/** $out/dist

      runHook postInstall
    '';

    sourceRoot = "${src.name}/crates/librqbit/webui";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  postPatch = ''
    # This script fascilitates the build of the webui,
    #  we've already built that
    rm crates/librqbit/build.rs
  '';

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ openssl ];
  cargoHash = "sha256-gYasOjrG0oeT/6Ben57MKAvBtgpoSmZ93RZQqSXAxIc=";

  preConfigure = ''
    mkdir -p crates/librqbit/webui/dist
    cp -R ${rqbit-webui}/dist/** crates/librqbit/webui/dist
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd rqbit --$shell <($out/bin/rqbit completions $shell)
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    tests.testService = nixosTests.rqbit;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "webui"
      ];
    };

    webui = rqbit-webui;
  };

  meta = {
    description = "Bittorrent client in Rust";
    homepage = "https://github.com/ikatson/rqbit";
    changelog = "https://github.com/ikatson/rqbit/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cafkafk
      toasteruwu
    ];

    mainProgram = "rqbit";
  };
}
