{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "unison-fsmonitor";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "autozimu";
    repo = "unison-fsmonitor";
    rev = "v${version}";
    hash = "sha256-hMrfEKW4klzHF89UGI4NUwXE6/Yk/wsUXUxe7ZPy/b8=";
  };

  cargoHash = "sha256-N3l18MM5DqgDKzl6qAXUibaHgQKvAQFvZuuzgb3eAPE=";

  checkFlags = [
    # accesses /usr/bin/env
    "--skip=test_follow_link"
  ];

  meta = {
    description = "fsmonitor implementation for darwin";
    homepage = "https://github.com/autozimu/unison-fsmonitor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nevivurn ];
    platforms = lib.platforms.darwin;
    mainProgram = "unison-fsmonitor";
  };
}
