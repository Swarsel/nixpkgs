{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  bind,
  coreutils,
  curl,
  file,
  iproute2,
  makeWrapper,
  netcat-gnu,
  nmap,
  openssl,
  python3,
  which,
}:

stdenv.mkDerivation rec {
  pname = "check_ssl_cert";
  version = "2.96.0";

  src = fetchFromGitHub {
    owner = "matteocorti";
    repo = "check_ssl_cert";
    tag = "v${version}";
    hash = "sha256-6j2+ScWgRDs/YaJzouzWQ92VlSty4juHKwo9/q/C+v0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "DESTDIR=$(out)/bin"
    "MANDIR=$(out)/share/man"
  ];

  postInstall = ''
    wrapProgram $out/bin/check_ssl_cert \
      --prefix PATH : "${
        lib.makeBinPath (
          [
            bc
            bind # host and dig binary
            coreutils # date and timeout binary
            curl
            file
            netcat-gnu
            nmap
            openssl
            python3
            which
          ]
          ++ lib.optional stdenv.hostPlatform.isLinux iproute2
        )
      }"
  '';

  meta = {
    description = "Nagios plugin to check the CA and validity of an X.509 certificate";
    homepage = "https://github.com/matteocorti/check_ssl_cert";
    changelog = "https://github.com/matteocorti/check_ssl_cert/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "check_ssl_cert";
  };
}
