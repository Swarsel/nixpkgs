{
  lib,
  fetchFromGitHub,
  cargo,
  makeWrapper,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-clean-recursive";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "IgaguriMK";
    repo = "cargo-clean-recursive";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-9+FqRvd0s9N7mQwIf+f3+vBhaa0YQWUR0j0lv4CBOkM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-KIoRsCy/Cei1YM/94kUcgI2Twgi8kEFVNiUM+sCPMyo=";

  postInstall = ''
    wrapProgram $out/bin/cargo-clean-recursive \
      --prefix PATH : ${lib.makeBinPath [ cargo ]}
  '';

  meta = {
    description = "Cleans all projects under specified directory";
    homepage = "https://github.com/IgaguriMK/cargo-clean-recursive";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ qubic ];
    mainProgram = "cargo-clean-recursive";
  };
})
