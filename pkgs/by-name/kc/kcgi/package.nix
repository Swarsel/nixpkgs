{
  lib,
  stdenv,
  fetchFromGitHub,
  libbsd,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "kcgi";
  version = "0.10.8";

  src = fetchFromGitHub {
    owner = "kristapsdz";
    repo = "kcgi";
    rev = "VERSION_${underscoreVersion}";
    sha256 = "0ha6r7bcgf6pcn5gbd2sl7835givhda1jql49c232f1iair1yqyp";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ] ++ lib.optionals stdenv.hostPlatform.isLinux [ libbsd ];
  dontAddPrefix = true;
  installFlags = [ "DESTDIR=$(out)" ];

  patchPhase = ''
    substituteInPlace configure \
      --replace /usr/local /
  '';

  underscoreVersion = lib.replaceStrings [ "." ] [ "_" ] version;

  meta = {
    description = "Minimal CGI and FastCGI library for C/C++";
    homepage = "https://kristaps.bsd.lv/kcgi";
    license = lib.licenses.isc;
    platforms = lib.platforms.all;
    mainProgram = "kfcgi";
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
}
