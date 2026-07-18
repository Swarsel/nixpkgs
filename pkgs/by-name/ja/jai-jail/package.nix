{
  lib,
  fetchFromGitHub,
  acl,
  autoreconfHook,
  gcc15Stdenv,
  pandoc,
  pkg-config,
  systemd,
  util-linux,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "jai-jail";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "stanford-scs";
    repo = "jai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AByC7Xh1FYbQ/4Au396m2zYUxsLqcF1PEbpdz7x6LaQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    pandoc
    systemd
  ];

  buildInputs = [
    util-linux # libmount
    acl
  ];

  configureFlags = [ "--with-untrusted-user=jai" ];
  __structuredAttrs = true;

  meta = {
    description = "Lightweight jail for AI CLIs";
    homepage = "https://jai.scs.stanford.edu";
    changelog = "https://github.com/stanford-scs/jai/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ agentelement ];
    platforms = lib.platforms.linux;
    mainProgram = "jai";
  };
})
