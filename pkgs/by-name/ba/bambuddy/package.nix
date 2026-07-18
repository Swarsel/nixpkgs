{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  ffmpeg,
  makeWrapper,
  python3,
}:
let
  version = "0.2.4.8";

  src = fetchFromGitHub {
    owner = "maziggy";
    repo = "bambuddy";
    tag = "v${version}";
    hash = "sha256-6qeIidvi62NUok7I9UQ8DblT0/Wscju4FMnVuPXzMdM=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "bambuddy-frontend";
    npmDepsHash = "sha256-/22FkXus5f3wYivyadZWU6ZKPYFLF8xA8mkVGxvdXm0=";
    preBuild = "chmod -R u+w ../static";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ../static/. $out/

      runHook postInstall
    '';

    sourceRoot = "${src.name}/frontend";
  };

  # https://github.com/maziggy/bambuddy/blob/main/requirements.txt
  python = python3.withPackages (
    ps: with ps; [
      aiofiles
      aioftp
      aiosqlite
      asyncpg
      asyncssh
      bcrypt
      cryptography
      curl-cffi
      defusedxml
      fastapi
      fast-simplification
      greenlet
      httpx
      ldap3
      lxml
      matplotlib
      networkx
      numpy
      opencv4
      openpyxl
      paho-mqtt
      passlib
      pillow
      psutil
      pydantic
      pydantic-settings
      pyftpdlib
      pyjwt
      pyopenssl
      pyotp
      python-multipart
      pywebpush
      qrcode
      reportlab
      sqlalchemy
      trimesh
      uvicorn
      websockets
    ]
  );
in
stdenv.mkDerivation {
  inherit version src;
  pname = "bambuddy";
  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/bambuddy
    cp -r . $out/lib/bambuddy/

    rm -rf $out/lib/bambuddy/static
    ln -s ${frontend} $out/lib/bambuddy/static

    mkdir -p $out/bin

    makeWrapper ${lib.getExe' python "uvicorn"} $out/bin/bambuddy \
      --chdir "$out/lib/bambuddy" \
      --prefix PYTHONPATH : "$out/lib/bambuddy" \
      --prefix PATH : ${ffmpeg}/bin \
      --add-flags "backend.app.main:app"

    runHook postInstall
  '';

  __structuredAttrs = true;

  meta = {
    description = "Self-hosted command center for Bambu Lab";
    homepage = "https://bambuddy.cool/";
    changelog = "https://github.com/maziggy/bambuddy/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ onatustun ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "bambuddy";
  };
}
