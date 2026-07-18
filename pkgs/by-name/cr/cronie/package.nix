{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cronie";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "cronie-crond";
    repo = "cronie";
    rev = "cronie-${finalAttrs.version}";
    hash = "sha256-WrzdpE9t7vWpc8QFoFs+S/HgHwsidRNmfcHp7ltSWQw=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Fix build with GCC 15
    (fetchpatch {
      hash = "sha256-OU6pCFeEPC32cPE3K9Uq9HuvpwdUZpaBtyxNOaJkFVM=";
      url = "https://github.com/cronie-crond/cronie/commit/09c630c654b2aeff06a90a412cce0a60ab4955a4.patch";
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
  ];

  meta = {
    description = "Cron replacement, based on vixie-cron";
    homepage = "https://github.com/cronie-crond/cronie";
    changelog = "https://github.com/cronie-crond/cronie/blob/master/ChangeLog";

    license = with lib.licenses; [
      gpl2Plus
      isc
      lgpl21Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "crond";
  };
})
