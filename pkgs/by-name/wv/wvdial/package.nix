{
  lib,
  stdenv,
  fetchFromGitea,
  fetchpatch,
  pkg-config,
  wvstreams,
}:

stdenv.mkDerivation {
  pname = "wvdial";
  version = "unstable-2016-06-15";

  src = fetchFromGitea {
    owner = "retronetworking";
    repo = "wvdial";
    rev = "42d084173cc939586c1963b8835cb00ec56b2823";
    hash = "sha256-q7pFvpJvv+ZvbN4xxolI9ZRULr+N5sqO9BOXUqSG5v4=";
    domain = "gitea.osmocom.org";
    # "download .tar.gz" has been disabled
    forceFetchGit = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-fsneoB5GeKH/nxwW0z8Mk6892PtnZ3J77wP4BGo3Tj8=";
      url = "https://git.openembedded.org/meta-openembedded/plain/meta-oe/recipes-connectivity/wvdial/wvdial/typo_pon.wvdial.1.patch?h=73a68490efe05cdbec540ec6f17782816632a24d";
    })
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ wvstreams ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "PPPDIR=${placeholder "out"}/etc/ppp/peers"
  ];

  meta = {
    description = "Dialer that automatically recognises the modem";
    homepage = "https://gitea.osmocom.org/retronetworking/wvdial";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ flokli ];
    platforms = lib.platforms.linux;
  };
}
