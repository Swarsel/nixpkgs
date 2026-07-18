{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  gpgme,
  installShellFiles,
  libgpg-error,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "envio";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "humblepenguinn";
    repo = "envio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3bcIGQ+4abdG7Xw4Sta+I8a1XllO8h7V09egwuogcxk=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libgpg-error
    gpgme
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
  ];

  cargoHash = "sha256-QwuGpIhPS0p+TsbWdGknXcN655IP/AzE44a6m9HY8K0=";

  postInstall = ''
    installManPage man/*.1
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern and secure CLI tool for managing environment variables";

    longDescription = ''
      Envio is a command-line tool that simplifies the management of
      environment variables across multiple profiles. It allows users to easily
      switch between different configurations and apply them to their current
      environment.
    '';

    homepage = "https://github.com/humblepenguinn/envio";
    changelog = "https://github.com/humblepenguinn/envio/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ afh ];
    platforms = lib.platforms.unix;
    mainProgram = "envio";
  };
})
