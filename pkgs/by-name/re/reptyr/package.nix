{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "reptyr";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "nelhage";
    repo = "reptyr";
    rev = "reptyr-${finalAttrs.version}";
    sha256 = "sha256-jlO/ykrwGJkgKiPxfRQEX4TSksrbPQhkQs+QddwqaQ4=";
  };

  makeFlags = [
    "PREFIX="
    "DESTDIR=$(out)"
  ];

  # reptyr needs to do ptrace of a non-child process
  # It can be neither used nor tested if the kernel is not told to allow this
  doCheck = false;

  meta = {
    description = "Reparent a running program to a new terminal";
    homepage = "https://github.com/nelhage/reptyr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ raskin ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
      "i686-freebsd"
      "x86_64-freebsd"
      "armv5tel-linux"
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
      "riscv64-linux"
    ];

    mainProgram = "reptyr";
  };
})
