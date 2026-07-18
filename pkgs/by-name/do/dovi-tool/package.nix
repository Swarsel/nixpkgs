{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  makeFontsConf,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

let
  fontsConf = makeFontsConf {
    fontDirectories = [ ];
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dovi-tool";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "quietvoid";
    repo = "dovi_tool";
    tag = finalAttrs.version;
    hash = "sha256-8UG3p84wjuPpnwcz65dyDbLDaoFXtokxNvnldBZHqwc=";
  };

  nativeBuildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    pkg-config
  ];

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    fontconfig
  ];

  cargoHash = "sha256-nr2F+QZurNN/iCFW62LZaheZkuCGId4TSRuYd1yYH88=";

  preCheck = lib.optionals (!stdenv.hostPlatform.isDarwin) ''
    # Fontconfig error: Cannot load default config file: No such file: (null)
    export FONTCONFIG_FILE="${fontsConf}"
    # Fontconfig error: No writable cache directories
    export XDG_CACHE_HOME="$(mktemp -d)"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Needed for rpu::plot::plot_p7 to pass in the sandbox.
  __impureHostDeps = lib.optionals stdenv.hostPlatform.isDarwin [
    "/System/Library/Fonts/Supplemental/Arial.ttf"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/dovi_tool";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool combining multiple utilities for working with Dolby Vision";
    homepage = "https://github.com/quietvoid/dovi_tool";
    changelog = "https://github.com/quietvoid/dovi_tool/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ plamper ];
    mainProgram = "dovi_tool";
  };
})
