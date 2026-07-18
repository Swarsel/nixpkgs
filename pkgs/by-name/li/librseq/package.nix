{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  linuxHeaders,
}:

stdenv.mkDerivation rec {
  pname = "librseq";
  version = "0.1.0pre71_${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "compudj";
    repo = "librseq";
    rev = "170f840b498e1aff068b90188727a656111bfc2f";
    sha256 = "0rdx59y8y9x8cfmmx5gl66gibkzpk3kw5lrrqhrxan8zr37a055y";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ linuxHeaders ];
  doCheck = true;

  # The share/ subdir only contains a doc/ with a README.md that just describes
  # how to compile the library, which clearly isn't very useful! So just get
  # rid of it anyway.
  postInstall = ''
    rm -rf $out/share
  '';

  enableParallelBuilding = true;

  installTargets = [
    "install"
    "install-man"
  ];

  patchPhase = ''
    patchShebangs tests
  '';

  separateDebugInfo = true;

  meta = {
    description = "Userspace library for the Linux Restartable Sequence API";
    homepage = "https://github.com/compudj/librseq";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.linux;
  };
}
