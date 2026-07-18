{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  ffmpeg-headless,
  nixosTests,
  python3Packages,
}:
let
  pname = "open-webui";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-tJ9b5up5FoX5TrmpwMWevyA/o3Ai/lKsHu+nahc2Ttc=";
  };

  frontend = buildNpmPackage rec {
    inherit version src;
    pname = "open-webui-frontend";

    # Disabling `pyodide:fetch` as it downloads packages during `buildPhase`
    # Until this is solved, running python packages from the browser will not work.
    postPatch = ''
      substituteInPlace package.json \
        --replace-fail "npm run pyodide:fetch && vite build" "vite build"
    '';

    propagatedBuildInputs = [
      ffmpeg-headless
    ];

    npmDepsHash = "sha256-yw/1n1jBCUtt8wUqJmIkB3W53wsXTKuAFG/EMwcTpx8=";
    env.CYPRESS_INSTALL_BINARY = "0"; # disallow cypress from downloading binaries in sandbox
    env.NODE_OPTIONS = "--max-old-space-size=8192";
    env.ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";

    preBuild = ''
      tar xf ${pyodide} -C static/
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a build $out/share/open-webui

      runHook postInstall
    '';

    npmFlags = [ "--force" ];

    pyodide = fetchurl {
      hash = "sha256-fcqubT8VmGoJ8PnmxHE6DA8kv/DJDHToWoFyPxvGCUA=";
      url = "https://github.com/pyodide/pyodide/releases/download/${pyodideVersion}/pyodide-${pyodideVersion}.tar.bz2";
    };

    # the backend for run-on-client-browser python execution
    # must match the version that is locked in package-lock.json
    pyodideVersion = "0.28.3";
  };
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit pname version src;

  # Not force-including the frontend build directory as frontend is managed by the `frontend` derivation above.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', build = "open_webui/frontend"' ""
  '';

  env.HATCH_BUILD_NO_HOOKS = true;
  build-system = with python3Packages; [ hatchling ];

  dependencies =
    with python3Packages;
    [
      accelerate
      aiocache
      aiofiles
      aiohttp
      aiosqlite
      alembic
      anthropic
      apscheduler
      argon2-cffi
      asgiref
      async-timeout
      authlib
      azure-ai-documentintelligence
      azure-identity
      azure-storage-blob
      bcrypt
      beautifulsoup4
      black
      boto3
      brotli
      brotlicffi
      chardet
      chromadb
      cryptography
      datasets_3
      ddgs
      docx2txt
      einops
      fake-useragent
      fastapi
      faster-whisper
      fpdf2
      ftfy
      google-api-python-client
      google-auth-httplib2
      google-auth-oauthlib
      google-cloud-storage
      google-genai
      googleapis-common-protos
      httpx
      itsdangerous
      langchain
      langchain-classic
      langchain-community
      langchain-text-splitters
      ldap3
      loguru
      markdown
      mcp
      msoffcrypto-tool
      nltk
      onnxruntime
      openai
      opencv-python-headless
      opentelemetry-api
      opentelemetry-exporter-otlp
      opentelemetry-instrumentation
      opentelemetry-instrumentation-aiohttp-client
      opentelemetry-instrumentation-fastapi
      opentelemetry-instrumentation-httpx
      opentelemetry-instrumentation-logging
      opentelemetry-instrumentation-redis
      opentelemetry-instrumentation-requests
      opentelemetry-instrumentation-sqlalchemy
      opentelemetry-sdk
      openpyxl
      opensearch-py
      pandas
      pillow
      psutil
      psycopg
      pyarrow
      pycrdt
      pydub
      pyjwt
      pymdown-extensions
      pymysql
      pypandoc
      pypdf
      python-dotenv
      python-jose
      python-mimeparse
      python-multipart
      python-pptx
      python-socketio
      pytube
      pytz
      pyxlsb
      rank-bm25
      rapidocr-onnxruntime
      redis
      requests
      restrictedpython
      sentence-transformers
      sentencepiece
      soundfile
      sqlalchemy
      starlette-compress
      starsessions
      tiktoken
      transformers
      uvicorn
      validators
      xlrd
      youtube-transcript-api
    ]
    ++ psycopg.optional-dependencies.c
    ++ pyjwt.optional-dependencies.crypto
    ++ sqlalchemy.optional-dependencies.asyncio
    ++ starsessions.optional-dependencies.redis;

  makeWrapperArgs = [ "--set FRONTEND_BUILD_DIR ${frontend}/share/open-webui" ];

  optional-dependencies = with python3Packages; {
    all = [
      azure-search-documents
      colbert-ai
      elasticsearch
      gcp-storage-emulator
      moto
      oracledb
      pinecone-client
      playwright
      pymilvus
      pymongo
      qdrant-client
      weaviate-client
    ]
    ++ finalAttrs.passthru.optional-dependencies.mariadb
    ++ finalAttrs.passthru.optional-dependencies.postgres
    ++ finalAttrs.passthru.optional-dependencies.unstructured
    ++ moto.optional-dependencies.s3;

    mariadb = [
      mariadb
    ];

    postgres = [
      pgvector
      psycopg2-binary
    ];

    unstructured = [
      unstructured
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "open_webui" ];
  pythonRelaxDeps = true;

  passthru = {
    inherit frontend;

    tests = {
      inherit (nixosTests) open-webui;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Comprehensive suite for LLMs with a user-friendly WebUI";

    longDescription = ''
      User-friendly WebUI for LLMs. Note on licensing: Code in Open WebUI prior
      to version 0.5.5 was MIT licensed. Since version 0.6.6, the project has
      adopted a modified BSD-3-Clause license that includes branding requirements
      and whose relicensing process from MIT has raised concerns within the community.
      Nixpkgs treats this custom license as non-free due to these factors.
    '';

    homepage = "https://github.com/open-webui/open-webui";
    changelog = "https://github.com/open-webui/open-webui/blob/${src.tag}/CHANGELOG.md";

    # License history is complex: originally MIT, then a potentially problematic
    # relicensing to a modified BSD-3 clause occurred around v0.5.5/v0.6.6.
    # Due to these concerns and non-standard terms, it's treated as custom non-free.
    license = {
      # Marked non-free due to concerns over the MIT -> modified BSD-3 relicensing process,
      # potentially unclear/contradictory statements, and non-standard branding requirements.
      free = false;
      fullName = "Open WebUI License";
      url = "https://github.com/open-webui/open-webui/blob/0cef844168e97b70de2abee4c076cc30ffec6193/LICENSE";
    };

    maintainers = with lib.maintainers; [
      shivaraj-bh
      codgician
    ];

    mainProgram = "open-webui";
  };
})
