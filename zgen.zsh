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
    local location=${dir}/${file}

    # clone repo if not present
    if [[ ! -d "${dir}" ]]; then
        -zgen-clone "${repo}" "${dir}"
    fi

    # source the file
    if [[ -f "${location}" ]]; then
        -zgen-source "${location}"

    elif [[ -f "${location}/init.zsh" ]]; then
        -zgen-source "${location}/init.zsh"

    elif [[ -f "${location}.zsh-theme" ]]; then
        -zgen-source "${location}.zsh-theme"

    elif ls "${location}" | grep -l "\.plugin\.zsh" &> /dev/null; then
        for script (${location}/*\.plugin\.zsh(N)) -zgen-source "${script}"

    elif ls "${location}" | grep -l "\.zsh" &> /dev/null; then
        for script (${location}/*\.zsh(N)) -zgen-source "${script}"

    else
        echo "zgen: failed to load ${dir}"
    fi
}

zgen-saved() {
    [[ -f "${ZGEN_INIT}" ]] && return 0 || return 1
}

zgen-oh-my-zsh() {
    local repo="robbyrussell/oh-my-zsh"
    local file="${1:-oh-my-zsh.sh}"

    zgen-load "${repo}" "${file}"
}

zgen() {
    local cmd="${1}"
    if [[ -z "${cmd}" ]]; then
        echo "usage: zgen [load|oh-my-zsh|save|update]"
        return 1
    fi

    shift

    if functions "zgen-${cmd}" > /dev/null ; then
        "zgen-${cmd}" "${@}"
    else
        echo "zgen: command not found: ${cmd}"
    fi
}

_zgen() {
    compadd \
        load \
        oh-my-zsh \
        save \
        update
}

ZSH=$(-zgen-get-clone-dir "robbyrussell/oh-my-zsh")
if [[ -f "${ZGEN_INIT}" ]]; then
    source "${ZGEN_INIT}"
fi
compdef _zgen zgen
