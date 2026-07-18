{
  lib,
  stdenv,
  fetchFromGitHub,
  elixir,
  writeText,
}:

let
  shell =
    drv:
    stdenv.mkDerivation {
      buildInputs = [ drv ];
      name = "interactive-shell-${drv.name}";
    };

  pkg =
    self:
    stdenv.mkDerivation rec {
      pname = "hex";
      version = "2.5.1";

      src = fetchFromGitHub {
        owner = "hexpm";
        repo = "hex";
        rev = "v${version}";
        sha256 = "sha256-1xiv8FWX8fk9WBoJXCUfgFN9lo7ClMVUBYb1mmr6u9U=";
      };

      buildInputs = [ elixir ];

      buildPhase = ''
        runHook preBuild
        export HEX_OFFLINE=1
        export HEX_HOME=./
        export MIX_ENV=prod
        mix compile
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/erlang/lib
        cp -r ./_build/prod/lib/hex $out/lib/erlang/lib/

        runHook postInstall
      '';

      dontStrip = true;

      setupHook = writeText "setupHook.sh" ''
        addToSearchPath ERL_LIBS "$1/lib/erlang/lib/"
      '';

      passthru = {
        env = shell self;
      };

      meta = {
        description = "Package manager for the Erlang VM https://hex.pm";
        homepage = "https://github.com/hexpm/hex";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ericbmerritt ];
      };
    };
in
lib.fix pkg
