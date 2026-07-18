{
  openssl,
  pkg-config,
  rustPlatform,
  wezterm,
}:

rustPlatform.buildRustPackage {
  inherit (wezterm)
    version
    src
    postPatch
    cargoHash
    meta
    ;

  pname = "wezterm-headless";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  doCheck = false;

  postInstall = ''
    install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
    install -Dm644 ${wezterm.passthru.terminfo}/share/terminfo/w/wezterm -t $out/share/terminfo/w
  '';

  cargoBuildFlags = [
    "--package"
    "wezterm"
    "--package"
    "wezterm-mux-server"
  ];
}
