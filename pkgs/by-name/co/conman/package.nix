{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  expect,
  freeipmi,
  pkg-config,
  tcp_wrappers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "conman";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "dun";
    repo = "conman";
    tag = "conman-${finalAttrs.version}";
    hash = "sha256-CHWvHYTmTiEpEfHm3TF5aCKBOW2GsT9Vv4ehpj775NQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    freeipmi # For libipmiconsole.so.2
    tcp_wrappers # For libwrap.so.0
    expect # For conman/*.exp scripts
  ];

  enableParallelBuilding = true;

  meta = {
    description = "The Console Manager";
    homepage = "https://github.com/dun/conman";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      frantathefranta
    ];

    platforms = lib.platforms.linux;
  };

})
