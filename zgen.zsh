if [[ -z "${ZGEN_DIR}" ]]; then
    ZGEN_DIR="${HOME}/.zgen"
fi

if [[ -z "${ZGEN_INIT}" ]]; then
    ZGEN_INIT="${ZGEN_DIR}/init.zsh"
fi

if [[ -z "${ZGEN_LOADED}" ]]; then
    ZGEN_LOADED=()
fi

-zgen-get-clone-dir() {
    local repo=${1}

    echo "${ZGEN_DIR}/${repo}"
}

-zgen-get-clone-url() {
    local repo=${1}

    echo "https://github.com/${repo}.git"
}

-zgen-clone() {
    local repo=${1}
    local dir=${2}
    local url=$(-zgen-get-clone-url "${repo}")

    mkdir -p "${dir}"
    git clone "${url}" "${dir}"
}

-zgen-source() {
    local file="${1}"

    source "${file}"

    # add to the array if not loaded already
    if [[ ! "${ZGEN_LOADED[@]}" =~ ${file} ]]; then
        ZGEN_LOADED+="${file}"
    fi
}

zgen-update() {
    find "${ZGEN_DIR}" -maxdepth 2 -mindepth 2 -type d -exec \
        git --git-dir={}/.git --work-tree={} pull origin master \;
}

zgen-save() {
    if [[ -f "${ZGEN_INIT}" ]]; then
        rm "${ZGEN_INIT}"
    fi

    for file in "${ZGEN_LOADED[@]}"; do
        echo "-zgen-source \"$file\"" >> "${ZGEN_INIT}"
    done
}

zgen-load() {
    local repo=${1}
    local file=${2}
    local dir=$(-zgen-get-clone-dir "${repo}")

    # clone repo if not present
    if [[ ! -d "${dir}" ]]; then
        -zgen-clone "${repo}" "${dir}"
    fi

    # source the file
    if [[ -f "${dir}/${file}" ]]; then
        -zgen-source "${dir}/${file}"
    else
        echo "zgen: failed to load ${dir}"
    fi
}

zgen-load-oh-my-zsh() {
    local repo="robbyrussell/oh-my-zsh"
    local file="oh-my-zsh.sh"

    zgen-load "${repo}" "${file}"
}

zgen() {
    local cmd="${1}"
    if [[ -z "${cmd}" ]]; then
        echo "usage: zgen [load|load-oh-my-zsh|save|update]"
        return 1
    fi

    shift

    if functions "zgen-${cmd}" > /dev/null ; then
        "zgen-${cmd}" "${@}"
    else
        echo "zgen: command not found: ${cmd}"
    fi
}

ZSH=$(-zgen-get-clone-dir "robbyrussell/oh-my-zsh")
if [[ -f "${ZGEN_INIT}" ]]; then
    source "${ZGEN_INIT}"
fi
