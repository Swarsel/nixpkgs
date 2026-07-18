{
  lib,
  stdenv,
  fetchFromGitHub,
  perl, # for tests
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nq";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "leahneukirchen";
    repo = "nq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gdVBSE2a4rq46o0uO9ICww6zicVgn6ykf4CeJ/MmiF4=";
  };

  postPatch = ''
    sed -i nqterm \
      -e 's|\bnq\b|'$out'/bin/nq|g' \
      -e 's|\bnqtail\b|'$out'/bin/nqtail|g'
  '';

  makeFlags = [ "PREFIX=$(out)" ];
  doCheck = true;
  nativeCheckInputs = [ perl ];

  meta = {
    description = "Unix command line queue utility";
    homepage = "https://github.com/leahneukirchen/nq";
    changelog = "https://github.com/leahneukirchen/nq/blob/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.publicDomain;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
