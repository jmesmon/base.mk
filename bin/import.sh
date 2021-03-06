set -euf
d="$(dirname $0)/.."
f="$d/$F"

if ! [ -e "$f" ]; then
	# TODO: fall back on /usr/share or some crap
	echo "Can't find \"$f\""
	exit 1
fi

i () {
	local sd="$1" # source dir
	local dd="$2" # dest dir
	local fn="$3" # file name

	local i="$dd/$fn" # destination
	local f="$sd/$fn" # source
	local d="$sd" # source git tree for versioning

	if [ "$(readlink -e "$f")" = "$(readlink -e "$i")" ]; then
		echo "ERR: refusing to overwrite source, \"$(readlink -e "$f")\""
		exit 1
	fi

	if [ "$fn" = "$F" ] && ! [ -e "$i" ]; then
		# Confirm new install.
		echo "This looks like a new install in"
		echo "    $PWD"
		printf "Are you sure you want to continue? [Yn]"
		read res
		[ -z "$res" ] && res=y
		case "$res" in
		y*|Y*) ;;
		*)  exit 1;
		esac
	fi

	local hash=$(cd $d; git show --pretty=format:%H $fn)
	local ver=$(cd $d; git describe --always --dirty=+)
	local tmp=`mktemp --tmpdir base.mk.XXXXXXXXX`

	echo "## $fn: $ver, see $URL" >>$tmp
	cat "$f" >>$tmp

	mv "$tmp" "$i"
}

f () {
	i "$d" . "$1"
}

D () {
	rsync -r  "$d/$1/" "$1/"
}

