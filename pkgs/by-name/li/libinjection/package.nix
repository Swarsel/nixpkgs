{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libinjection";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "client9";
    repo = "libinjection";
    tag = "v${finalAttrs.version}";
    sha256 = "0chsgam5dqr9vjfhdcp8cgk7la6nf3lq44zs6z6si98cq743550g";
  };

  # no binaries, so out = library, dev = headers
  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-SPdf57FIDDNpatWe5pjhAiZl5yPMDEv50k0Wj+eWTEM=";
      name = "support-python3-for-building";
      url = "https://raw.githubusercontent.com/sysown/proxysql/bed58f92917eb651b80fd8ffa627a485eb320805/deps/libinjection/update-build-py3.diff";
    })
  ];

  postPatch = ''
    patchShebangs src
    substituteInPlace src/Makefile \
      --replace /usr/local $out
  '';

  strictDeps = true;
  nativeBuildInputs = [ python3 ];
  buildPhase = "make all";
  configurePhase = "cd src";

  meta = {
    description = "SQL / SQLI tokenizer parser analyzer";
    homepage = "https://github.com/client9/libinjection";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
})
