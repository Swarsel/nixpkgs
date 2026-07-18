{
  lib,
  autoconf,
  autogen,
  automake,
  clangStdenv,
  fetchFromGitea,
  gitUpdater,
  objfw,
  writeTextDir,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "objfw";
  version = "1.5.7";

  src = fetchFromGitea {
    owner = "ObjFW";
    repo = "ObjFW";
    rev = "${finalAttrs.version}-release";
    hash = "sha256-3MdQG2pVjlBdbmBzTrrKdkbSzsvjZWZRoSPsN+MURCQ=";
    domain = "git.nil.im";
  };

  nativeBuildInputs = [
    automake
    autogen
    autoconf
  ];

  configureFlags = [
    "--without-tls"
  ];

  preConfigure = "./autogen.sh";
  doCheck = true;

  passthru.tests = {
    build-hello-world = (import ./test-build-and-run.nix) { inherit clangStdenv objfw writeTextDir; };
  };

  passthru.updateScript = gitUpdater { rev-suffix = "-release"; };

  meta = {
    description = "Portable framework for the Objective-C language";
    homepage = "https://objfw.nil.im";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.steeleduncan ];
    platforms = lib.platforms.linux;
  };
})
