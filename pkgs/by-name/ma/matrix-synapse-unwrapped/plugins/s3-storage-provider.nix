{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  humanize,
  matrix-synapse-unwrapped,
  psycopg2,
  tqdm,
  twisted,
}:

buildPythonPackage rec {
  pname = "matrix-synapse-s3-storage-provider";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "synapse-s3-storage-provider";
    tag = "v${version}";
    hash = "sha256-vRDjN9BDp7Rta/F91OVEH8FWyiwxR67PQSqBCs3bDkM=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "humanize>=0.5.1,<0.6" "humanize>=0.5.1"
  '';

  buildInputs = [
    matrix-synapse-unwrapped
  ];

  propagatedBuildInputs = [
    boto3
    humanize
    tqdm
    twisted
    psycopg2
  ]
  # For the s3_media_upload script
  ++ matrix-synapse-unwrapped.propagatedBuildInputs;

  # Tests need network access
  doCheck = false;
  format = "setuptools";

  pythonImportsCheck = [
    "s3_storage_provider"
  ];

  meta = {
    description = "Synapse storage provider to fetch and store media in Amazon S3";
    homepage = "https://github.com/matrix-org/synapse-s3-storage-provider";
    changelog = "https://github.com/matrix-org/synapse-s3-storage-provider/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "s3_media_upload";
  };
}
