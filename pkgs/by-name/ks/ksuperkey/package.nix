{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxi,
  libxtst,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ksuperkey";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "hanschen";
    repo = "ksuperkey";
    rev = "v${finalAttrs.version}";
    sha256 = "1dvgf356fihfav8pjzww1q6vgd96c5h18dh8vpv022g9iipiwq8a";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxtst
    xorgproto
    libxi
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Tool to be able to bind the super key as a key rather than a modifier";
    homepage = "https://github.com/hanschen/ksuperkey";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ksuperkey";
  };
})
