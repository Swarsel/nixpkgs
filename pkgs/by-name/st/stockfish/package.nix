{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  gnugrep,
  nix,
  nix-update-script,
  versionCheckHook,
  writeShellApplication,
}:

let
  # The x86-64-modern may need to be refined further in the future
  # but stdenv.hostPlatform CPU flags do not currently work on Darwin
  # https://discourse.nixos.org/t/darwin-system-and-stdenv-hostplatform-features/9745
  archDarwin = if stdenv.hostPlatform.isx86_64 then "x86-64-modern" else "apple-silicon";
  arch =
    if stdenv.hostPlatform.isDarwin then
      archDarwin
    else if stdenv.hostPlatform.isx86_64 then
      "x86-64"
    else if stdenv.hostPlatform.isi686 then
      "x86-32"
    else if stdenv.hostPlatform.isAarch64 then
      "armv8"
    else if stdenv.hostPlatform.isAarch32 then
      "armv7"
    else
      "unknown";

  # These files can be found in src/evaluate.h
  nnueBigFile = "nn-c288c895ea92.nnue";
  nnueBigHash = "sha256-wojIleqSRCnqkJLj82srPB8A8qOkx1n/flfnnjtD5Kc=";
  nnueBig = fetchurl {
    hash = nnueBigHash;
    name = nnueBigFile;
    url = "https://tests.stockfishchess.org/api/nn/${nnueBigFile}";
  };
  nnueSmallFile = "nn-37f18f62d772.nnue";
  nnueSmallHash = "sha256-N/GPYtdy8xB+HWqso4mMEww8hvKrY+ZVX7vKIGNaiZ0=";
  nnueSmall = fetchurl {
    hash = nnueSmallHash;
    name = nnueSmallFile;
    url = "https://tests.stockfishchess.org/api/nn/${nnueSmallFile}";
  };
in

stdenv.mkDerivation rec {
  pname = "stockfish";
  version = "18";

  src = fetchFromGitHub {
    owner = "official-stockfish";
    repo = "Stockfish";
    tag = "sf_${version}";
    hash = "sha256-J9E0fJeUemKh1mAPJ5PjZ3kmXqAc1Ec3dG5sfzvhuGo=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "ARCH=${arch}"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "STRIP=${stdenv.cc.targetPrefix}strip"
  ];

  buildFlags = [ "build" ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;

  postUnpack = ''
    sourceRoot+=/src
    cp "${nnueBig}" "$sourceRoot/${nnueBigFile}"
    cp "${nnueSmall}" "$sourceRoot/${nnueSmallFile}"
  '';

  versionCheckProgram = "${placeholder "out"}/bin/stockfish";
  versionCheckProgramArg = "--help";

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [ "--version-regex=^sf_([\\d.]+)$" ];
      })
      (lib.getExe (writeShellApplication {
        name = "${pname}-nnue-updater";

        runtimeEnv = {
          NNUE_BIG_FILE = nnueBigFile;
          NNUE_BIG_HASH = nnueBigHash;
          NNUE_SMALL_FILE = nnueSmallFile;
          NNUE_SMALL_HASH = nnueSmallHash;
          PKG_FILE = toString ./package.nix;
          PNAME = pname;
        };

        runtimeInputs = [
          nix
          gnugrep
        ];

        text = builtins.readFile ./update.bash;
      }))
    ];
  };

  meta = {
    description = "Strong open source chess engine";

    longDescription = ''
      Stockfish is one of the strongest chess engines in the world. It is also
      much stronger than the best human chess grandmasters.
    '';

    homepage = "https://stockfishchess.org/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      luispedro
      siraben
      thibaultd
    ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "armv7l-linux"
    ];

    mainProgram = "stockfish";
  };

}
