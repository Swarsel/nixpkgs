{
  lib,
  fetchFromGitHub,
  buildPecl,
  libuv,
}:

buildPecl rec {
  pname = "uv";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "amphp";
    repo = "ext-uv";
    rev = "v${version}";
    hash = "sha256-RYb7rszHbdTLfBi66o9hVkFwX+7RlcxH5PAw5frjpFg=";
  };

  buildInputs = [ libuv ];

  meta = {
    description = "Interface to libuv for php";
    homepage = "https://github.com/amphp/ext-uv";
    license = lib.licenses.php301;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.php ];
  };
}
