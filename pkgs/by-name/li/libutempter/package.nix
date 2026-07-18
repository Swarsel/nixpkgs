{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libutempter";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "altlinux";
    repo = "libutempter";
    tag = "${finalAttrs.version}-alt1";
    hash = "sha256-CiRZiEXzfOrtx1XXdMG2QZqzRtvY5mdA4SwTHRxkLUI=";
  };

  patches = [
    ./exec_path.patch
    (fetchpatch {
      hash = "sha256-4YaxgbORNm+rlp0YzYKj5a7/zJl1dxo72i/Rei9qulg=";
      name = "build-overwrite-already-existing-symlinks-during-ins.patch";
      url = "https://github.com/altlinux/libutempter/commit/717116b93d496a19f7f8abf8702517de0053f66e.patch";
    })
    ./Makefile-add-STATIC-and-DYNAMIC-build-variables.patch # https://github.com/altlinux/libutempter/pull/9
  ];

  buildInputs = [ glib ];

  makeFlags =
    lib.optionals stdenv.hostPlatform.isStatic [
      "DYNAMIC=0"
      "STATIC=1"
    ]
    ++ [
      "libdir=\${out}/lib"
      "libexecdir=\${out}/lib"
      "includedir=\${out}/include"
      "mandir=\${out}/share/man"
    ];

  patchFlags = [ "-p2" ];

  prePatch = ''
    substituteInPlace Makefile --replace 2711 0711
  '';

  sourceRoot = "${finalAttrs.src.name}/libutempter";

  meta = {
    description = "Interface for terminal emulators such as screen and xterm to record user sessions to utmp and wtmp files";

    longDescription = ''
      The bundled utempter binary must be able to run as a user belonging to group utmp.
      On NixOS systems, this can be achieved by creating a setguid wrapper.
    '';

    homepage = "https://github.com/altlinux/libutempter";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.msteen ];
    platforms = lib.platforms.linux;
  };
})
