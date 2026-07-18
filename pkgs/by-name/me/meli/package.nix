{
  lib,
  stdenv,
  dbus,
  fetchzip,
  file,
  gnum4,
  # runtime deps
  gpgme,
  installShellFiles,
  makeWrapper,
  mandoc,
  notmuch,
  # build inputs
  openssl,
  # native build inputs
  pkg-config,
  rustPlatform,
  rustfmt,
  sqlite,
  writableTmpDirAsHomeHook,
  withNotmuch ? true,
}:

rustPlatform.buildRustPackage rec {
  pname = "meli";
  version = "0.8.13";

  src = fetchzip {
    hash = "sha256-uyhxNEKoRKrqvU76SuTKl1wlwOdHIxMFLXB5LwsdvQE=";

    urls = [
      "https://git.meli-email.org/meli/meli/archive/v${version}.tar.gz"
      "https://codeberg.org/meli/meli/archive/v${version}.tar.gz"
      "https://github.com/meli/meli/archive/refs/tags/v${version}.tar.gz"
    ];
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    makeWrapper
    mandoc
    (rustfmt.override { asNightly = true; })
  ];

  buildInputs = [
    openssl
    dbus
    sqlite
  ];

  cargoHash = "sha256-wDj4g5Cjm6zedjCmpc/A40peHO951lLuEQGsn+i3eT0=";
  # Needed to get openssl-sys to use pkg-config
  env.OPENSSL_NO_VENDOR = 1;

  nativeCheckInputs = [
    file
    gnum4
    writableTmpDirAsHomeHook
  ];

  checkFlags = [
    "--skip=test_cli_subcommands" # panicking due to sandbox
  ];

  postInstall = ''
    installManPage meli/docs/*.{1,5,7}

    wrapProgram $out/bin/meli \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath ([ gpgme ] ++ lib.optional withNotmuch notmuch)
      } \
      --prefix PATH : ${lib.makeBinPath [ gnum4 ]}
  '';

  meta = {
    description = "Terminal e-mail client and e-mail client library";
    homepage = "https://meli.delivery";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      _0x4A6F
      matthiasbeyer
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "meli";
  };
}
