{
  lib,
  stdenv,
  fetchFromGitLab,
  glibmm,
  modemmanager,
  pidgin,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "purple-mm-sms";
  version = "0.1.7";

  src = fetchFromGitLab {
    owner = "Librem5";
    repo = "purple-mm-sms";
    rev = "v${version}";
    sha256 = "0917gjig35hmi6isqb62vhxd3lkc2nwdn13ym2gvzgcjfgjzjajr";
    domain = "source.puri.sm";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glibmm
    pidgin
    modemmanager
  ];

  makeFlags = [
    "DATA_ROOT_DIR_PURPLE=$(out)/share"
    "PLUGIN_DIR_PURPLE=$(out)/lib/purple-2"
  ];

  meta = {
    description = "Libpurple plugin for sending and receiving SMS via Modemmanager";
    homepage = "https://source.puri.sm/Librem5/purple-mm-sms";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
