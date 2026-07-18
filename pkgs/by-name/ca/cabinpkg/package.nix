{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  fmt_11,
  libgit2,
  nlohmann_json,
  onetbb,
  pkg-config,
}:

let
  toml11 = fetchFromGitHub rec {
    version = "4.2.0";
    owner = "ToruNiina";
    repo = "toml11";
    sha256 = "sha256-NUuEgTpq86rDcsQnpG0IsSmgLT0cXhd1y32gT57QPAw=";
    tag = "v${version}";
  };
in
stdenv.mkDerivation rec {
  pname = "cabinpkg";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "cabinpkg";
    repo = "cabin";
    tag = version;
    sha256 = "sha256-qMmfViu3ol8+Tpyy8hn0j5r+bql0SFeKPVVj/ox4AGQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    fmt_11
    onetbb
    nlohmann_json
    curl
  ];

  makeFlags = [
    "RELEASE=1"
    "COMMIT_HASH="
    "COMMIT_SHORT_HASH="
    "COMMIT_DATE="
  ];

  # Skip git cloning toml11
  preConfigure = ''
    substituteInPlace Makefile \
       --replace-fail "git clone https://github.com/ToruNiina/toml11.git \$@" ":" \
       --replace-fail "git -C \$@ reset --hard v4.2.0" ":"
  '';

  preBuild = ''
    mkdir -p build/DEPS/
    cp -rf ${toml11} build/DEPS/toml11
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Package manager and build system for C++";
    homepage = "https://cabinpkg.com";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "cabin";
    broken = (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64);
  };
}
