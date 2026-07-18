{
  lib,
  fetchFromGitHub,
  # for tests
  beam27Packages,
  beam28Packages,
  elixir,
  fetchMixDeps,
  mixRelease,
  nix-update-script,
}:
# Based on ../elixir-ls/default.nix

let
  pname = "ex_doc";
  version = "0.40.3";
  src = fetchFromGitHub {
    owner = "elixir-lang";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-xGZCBnjYr+0x6JNcf0XZVdaKaUB8V72GuZI3lEunzic=";
  };
in
mixRelease {
  inherit
    pname
    version
    src
    elixir
    ;

  escriptBinName = "ex_doc";

  mixFodDeps = fetchMixDeps {
    inherit src version elixir;
    pname = "mix-deps-${pname}";
    hash = "sha256-FSLAQhFk7NCUXRMfNr6E9XvndrviapjcKZDisHbB87Y=";
  };

  stripDebug = true;

  passthru = {
    tests = {
      # ex_doc is the doc generation for OTP 27+, so let's make sure they build
      erlang_27 = beam27Packages.erlang;
      erlang_28 = beam28Packages.erlang;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = ''
      ExDoc produces HTML and EPUB documentation for Elixir projects
    '';

    homepage = "https://github.com/elixir-lang/ex_doc";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chiroptical ];
    platforms = lib.platforms.unix;
    mainProgram = "ex_doc";
  };
}
