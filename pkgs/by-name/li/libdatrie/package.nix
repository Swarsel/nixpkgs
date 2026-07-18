{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  installShellFiles,
  libiconv,
}:

stdenv.mkDerivation rec {

  pname = "libdatrie";
  version = "2019-12-20";

  src = fetchFromGitHub {
    owner = "tlwg";
    repo = "libdatrie";
    rev = "d1db08ac1c76f54ba23d63665437473788c999f3";
    sha256 = "03dc363259iyiidrgadzc7i03mmfdj8h78j82vk6z53w6fxq5zxc";
  };

  outputs = [
    "bin"
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    installShellFiles
  ];

  buildInputs = [ libiconv ];

  postInstall = ''
    installManPage man/trietool.1
  '';

  preAutoreconf =
    let
      reports = "https://github.com/tlwg/libdatrie/issues";
    in
    ''
      sed -i -e "/AC_INIT/,+3d" configure.ac
      sed -i "5iAC_INIT(${pname},${version},[${reports}])" configure.ac
    '';

  meta = {
    description = "This is an implementation of double-array structure for representing trie";
    homepage = "https://linux.thai.net/~thep/datrie/datrie.html";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "datrie-0.2" ];
  };
}
