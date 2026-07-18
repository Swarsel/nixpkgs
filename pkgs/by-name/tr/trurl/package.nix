{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  fetchpatch,
  perl,
  python3,
  trurl,
  versionCheckHook,
}:

stdenv.mkDerivation rec {
  pname = "trurl";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "curl";
    repo = "trurl";
    rev = "trurl-${version}";
    hash = "sha256-VCMT4WgZ6LG7yiKaRy7KTgTkbACVXb4rw62lWnVAuP0=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-7CkUs5tMk77WKc7SlgE2NslHtU5cViKSGhHj3IBlpWo=";
      url = "https://github.com/curl/trurl/commit/f22a2c45956f35702e437fb83ac05376f1956ec5.patch";
    })
    # https://github.com/curl/trurl/pull/441
    ./tests-uppercase-hex.patch
  ];

  postPatch = ''
    patchShebangs scripts/*
  '';

  strictDeps = true;

  nativeBuildInputs = [
    curl
    perl
  ];

  buildInputs = [ curl ];
  makeFlags = [ "PREFIX=$(out)" ];
  doCheck = true;
  nativeCheckInputs = [ python3 ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  checkTarget = "test";
  enableParallelBuilding = true;
  separateDebugInfo = stdenv.hostPlatform.isLinux;

  meta = {
    description = "Command line tool for URL parsing and manipulation";
    homepage = "https://curl.se/trurl";
    changelog = "https://github.com/curl/trurl/releases/tag/trurl-${version}";
    license = lib.licenses.curl;
    maintainers = with lib.maintainers; [ christoph-heiss ];
    platforms = lib.platforms.all;
    mainProgram = "trurl";
  };
}
