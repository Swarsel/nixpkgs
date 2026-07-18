{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beanstalkd";
  version = "1.13";

  src = fetchFromGitHub {
    owner = "beanstalkd";
    repo = "beanstalkd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xoudhPad4diGGE8iZaY1/4LiENlKT2dYcIR6wlQdlTU=";
  };

  patches = [
    # Fix build with GCC 15, remove after next update
    (fetchpatch {
      hash = "sha256-QDDypvrQtjlG7iPE0GfvpZMActIw1gRx36+BpZ6WjMw=";
      url = "https://github.com/beanstalkd/beanstalkd/commit/85070765.patch";
    })
  ];

  nativeBuildInputs = [ installShellFiles ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    installManPage doc/beanstalkd.1
  '';

  hardeningDisable = [ "fortify" ];

  passthru.tests = {
    smoke-test = nixosTests.beanstalkd;
  };

  meta = {
    description = "Simple, fast work queue";
    homepage = "http://kr.github.io/beanstalkd/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.zimbatm ];
    platforms = lib.platforms.all;
    mainProgram = "beanstalkd";
  };
})
