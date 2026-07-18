{
  lib,
  fetchFromGitLab,
  glib-networking,
  libadwaita,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage {
  pname = "hackgregator";
  version = "0.5.0-unstable-2023-12-05";

  src = fetchFromGitLab {
    owner = "gunibert";
    repo = "hackgregator";
    rev = "594bdcdc3919c7216d611ddbbc77ab4d0c1f4f2b";
    hash = "sha256-RE0x4YWquWAcQzxGk9zdNjEp1pijrBtjV1EMBu9c5cs=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    openssl
    webkitgtk_6_0
    sqlite
    glib-networking
  ];

  cargoHash = "sha256-XI0dpW0BQoTgw7rCNTA3Imo5tU1eMqLvIHyqQD3sC6Q=";
  # 'error[E0432]: unresolved import' when compiling checks
  doCheck = false;

  postInstall = ''
    rm $out/bin/xtask
    mkdir -p $out/share
    pushd hackgregator/data
      cp -r icons $out/share/icons
      install -Dm644 de.gunibert.Hackgregator.desktop -t $out/share/applications
      install -Dm644 de.gunibert.Hackgregator.appdata.xml -t $out/share/appdata
    popd
  '';

  meta = {
    description = "Comfortable GTK reader application for news.ycombinator.com";
    homepage = "https://gitlab.com/gunibert/hackgregator";

    license = with lib.licenses; [
      gpl3Plus
      # and
      cc0
    ];

    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "hackgregator";
  };
}
