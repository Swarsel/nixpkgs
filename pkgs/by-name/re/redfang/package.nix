{
  lib,
  stdenv,
  fetchFromGitLab,
  bluez,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "redfang";
  version = "2.5";

  src = fetchFromGitLab {
    owner = "packages";
    repo = "redfang";
    rev = "upstream/${finalAttrs.version}";
    hash = "sha256-dF9QmBckyHAZ+JbLr0jTmp0eMu947unJqjrTMsJAfIE=";
    group = "kalilinux";
  };

  patches = [
    # make install rule
    (fetchpatch {
      sha256 = "sha256-oxIrUAucxsBL4+u9zNNe2XXoAd088AEAHcRB/AN7B1M=";
      url = "https://gitlab.com/kalilinux/packages/redfang/-/merge_requests/1.diff";
    })
    # error: implicit declaration of function 'pthread_create' []
    ./include-pthread.patch
  ];

  buildInputs = [ bluez ];
  env.NIX_CFLAGS_COMPILE = "-Wno-format-security";
  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Small proof-of-concept application to find non discoverable bluetooth devices";
    homepage = "https://gitlab.com/kalilinux/packages/redfang";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ moni ];
    mainProgram = "fang";
  };
})
