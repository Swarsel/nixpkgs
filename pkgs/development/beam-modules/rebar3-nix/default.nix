{
  lib,
  fetchFromGitHub,
  buildRebar3,
}:
buildRebar3 rec {
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "erlang-nix";
    repo = name;
    rev = "v${version}";
    sha256 = "10ijc06qvv5hqv0qy3w7mbv9pshdb8bvy0f3phr1vd5hksbk731y";
  };

  name = "rebar3_nix";

  meta = {
    description = "nix integration for rebar3";
    homepage = "https://github.com/erlang-nix/rebar3_nix";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      dlesl
      gleber
    ];
  };
}
