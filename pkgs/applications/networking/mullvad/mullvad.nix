{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  dbus,
  git,
  installShellFiles,
  libmnl,
  libnftnl,
  libwg,
  makeWrapper,
  pkg-config,
  protobuf,
  rustPlatform,
  versionCheckHook,
  writeShellScriptBin,
}:
let
  # NOTE(cole-h): This is necessary because wireguard-go-rs executes go in its build.rs (whose goal
  # is to  produce $OUT_DIR/libwg.a), and a mixed Rust-Go build is non-trivial (read: I didn't want
  # to attempt it). So, we just fake the "go" binary and do what it would have done: put libwg.a
  # under $OUT_DIR so that it can be linked against.
  fakeGoCopyLibwg = writeShellScriptBin "go" ''
    [ ! -e "$OUT_DIR"/libwg.a ] && cp ${libwg}/lib/libwg.a "$OUT_DIR"/libwg.a
  '';
in
rustPlatform.buildRustPackage rec {
  pname = "mullvad";
  version = "2026.2";

  src = fetchFromGitHub {
    owner = "mullvad";
    repo = "mullvadvpn-app";
    tag = version;
    hash = "sha256-8InCgT7HaM1npn03jEry7jr/JUGS2VNgC2FKpIZZiQw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    makeWrapper
    git
    installShellFiles
    fakeGoCopyLibwg
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      dbus.dev
      libnftnl
      libmnl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.libpcap
    ];

  cargoHash = "sha256-6SsEfCDJ/WipOk6m5CezRmjt8RT4cXAbicgKCOR161w=";

  checkFlags = [
    "--skip=version_check"
    "--skip=config_resolver::test"
  ];

  postInstall = ''
    compdir=$(mktemp -d)
    for shell in bash zsh fish; do
      $out/bin/mullvad shell-completions $shell $compdir
    done
    installShellCompletion --cmd mullvad \
      --bash $compdir/mullvad.bash \
      --zsh $compdir/_mullvad \
      --fish $compdir/mullvad.fish
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  cargoBuildFlags = [
    "-p mullvad-daemon --bin mullvad-daemon"
    "-p mullvad-cli --bin mullvad"
    "-p mullvad-setup --bin mullvad-setup"
    "-p mullvad-problem-report --bin mullvad-problem-report"
    "-p mullvad-exclude --bin mullvad-exclude"
    "-p tunnel-obfuscation --bin tunnel-obfuscation"
  ];

  passthru = {
    inherit libwg;
  };

  meta = {
    description = "Mullvad VPN command-line client tools";
    homepage = "https://github.com/mullvad/mullvadvpn-app";
    changelog = "https://github.com/mullvad/mullvadvpn-app/blob/${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ cole-h ];
    mainProgram = "mullvad";
  };
}
