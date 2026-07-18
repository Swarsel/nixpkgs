{
  lib,
  stdenv,
  fetchFromGitHub,
  erlang,
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
    stdenv.mkDerivation {
      pname = "webdriver";
      version = "0.pre+unstable=2015-02-08";

      src = fetchFromGitHub {
        owner = "Quviq";
        repo = "webdrv";
        rev = "7ceaf1f67d834e841ca0133b4bf899a9fa2db6bb";
        sha256 = "1pq6pmlr6xb4hv2fvmlrvzd8c70kdcidlgjv4p8n9pwvkif0cb87";
      };

      buildInputs = [ erlang ];
      installFlags = [ "PREFIX=$(out)/lib/erlang/lib" ];

      setupHook = writeText "setupHook.sh" ''
        addToSearchPath ERL_LIBS "$1/lib/erlang/lib/"
      '';

      passthru = {
        env = shell self;
      };

      meta = {
        description = "WebDriver implementation in Erlang";
        homepage = "https://github.com/Quviq/webdrv";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ ericbmerritt ];
      };

    };
in
lib.fix pkg
