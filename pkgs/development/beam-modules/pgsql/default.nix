{
  lib,
  stdenv,
  fetchFromGitHub,
  buildRebar3,
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
    buildRebar3 {
      version = "25+beta.2";

      src = fetchFromGitHub {
        owner = "semiocast";
        repo = "pgsql";
        rev = "14f632bc89e464d82ce3ef12a67ed8c2adb5b60c";
        sha256 = "17dcahiwlw61zhy8aq9rn46lwb35fb9q3372s4wmz01czm8c348w";
      };

      dontStrip = true;
      name = "pgsql";

      passthru = {
        env = shell self;
      };

      meta = {
        description = "Erlang PostgreSQL Driver";
        homepage = "https://github.com/semiocast/pgsql";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ericbmerritt ];
      };

    };
in
lib.fix pkg
