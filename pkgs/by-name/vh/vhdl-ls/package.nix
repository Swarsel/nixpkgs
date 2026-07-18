{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vhdl-ls";
  version = "0.87.1";

  src = fetchFromGitHub {
    owner = "VHDL-LS";
    repo = "rust_hdl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+7kjRjRtsb038xw0x+yojhWVChvkBz6kTlqSc3rTwXE=";
  };

  postPatch = ''
    substituteInPlace vhdl_lang/src/config.rs \
      --replace /usr/lib $out/lib
  '';

  cargoHash = "sha256-NAi/YY6bu/yHHPWfgv5fimS3Ac4PL12T/U1Jknj/Zc8=";

  postInstall = ''
    mkdir -p $out/lib/rust_hdl
    cp -r vhdl_libraries $out/lib/rust_hdl
  '';

  meta = {
    description = "Fast VHDL language server";
    homepage = "https://github.com/VHDL-LS/rust_hdl";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "vhdl_ls";
  };
})
