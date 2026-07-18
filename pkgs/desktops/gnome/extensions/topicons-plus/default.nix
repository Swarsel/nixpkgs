{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-topicons-plus";
  version = "27";

  src = fetchFromGitHub {
    owner = "phocean";
    repo = "TopIcons-plus";
    rev = version;
    sha256 = "1p3jlvs4zgnrvy8am7myivv4rnnshjp49kg87rd22qqyvcz51ykr";
  };

  nativeBuildInputs = [ gettext ];
  buildInputs = [ glib ];
  makeFlags = [ "INSTALL_PATH=$(out)/share/gnome-shell/extensions" ];
  passthru.extensionUuid = "TopIcons@phocean.net";

  meta = {
    description = "Brings all icons back to the top panel, so that it's easier to keep track of apps running in the backround";
    homepage = "https://github.com/phocean/TopIcons-plus";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ eperuffo ];
  };
}
