{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  docutils,
  ncurses,
  pkg-config,
  python3,
  swig,
  talloc,
  enablePython ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proot";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "proot-me";
    repo = "proot";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Z9Y7ccWp5KEVuo9xfHcgo58XqYVdFo7ck1jH7cnT2KA=";
  };

  postPatch = ''
    substituteInPlace src/GNUmakefile \
      --replace /bin/echo ${coreutils}/bin/echo
    # our cross machinery defines $CC and co just right
    sed -i /CROSS_COMPILE/d src/GNUmakefile
  '';

  nativeBuildInputs = [
    pkg-config
    docutils
  ]
  ++ lib.optional enablePython swig;

  buildInputs = [
    ncurses
    talloc
  ]
  ++ lib.optional enablePython python3;

  makeFlags = [ "--directory=src" ];

  postBuild = ''
    make --directory=doc proot/man.1
  '';

  # proot provides tests with `make -C test` however they do not run in the sandbox
  doCheck = false;

  postInstall = ''
    install -Dm644 doc/proot/man.1 $out/share/man/man1/proot.1
  '';

  enableParallelBuilding = true;
  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "User-space implementation of chroot, mount --bind and binfmt_misc";
    homepage = "https://proot-me.github.io";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      ianwookim
      makefu
      veprbl
    ];

    platforms = lib.platforms.linux;
    mainProgram = "proot";
  };
})
