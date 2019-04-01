# insta fail
set -e

# in case of a global installation, but who with sane mind would have done that
_yarn="yarn"
_dev=0
_debug=0

working_dir=${1%/} # remove trailing slash
if [ -z "$working_dir" ] && [ ! -d "$working_dir" ]; then
	echo "provide input directory"
	exit 1
fi

function process_circuit () {
	if [ ! $_debug -eq 0 ]; then
		echo "Processing $@"
	fi

	_circ_src=$1
	_basename=${_circ_src/\.circom/}
	_circ="$_basename.json"

	_pk="$_basename""_pk.json"
	_vk="$_basename""_vk.json"

	_input="$working_dir/input.json"

	_public="$_basename""_public.json"
	_proof="$_basename""_proof.json"
	_witness="$_basename""_witness.json"

	_verifier="$_basename""_verifier.sol"

	if [ ! $_dev -eq 0 ]; then
		echo "Received: $@"
		echo "$_yarn circom $_input -o $_circ"
		echo "$_yarn snarkjs setup -c $_circ --pk $_pk --vk $_vk"
		echo "$_yarn snarkjs calculatewitness -c $_circ -i $_input"
		echo "$_yarn snarkjs proof -w $_input --pk $_pk -p $_proof --pub $_public"
		echo "$_yarn snarkjs verify --vk $_vk -p $_proof --pub $_public"
		echo "$_yarn snarkjs generateverifier --vk $_vk -v $_verifier"
		exit 0
	fi

	$_yarn circom $_circ_src -o $_circ

	# just some info
	if [ ! $_debug -eq 0 ]; then
		$_yarn snarkjs info -c $_out_file
		$_yarn snarkjs printconstraints -c $_out_file
	fi

	# all files must be in the root directory or else it will fail,
	# requires $_out_file, outputs witness.json + proving_key.json + verification_key.json
	$_yarn snarkjs setup -c $_circ --pk $_pk --vk $_vk

	# requires input.json
	if [ ! -e $_input ]; then
		echo "no input.json for the circuit $_circ"
		exit 1
	fi
	$_yarn snarkjs calculatewitness -c $_circ -i $_input -w $_witness

	# requires proving_key.json + witness.json, outputs proof.json + public.json
	$_yarn snarkjs proof -w $_witness --pk $_pk -p $_proof --pub $_public

	# requires verification_key.json + proof.json + public.json
	$_yarn snarkjs verify --vk $_vk -p $_proof --pub $_public

	# solidity
	$_yarn snarkjs generateverifier --vk $_vk -v $_verifier
	$_yarn snarkjs generatecall -p $_proof --pub $_public
}

for inp_file in $working_dir/*.circom; do
	process_circuit $inp_file
done

