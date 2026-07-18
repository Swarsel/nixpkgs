{
  image,
  invisible-watermark,
  opencv4,
  python,
  runCommand,
  stdenvNoCC,
}:

# This test checks if the python code shown in the README works correctly

let
  message = "fnörd1";
  method = "dwtDct";

  pythonWithPackages = python.withPackages (_: [
    invisible-watermark
    opencv4
  ]);
  pythonInterpreter = pythonWithPackages.interpreter;

  encode = stdenvNoCC.mkDerivation {
    inherit image message method;
    args = [ ./encode.py ];
    name = "encode";
    realBuilder = pythonInterpreter;
  };

  decode = stdenvNoCC.mkDerivation {
    inherit method;
    args = [ ./decode.py ];
    image = "${encode}/test_wm.png";
    name = "decode";
    num_bits = (builtins.stringLength message) * 8;
    realBuilder = pythonInterpreter;
  };
in
runCommand "invisible-watermark-test-python" { } ''
  decoded_message="$(cat '${decode}')"
  if [ '${message}' != "$decoded_message" ]; then
    echo "invisible-watermark did not decode the watermark correctly."
    echo "The original message was ${message} but the decoded message was $decoded_message."
    exit 1
  fi
  touch "$out"
''
