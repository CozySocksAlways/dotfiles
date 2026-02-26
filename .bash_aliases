senv() {
	if [[ -f "$1/bin/activate" ]]; then
		source "$1/bin/activate"
	else
		echo "No venv found at $1"
		return 1
	fi
}

alias python='python3'
alias py='python'

uvenv() {
	VENV_NAME="$1"
	DOCSTRING="${2:-''}" # default to empty

	if [ -z "$VENV_NAME" ]; then
		echo "use: uvenv <env name> [docstring]"
		return 1
	fi

	# create env, if fail return 1
	uv venv "$VENV_NAME" || return 1

	# create doc file
	DOC_PATH="$(pwd)/$VENV_NAME/doc.md"
	echo "$DOCSTRING" > "$DOC_PATH"
}


# Start nvim as a server
alias nvs='nvim --listen /tmp/pdb_nvim -i NONE'

# Start pytest with custom debugger
npytest() {
    pytest --pdb --pdbcls=nvimpdb.debugger:NvimPdb -s "$@"
}

# Clean swap files
alias cleanswp='rm ~/.local/state/nvim/swap/*.sw?'

alias ied='nvim ~/.config/i3/config'
