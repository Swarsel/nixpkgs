{
  lib,
  fetchFromGitHub,
  ncurses6,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ncgopher";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "jansc";
    repo = "ncgopher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O5lC1eeiwXeX3aF8kLl65jl0Jq0dIswQiFuROWVFeYc=";
  };

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    ncurses6
    openssl
    sqlite
  ];

  cargoHash = "sha256-qCYx3RPp22YBFRwEoTttppDmyeg9J0I1QD5aK/OY7l8=";

  meta = {
    description = "Gopher and gemini client for the modern internet";
    homepage = "https://github.com/jansc/ncgopher";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jrrom ];
    platforms = lib.platforms.linux;
    mainProgram = "ncgopher";
  };
})
