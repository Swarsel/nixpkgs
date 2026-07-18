{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  incus,
  libuv,
  nix-update-script,
  pkg-config,
  raft-cowsql,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cowsql";
  version = "1.15.9";

  src = fetchFromGitHub {
    owner = "cowsql";
    repo = "cowsql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7djVcozWklI/0KhDC20df+H3YQbodUZaXBnQT4Ug8oI=";
  };

  outputs = [
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libuv
    raft-cowsql.dev
    sqlite
  ];

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    inherit (incus) tests;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Embeddable, replicated and fault tolerant SQL engine";
    homepage = "https://github.com/cowsql/cowsql";
    changelog = "https://github.com/cowsql/cowsql/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ lxc ];
  };
})
