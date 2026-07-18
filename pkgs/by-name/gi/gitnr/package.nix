{
  lib,
  stdenv,
  fetchFromGitHub,
  libxkbcommon,
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gitnr";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "reemus-dev";
    repo = "gitnr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rt82Pb//OAM20BtaT/n1grL4GTTsW2iBziSVn/OI78c=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxkbcommon
    wayland
  ];

  cargoHash = "sha256-ej5lFiTkynW9ZXRkZtnKqWxaqHETHtYfbLi1L1I4KiM=";
  # requires internet access
  doCheck = false;

  meta = {
    description = "Create `.gitignore` files using one or more templates from TopTal, GitHub or your own collection";
    homepage = "https://github.com/reemus-dev/gitnr";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "gitnr";
  };
})
