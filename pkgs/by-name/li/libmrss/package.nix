{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  libnxml,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmrss";
  version = "0.19.4";

  src = fetchFromGitHub {
    owner = "bakulf";
    repo = "libmrss";
    tag = finalAttrs.version;
    hash = "sha256-sllY0Q8Ct7XJn4A3N8xQCUqaHXubPoB49gBZS1vURBs=";
  };

  postPatch = ''
    touch NEWS # https://github.com/bakulf/libmrss/issues/3
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  propagatedBuildInputs = [
    curl
    libnxml
  ];

  meta = {
    description = "C library for parsing, writing and creating RSS/ATOM files or streams";
    homepage = "https://github.com/bakulf/libmrss";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.all;
  };
})
