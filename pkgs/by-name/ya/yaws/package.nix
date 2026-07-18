{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  beamPackages,
  pam,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yaws";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "erlyaws";
    repo = "yaws";
    rev = "yaws-${finalAttrs.version}";
    hash = "sha256-acO8Vc8sZJl22HUml2kTxVswLEirqMbqHQdRIbkkcvs=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    beamPackages.erlang
    pam
    perl
  ];

  configureFlags = [ "--with-extrainclude=${pam}/include/security" ];

  postInstall = ''
    sed -i "s#which #type -P #" $out/bin/yaws
  '';

  meta = {
    description = "Webserver for dynamic content written in Erlang";
    homepage = "https://github.com/erlyaws/yaws";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "yaws";
  };

})
