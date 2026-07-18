{
  lib,
  stdenv,
  fetchgit,
  gnunet,
  libgcrypt,
  libgnunetchat,
  libsodium,
  meson,
  ncurses,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnunet-messenger-cli";
  version = "0.3.1";

  src = fetchgit {
    url = "https://git-www.taler.net/messenger-cli.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Iby3IZXEZJ1dqVV62xDzXx/qq7JKhVtn6ZLb697ZSw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gnunet
    libgcrypt
    libgnunetchat
    libsodium
    ncurses
  ];

  env.INSTALL_DIR = (placeholder "out") + "/";
  preInstall = "mkdir -p $out/bin";
  preFixup = "mv $out/bin/messenger-cli $out/bin/gnunet-messenger-cli";

  meta = {
    description = "Decentralized, privacy-preserving networking framework for secure peer-to-peer communication";
    homepage = "https://git-www.taler.net/messenger-cli.git";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    platforms = lib.platforms.all;
    mainProgram = "gnunet-messenger-cli";
    teams = with lib.teams; [ ngi ];
  };
})
