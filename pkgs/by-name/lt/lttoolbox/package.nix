{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  autoreconfHook,
  fetchpatch,
  icu,
  libtool,
  libxml2,
  pkg-config,
  python3,
  utf8cpp,
}:

stdenv.mkDerivation rec {
  pname = "lttoolbox";
  version = "3.7.6";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "lttoolbox";
    tag = "v${version}";
    hash = "sha256-T92TEhrWwPYW8e49rc0jfM0C3dmNYtuexhO/l5s+tQ0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf
    automake
    pkg-config
    utf8cpp
    libtool
  ];

  buildInputs = [
    libxml2
    icu
  ];

  buildFlags = [
    "CPPFLAGS=-I${utf8cpp}/include/utf8cpp"
  ];

  doCheck = true;
  nativeCheckInputs = [ python3 ];

  checkPhase = ''
    python3 tests/run_tests.py
  '';

  meta = {
    description = "Finite state compiler, processor and helper tools used by apertium";
    homepage = "https://github.com/apertium/lttoolbox";
    changelog = "https://github.com/apertium/lttoolbox/releases/tag/v${version}";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ onthestairs ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
