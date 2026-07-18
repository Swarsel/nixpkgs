{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  curl,
  gnused,
  jq,
  makeBinaryWrapper,
  python3,
  scitokens-cpp,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "htgettoken";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "fermitools";
    repo = "htgettoken";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jHKKTnFZ+6LHaB61wi5+Ht6ZHrE4dDqADIMfGWI47oM=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildInputs = [
    bash
    curl
    coreutils
    jq
    scitokens-cpp
  ];

  postInstall = ''
    wrapProgram $out/bin/htdecodetoken \
        --prefix PATH : ${
          lib.makeBinPath [
            coreutils
            jq
            scitokens-cpp
          ]
        }
    wrapProgram $out/bin/htdestroytoken \
        --prefix PATH : $out/bin:${
          lib.makeBinPath [
            coreutils
            curl
          ]
        }
    wrapProgram $out/bin/httokensh \
        --prefix PATH : $out/bin:${
          lib.makeBinPath [
            coreutils
            gnused
            jq
          ]
        }
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    gssapi
    paramiko
    urllib3
  ];

  pyproject = true;

  meta = {
    description = "Gets OIDC authentication tokens for High Throughput Computing via a Hashicorp vault server ";
    homepage = "https://github.com/fermitools/htgettoken";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
