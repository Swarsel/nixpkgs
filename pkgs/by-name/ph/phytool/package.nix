{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "phytool";
  version = "2-unstable-2024-07-14";

  src = fetchFromGitHub {
    owner = "wkz";
    repo = "phytool";
    rev = "bcf23b0261aa9f352ee4b944e30e3482158640a4";
    hash = "sha256-8e2DVjG/2CtJ/+FLzMa1VKajJZfFqjD54XQAMY+0q3U=";
  };

  strictDeps = true;

  makeFlags = [
    "PREFIX=$(out)"
  ];

  preInstall = ''
    mkdir -p "$out/bin"
  '';

  __structuredAttrs = true;

  meta = {
    description = "Linux MDIO register access";
    homepage = "https://github.com/wkz/phytool";
    changelog = "https://github.com/wkz/phytool/releases";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.connorbaker ];
  };
}
