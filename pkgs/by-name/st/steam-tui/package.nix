{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  runtimeShell,
  rustPlatform,
  steam-run,
  steamcmd,
  wine,
  withWine ? false,
}:

rustPlatform.buildRustPackage rec {
  pname = "steam-tui";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dmadisetti";
    repo = "steam-tui";
    rev = version;
    sha256 = "sha256-3vBIpPIsh+7PjTuNNqp7e/pdciOYnzuGkjb/Eks6QJw=";
  };

  nativeBuildInputs = [
    openssl
    pkg-config
  ];

  buildInputs = [ steamcmd ] ++ lib.optional withWine wine;
  cargoHash = "sha256-/39MrHCdJGTBTZplQcwYk6zpaVFYHpRKHhZC1GTNysY=";
  env.PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";
  checkFlags = [ "--skip=impure" ];

  preFixup = ''
    mv $out/bin/steam-tui $out/bin/.steam-tui-unwrapped
    cat > $out/bin/steam-tui <<EOF
    #!${runtimeShell}
    export PATH=${steamcmd}/bin:\$PATH
    exec ${steam-run}/bin/steam-run $out/bin/.steam-tui-unwrapped '\$@'
    EOF
    chmod +x $out/bin/steam-tui
  '';

  meta = {
    description = "Rust TUI client for steamcmd";
    homepage = "https://github.com/dmadisetti/steam-tui";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dmadisetti
    ];

    # steam only supports that platform
    platforms = [ "x86_64-linux" ];
    mainProgram = "steam-tui";
  };
}
