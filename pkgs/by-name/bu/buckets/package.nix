{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  makeWrapper,
}:

let

  inherit (stdenv.hostPlatform) system;

  platform =
    {
      aarch64-linux = "arm64";
      x86_64-linux = "amd64";
    }
    .${system};

  # Get hash in sri format
  # nix-prefetch-url <url> | xargs nix --extra-experimental-features nix-command hash convert --hash-algo sha256
  hash =
    {
      aarch64-linux = "sha256-Qu2YHGu0EPFaXjlUwJ7On8tOA9rqX/k8UnwADuRxoUk=";
      x86_64-linux = "sha256-DK5+VT4+OCcJ4Bbv6GGs6R332GMsD1gNEmcz0iaJb1c=";
    }
    .${system};

  pname = "buckets";
  version = "0.80.0";
  src = fetchurl {
    inherit hash;
    url = "https://github.com/buckets/application/releases/download/v${version}/Buckets-linux-latest-${platform}-${version}.AppImage";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/buckets
    install -m 444 -D ${appimageContents}/buckets.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/buckets.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=buckets'
    for size in 16 32 48 64 128 256 512; do
        install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/buckets.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/buckets.png
    done
  '';

  extraPkgs = pkgs: (appimageTools.defaultFhsEnvArgs.multiPkgs pkgs) ++ [ pkgs.libsodium ];

  meta = {
    description = "Private family budgeting app";
    homepage = "https://www.budgetwithbuckets.com/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ kmogged ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "buckets";
  };
}
