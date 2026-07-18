{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fetchpatch,
  gettext,
  libtool,
  llvmPackages,
  python3,
  wrapGAppsHook3,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wxhexeditor";
  version = "0.24";

  src = fetchFromGitHub {
    owner = "EUA";
    repo = "wxHexEditor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EmdWYifwewk40s1TARYoUzx/qhyMmgmUC9tr5KKCtiM=";
  };

  patches = [
    # https://github.com/EUA/wxHexEditor/issues/90
    (fetchpatch {
      hash = "sha256-0m+dvsPlEoRnc22O73InR+NLPWb5JiSzEwdDmyE4i/E=";
      url = "https://github.com/EUA/wxHexEditor/commit/d0fa3ddc3e9dc9b05f90b650991ef134f74eed01.patch";
    })
    ./missing-semicolon.patch
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "/usr" "$out" \
      --replace-fail "mhash; ./configure" "mhash; ./configure --prefix=$out"
  ''
  + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace Makefile \
      --replace-fail "-lgomp" "-lomp"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    libtool
    python3
    wxwidgets_3_2
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  makeFlags = lib.optionals stdenv.cc.isGNU [
    "CFLAGS=-std=c17"
    "OPTFLAGS=-fopenmp"
  ];

  preConfigure = "patchShebangs .";

  meta = {
    description = "Hex Editor / Disk Editor for Huge Files or Devices";

    longDescription = ''
      This is not an ordinary hex editor, but could work as low level disk editor too.
      If you have problems with your HDD or partition, you can recover your data from HDD or
      from partition via editing sectors in raw hex.
      You can edit your partition tables or you could recover files from File System by hand
      with help of wxHexEditor.
      Or you might want to analyze your big binary files, partitions, devices... If you need
      a good reverse engineer tool like a good hex editor, you welcome.
      wxHexEditor could edit HDD/SDD disk devices or partitions in raw up to exabyte sizes.
    '';

    homepage = "http://www.wxhexeditor.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.unix;
    mainProgram = "wxHexEditor";
  };
})
