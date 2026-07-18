{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  gpgme,
  libx11,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:
let
  version = "1.5";
in
buildGoModule {
  inherit version;
  pname = "gomanagedocker";

  src = fetchFromGitHub {
    owner = "ajayd-san";
    repo = "gomanagedocker";
    tag = "v${version}";
    hash = "sha256-y2lepnhaLsjokd587D0bCEd9cmG7GuNBbbx+0sKSCGA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gpgme
    btrfs-progs
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];

  vendorHash = "sha256-hUlv3i+ri9W8Pf1zVtFxB/QSdPJu1cWCjMbquCxoSno=";
  # Mocking of docker and podman containers fails
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "TUI tool to manage your docker images, containers and volumes";
    homepage = "https://github.com/ajayd-san/gomanagedocker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "gomanagedocker";
  };
}
