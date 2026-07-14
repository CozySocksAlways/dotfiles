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

uenv() {
	uvenv "$@" &> /dev/null || return 1
	senv "$1"
}

# uv run
alias uvr='uv run'

# Start nvim as a server
alias nvs='nvim --listen /tmp/pdb_nvim -i NONE'

# Start pytest with custom debugger
npytest() {
    pytest --pdb --pdbcls=nvimpdb.debugger:NvimPdb -s "$@"
}

# Clean swap files
alias cleanswp='rm ~/.local/state/nvim/swap/*.sw?'

alias ied='nvim ~/.config/i3/config'


# Copy to clipboard
alias xcpy='wl-copy'

# lisa
alias lisa='(echo "inode blocks perms links owner group size date name"; ls -lisa)'
alias ll='ls -la'

# Quack quack
alias setspack='source /home/jos/repos/spack/v0.23.1/share/spack/setup-env.sh'

# Ninja build
alias nbuild='cmake -S . -B build -G Ninja && cmake --build build'

# Personal fox
alias pfox='setsid firefox -p Personal'

# Bat cat
alias batp='bat -pp'
alias batl='bat --pager=builtin'
alias bath='bat --style=header'

# Up a dir
alias ..='cd ..'
alias ...='cd ../..'

# Make a venv with pip
alias penv='python -m venv .venv && source .venv/bin/activate'
alias prenv='rm -rf .venv'

# wayland "xrandr"
alias wrandr='swaymsg -t get_outputs'

# open all modified files in a git repo
# alias sopen="git status --porcelain | awk -F ' ' '{print $2}' | xargs nvim"

# View all logs
# gh run view 26870424046 --json jobs | jq -r '.jobs[].databaseId' | xargs -I{} gh run view --job {}


# Docker
drun() {
	if (($# < 4)); then
		cat <<'EOF'
	Usage:
		drun src dst image command
	Example:
		drun . /scratch bash -c 'echo hello'
EOF
		return 0
	fi

	local src dst image
	src=$(realpath "$1")
	dst=$2
	image=$3
	shift 3 # Shift positional argument
	docker run \
			--rm \
			--mount type=bind,src="$src",dst="$dst" \
			--user $(id -u):$(id -g) \
			"$image" \
			"$@"
}

alias history='history | less'

# Diff
alias diff='diff -u --color'
