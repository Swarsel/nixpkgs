{
  lib,
  stdenv,
  fetchurl,
  atkmm,
  autoPatchelfHook,
  cairo,
  gdk-pixbuf,
  gtk3,
  harfbuzz,
  libcxx,
  libz,
  makeWrapper,
  mpv-unwrapped,
  pango,
  undmg,
}:
let
  version = "0.3.22";
  url_base = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}";
  url =
    {
      aarch64-darwin = "${url_base}/harmonoid-macos-universal.dmg";
      aarch64-linux = "${url_base}/harmonoid-linux-aarch64.tar.gz";
      x86_64-linux = "${url_base}/harmonoid-linux-x86_64.tar.gz";
    }
    .${stdenv.hostPlatform.system}
      or (throw "${stdenv.hostPlatform.system} is an unsupported platform");
  hash =
    {
      aarch64-darwin = "sha256-YYMKrb7ZilfEztL2JTxSdeoDd8xQMrHFtN9N9fmsm3w=";
      aarch64-linux = "sha256-jXN5i+LudsODNZUzb5SXClqgQxYzanrbZCqB8X0pJRQ=";
      x86_64-linux = "sha256-+fEx30uu0rZiORrtE00xG2piJzpFbfxSZw3OjrhLJyg=";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "harmonoid";

  src = fetchurl {
    inherit url hash;
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    cairo
    gdk-pixbuf
    gtk3
    libz
    pango
    harfbuzz
    atkmm
    libcxx
  ];

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out
    cp -r bin $out
    mkdir -p $out
    cp -r share $out
    wrapProgram $out/bin/harmonoid --prefix LD_LIBRARY_PATH : $out/share/harmonoid/lib:${
      lib.makeLibraryPath [ mpv-unwrapped ]
    }
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r . $out/Applications/Harmonoid.app
  ''
  + ''
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Plays & manages your music library";
    homepage = "https://harmonoid.com/";
    changelog = "https://github.com/harmonoid/harmonoid/releases/tag/v${finalAttrs.version}";

    license = {
      free = false;
      fullName = "PolyForm Strict License 1.0.0";
      url = "https://polyformproject.org/licenses/strict/1.0.0/";
    };

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ivyfanchiang ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
