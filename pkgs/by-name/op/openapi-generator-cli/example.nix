{
  fetchurl,
  formats,
  openapi-generator-cli,
  runCommand,
}:

runCommand "openapi-generator-cli-test"
  {
    nativeBuildInputs = [ openapi-generator-cli ];

    config = (formats.json { }).generate "config.json" {
      elmPrefixCustomTypeVariants = false;
      elmVersion = "0.19";
    };

    petstore = fetchurl {
      hash = "sha256-q2D1naR41KwxLNn6vMbL0G+Pl1q4oaDCApsqQfZf7dU=";
      url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/14c0908becbccd78252be49bd92be8c53cd2b9e3/examples/v3.0/petstore.yaml";
    };
  }
  ''
    openapi-generator-cli generate \
      --input-spec $petstore \
      --enable-post-process-file \
      --generator-name elm \
      --config "$config" \
      --additional-properties elmEnableCustomBasePaths=true \
      --output "$out" \
      ;
    find $out
    echo >&2 'Looking for some keywords'
    set -x
    grep 'module Api.Request.Pets' $out/src/Api/Request/Pets.elm
    grep 'createPets' $out/src/Api/Request/Pets.elm
    grep '"limit"' $out/src/Api/Request/Pets.elm
    set +x
    echo "Looks OK!"
  ''
