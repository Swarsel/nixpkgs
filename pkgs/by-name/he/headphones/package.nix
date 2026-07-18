{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "headphones";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "rembo10";
    repo = "headphones";
    rev = "v${finalAttrs.version}";
    sha256 = "0gv7rasjbm4rf9izghibgf5fbjykvzv0ibqc2in1naagjivqrpq4";
  };

  nativeBuildInputs = [ makeWrapper ];
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/headphones
    cp -R {data,headphones,lib,Headphones.py} $out/opt/headphones

    echo v${finalAttrs.version} > $out/opt/headphones/version.txt

    makeWrapper $out/opt/headphones/Headphones.py $out/bin/headphones

    runHook postInstall
  '';

  dontBuild = true;
  pyproject = false;

  meta = {
    description = "Automatic music downloader for SABnzbd";
    homepage = "https://github.com/rembo10/headphones";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rembo10 ];
    mainProgram = "headphones";
  };
})
