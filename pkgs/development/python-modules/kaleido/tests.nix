{
  kaleido,
  pandas,
  plotly,
  python,
  runCommand,
}:

runCommand "${kaleido.pname}-tests" {
  nativeBuildInputs = [
    python
    plotly
    pandas
    kaleido
  ];
} "python3 ${./tests.py}"
