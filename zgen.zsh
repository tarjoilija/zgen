autoload -U compinit
compinit

local ZGEN_SOURCE=$(dirname $0)

if [[ -z "${ZGEN_DIR}" ]]; then
    ZGEN_DIR="${HOME}/.zgen"
fi

if [[ -z "${ZGEN_INIT}" ]]; then
    ZGEN_INIT="${ZGEN_DIR}/init.zsh"
fi

if [[ -z "${ZGEN_LOADED}" ]]; then
    ZGEN_LOADED=()
fi

if [[ -z "${ZGEN_COMPLETIONS}" ]]; then
    ZGEN_COMPLETIONS=()
fi

-zgen-get-clone-dir() {
    local repo=${1}

    if [ -d "${repo}/.git" ]; then
        echo "${ZGEN_DIR}/local/$(basename ${repo})"
    else
        echo "${ZGEN_DIR}/${repo}"
    fi
}

-zgen-get-clone-url() {
    local repo=${1}

    if [ -d "${repo}/.git" ]; then
        echo ${repo}
    else
        echo "https://github.com/${repo}.git"
    fi
}

-zgen-clone() {
    local repo=${1}
    local dir=${2}
    local url=$(-zgen-get-clone-url "${repo}")

    mkdir -p "${dir}"
    git clone "${url}" "${dir}"
    echo
}

-zgen-source() {
    local file="${1}"

    source "${file}"

    # add to the array if not loaded already
    if [[ ! "${ZGEN_LOADED[@]}" =~ ${file} ]]; then
        ZGEN_LOADED+="${file}"
    fi

    completion_path=$(dirname ${file})
    # Add the directory to ZGEN_COMPLETIONS array if not there already
    if [[ ! "${ZGEN_COMPLETIONS[@]}" =~ ${completion_path} ]]; then
        ZGEN_COMPLETIONS+="${completion_path}"
    fi
}

zgen-update() {
    find "${ZGEN_DIR}" -maxdepth 2 -mindepth 2 -type d -exec \
        git --git-dir={}/.git --work-tree={} pull origin master \;

    if [[ -f "${ZGEN_INIT}" ]]; then
        rm "${ZGEN_INIT}"
    fi
}

zgen-save() {
    if [[ -f "${ZGEN_INIT}" ]]; then
        rm "${ZGEN_INIT}"
    fi

    for file in "${ZGEN_LOADED[@]}"; do
        echo "-zgen-source \"$file\"" >> "${ZGEN_INIT}"
    done

    # Set up fpath
    echo "fpath=(\$fpath $ZGEN_COMPLETIONS )" >> ${ZGEN_INIT}
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

    # Prezto modules have init.zsh files
    elif [[ -f "${location}/init.zsh" ]]; then
        -zgen-source "${location}/init.zsh"

    elif [[ -f "${location}.zsh-theme" ]]; then
        -zgen-source "${location}.zsh-theme"

    elif [[ -f "${location}.zshplugin" ]]; then
        -zgen-source "${location}.zshplugin"

    elif [[ -f "${location}.zsh.plugin" ]]; then
        -zgen-source "${location}.zsh.plugin"

    # Classic oh-my-zsh plugins have foo.plugin.zsh
    elif ls "${location}" | grep -l "\.plugin\.zsh" &> /dev/null; then
        for script (${location}/*\.plugin\.zsh(N)) -zgen-source "${script}"

    elif ls "${location}" | grep -l "\.zsh" &> /dev/null; then
        for script (${location}/*\.zsh(N)) -zgen-source "${script}"

    elif ls "${location}" | grep -l "\.sh" &> /dev/null; then
        for script (${location}/*\.sh(N)) -zgen-source "${script}"

    else
        echo "zgen: failed to load ${dir}"
    fi
}

zgen-saved() {
    [[ -f "${ZGEN_INIT}" ]] && return 0 || return 1
}

zgen-selfupdate() {
    if [ -d ${ZGEN_SOURCE}/.git ]; then
        pushd ${ZGEN_SOURCE}
        git pull
        popd
    else
        echo "zgen is not running from a git repository, so it is not possible to selfupdate"
    fi
}

zgen-oh-my-zsh() {
    local repo="robbyrussell/oh-my-zsh"
    local file="${1:-oh-my-zsh.sh}"

    zgen-load "${repo}" "${file}"
}

zgen() {
    local cmd="${1}"
    if [[ -z "${cmd}" ]]; then
        echo "usage: zgen [load|oh-my-zsh|save|selfupdate|update]"
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
        selfupdate \
        update
}

ZSH=$(-zgen-get-clone-dir "robbyrussell/oh-my-zsh")
if [[ -f "${ZGEN_INIT}" ]]; then
    source "${ZGEN_INIT}"
fi
compdef _zgen zgen
