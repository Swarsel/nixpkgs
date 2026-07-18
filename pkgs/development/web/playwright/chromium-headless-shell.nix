{
  stdenv,
  alsa-lib,
  at-spi2-atk,
  autoPatchelfHook,
  browserVersion,
  expat,
  fetchzip,
  glib,
  libgbm,
  libgcc,
  libxcomposite,
  libxdamage,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  patchelfUnstable,
  revision,
  system,
  throwSystem,
  ...
}:
let
  download =
    (import ./browser-downloads.nix {
      inherit revision browserVersion;
      name = "chromium-headless-shell";
    }).${system} or throwSystem;

  linux = stdenv.mkDerivation {
    src = fetchzip {
      inherit (download) url stripRoot;

      hash =
        {
          aarch64-linux = "sha256-d9Qr3q4GjtUp2ZVFSq+M2Ap++WKaEscRzEkk4JwXL/E=";
          x86_64-linux = "sha256-wnN0SL8QqiFGZdevm06WOhR9o6q34+kHL5ay1mRYnxs=";
        }
        .${system} or throwSystem;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      patchelfUnstable
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      expat
      glib
      libxcomposite
      libxdamage
      libxfixes
      libxrandr
      libgbm
      libgcc
      libxkbcommon
      nspr
      nss
    ];

    buildPhase = ''
      cp -R . $out
    '';

    name = "playwright-chromium-headless-shell";
  };

  darwin = fetchzip {
    inherit (download) url stripRoot;

    hash =
      {
        aarch64-darwin = "sha256-qWrMOreqTOFhmFBROlXIPXrM3wqNT7iJJwpelVFke6I=";
      }
      .${system} or throwSystem;
  };
in
{
  aarch64-darwin = darwin;
  aarch64-linux = linux;
  x86_64-linux = linux;
}
.${system} or throwSystem
