{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  vimPlugins,
  vimUtils,
}:
let
  version = "0-unstable-2025-05-13";
  src = fetchFromGitHub {
    owner = "nvim-pack";
    repo = "nvim-spectre";
    rev = "72f56f7585903cd7bf92c665351aa585e150af0f";
    hash = "sha256-WPEizIClDmseDEhomCasLx/zfAMT7lq7ZBnfc/a8CuA=";
  };

  spectre_oxi = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "spectre_oxi";
    cargoHash = "sha256-0szVL45QRo3AuBMf+WQ0QF0CS1B9HWPxfF6l6TJtv6Q=";
    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";

    checkFlags = [
      # Flaky test (https://github.com/nvim-pack/nvim-spectre/issues/244)
      "--skip=tests::test_replace_simple"
    ];

    preCheck = ''
      mkdir tests/tmp/
    '';

    sourceRoot = "${src.name}/spectre_oxi";
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "nvim-spectre";

  postInstall = ''
    ln -s ${spectre_oxi}/lib/libspectre_oxi.* $out/lua/spectre_oxi.so
  '';

  dependencies = [ vimPlugins.plenary-nvim ];

  passthru = {
    # needed for the update script
    inherit spectre_oxi;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.nvim-spectre.spectre_oxi";
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    homepage = "https://github.com/nvim-pack/nvim-spectre/";
    license = lib.licenses.mit;
  };
}
