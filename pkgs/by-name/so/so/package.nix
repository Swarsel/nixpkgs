{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
}:

let
  self = rustPlatform.buildRustPackage {
    pname = "so";
    version = "0.4.10";

    src = fetchFromGitHub {
      inherit (self) version;
      owner = "samtay";
      repo = "so";
      rev = "v${self.version}";
      hash = "sha256-25jZEo1C9XF4m9YzDwtecQy468nHyv2wnRuK5oY2siU=";
      pname = "so-source";
    };

    strictDeps = true;
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ];

    cargoHash = "sha256-cSLsfYYtdMiXGCG3jpq2Cxl8TgSb7iCWoeXNwEuv4FM=";

    passthru = {
      tests = {
        version = testers.testVersion {
          command = ''
            export HOME=$TMP
            so --version
          '';

          package = self;
        };
      };
    };

    meta = {
      description = "TUI to StackExchange network";
      homepage = "https://github.com/samtay/so";
      changelog = "https://github.com/samtay/so/blob/main/CHANGELOG.md";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        unsolvedcypher
      ];

      mainProgram = "so";
    };
  };
in
self
