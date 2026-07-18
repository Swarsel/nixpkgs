{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libsixel,
  libx11,
  libxrandr,
  pkg-config,
  rustPlatform,
  withSixel ? false,
  withSki ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "menyoki";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "orhun";
    repo = "menyoki";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-owP3G1Rygraifdc4iPURQ1Es0msNhYZIlfrtj0CSU6Y=";
  };

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional stdenv.hostPlatform.isLinux pkg-config;

  buildInputs =
    lib.optional withSixel libsixel
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libx11
      libxrandr
    ];

  cargoHash = "sha256-6FRc/kEhGJXIZ+6GXeYj5j7QVmvZgIQgtDPvt94hlho=";

  checkFlags = [
    # sometimes fails on lower end machines
    "--skip=record::fps::tests::test_fps"
  ];

  postInstall = ''
    installManPage man/*
    installShellCompletion completions/menyoki.{bash,fish,zsh}
  '';

  buildFeatures = lib.optional withSixel "sixel";
  buildNoDefaultFeatures = !withSki;

  meta = {
    description = "Screen{shot,cast} and perform ImageOps on the command line";
    homepage = "https://menyoki.cli.rs/";
    changelog = "https://github.com/orhun/menyoki/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "menyoki";
  };
})
