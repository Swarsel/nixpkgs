{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildNpmPackage rec {
  pname = "mailsy";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "BalliAsghar";
    repo = "Mailsy";
    rev = version;
    hash = "sha256-RnOWvu023SOcN83xEEkYFwgDasOmkMwSzJ/QYjvTBDo=";
  };

  postPatch = ''
    substituteInPlace utils/index.js \
    --replace-fail 'dirname, "../data/account.json"' 'process.cwd(), "account.json"' \
    --replace-fail 'dirname, "../data/email.html"' 'process.cwd(), "email.html"'
  '';

  npmDepsHash = "sha256-ljmqNmLvRHPdsKyOdDfECBXHTIExM6nPZF45lqV+pDM=";
  dontNpmBuild = true;
  npmFlags = [ "--legacy-peer-deps" ];

  meta = {
    description = "Quickly generate a disposable email straight from terminal";
    homepage = "https://fig.io/manual/mailsy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers._404wolf ];
    mainProgram = "mailsy";
  };
}
