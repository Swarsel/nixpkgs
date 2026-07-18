{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rabbitmq-c";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "alanxz";
    repo = "rabbitmq-c";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uOI+YV9aV/LGlSxr75sSii5jQ005smCVe14QAGNpKY8=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "RabbitMQ C AMQP client library";
    homepage = "https://github.com/alanxz/rabbitmq-c";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "librabbitmq" ];
  };
})
