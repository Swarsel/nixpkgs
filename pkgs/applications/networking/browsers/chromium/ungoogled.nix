{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  patch,
  python3Packages,
}:

{
  hash,
  rev,
}:

stdenv.mkDerivation {
  pname = "ungoogled-chromium";
  version = rev;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "ungoogled-software";
    repo = "ungoogled-chromium";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    python3Packages.python
    patch
  ];

  installPhase = ''
    mkdir $out
    cp -R * $out/
    wrapProgram $out/utils/patches.py --add-flags "apply" --prefix PATH : "${patch}/bin"
  '';

  dontBuild = true;

  patchPhase = ''
    sed -i '/chromium-widevine/d' patches/series
  '';
}
