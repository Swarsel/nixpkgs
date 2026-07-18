{
  lib,
  stdenv,
  fetchFromGitHub,
  libbsd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metastore";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "przemoc";
    repo = "metastore";
    rev = "v${finalAttrs.version}";
    sha256 = "0mb10wfckswqgi0bq25ncgabnd3iwj7s7hhg3wpcyfgckdynwizv";
  };

  buildInputs = [ libbsd ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Store and restore metadata from a filesystem";
    homepage = "https://software.przemoc.net/#metastore";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ sstef ];
    platforms = lib.platforms.linux;
    mainProgram = "metastore";
  };
})
