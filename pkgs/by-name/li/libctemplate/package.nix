{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctemplate";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "OlafvdSpek";
    repo = "ctemplate";
    rev = "ctemplate-${finalAttrs.version}";
    sha256 = "1x0p5yym6vvcx70pm8ihnbxxrl2wnblfp72ih5vjyg8mzkc8cxrr";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    python3
    autoconf
    automake
    libtool
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = {
    description = "Simple but powerful template language for C++";

    longDescription = ''
      CTemplate is a simple but powerful template language for C++. It
      emphasizes separating logic from presentation: it is impossible to
      embed application logic in this template language.
    '';

    homepage = "https://github.com/OlafvdSpek/ctemplate";
    license = lib.licenses.bsd3;
  };
})
