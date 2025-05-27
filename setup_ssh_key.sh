#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Uso: $0 -h HOST -u USER -e EMAIL [-k KEYFILE] [-t TYPE]

  -h HOST      Hostname ou IP da máquina remota
  -u USER      Usuário na máquina remota
  -e EMAIL     Email para usar no comentário da chave
  -k KEYFILE   Caminho/base do par de chaves (padrão: ~/.ssh/id_ed25519)
  -t TYPE      Tipo de chave ssh (padrão: ed25519; outras opções: rsa, ecdsa, etc)

Exemplo:
  $0 -h 192.168.0.10 -u pi -e me@exemplo.com

EOF
  exit 1
}

# Parâmetros padrão
KEYFILE="$HOME/.ssh/id_ed25519"
TYPE="ed25519"

# Parse args
while getopts "h:u:e:k:t:" opt; do
  case $opt in
    h) HOST="$OPTARG" ;;
    u) USER="$OPTARG" ;;
    e) EMAIL="$OPTARG" ;;
    k) KEYFILE="$OPTARG" ;;
    t) TYPE="$OPTARG" ;;
    *) usage ;;
  esac
done

# validação
if [[ -z "${HOST:-}" || -z "${USER:-}" || -z "${EMAIL:-}" ]]; then
  usage
fi

# 1. Gerar par de chaves (se ainda não existir)
if [[ -f "${KEYFILE}" ]]; then
  echo "⚠️  Chave '${KEYFILE}' já existe, pulando keygen."
else
  echo "🔐 Gerando par de chaves (${TYPE}) em ${KEYFILE}..."
  ssh-keygen -t "$TYPE" -C "$EMAIL" -f "$KEYFILE" -N ""
fi

# 2. Copiar chave pública para o servidor
echo "📤 Copiando chave pública para ${USER}@${HOST}..."
if command -v ssh-copy-id &>/dev/null; then
  ssh-copy-id -i "${KEYFILE}.pub" "${USER}@${HOST}"
else
  # método manual
  PUB=$(<"${KEYFILE}.pub")
  ssh "${USER}@${HOST}" bash -c "'
    umask 0077
    mkdir -p ~/.ssh
    echo \"$PUB\" >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
  '"
fi

# 3. Atualizar ~/.ssh/config
CFG="$HOME/.ssh/config"
ENTRY="Host ${HOST}
    HostName ${HOST}
    User ${USER}
    IdentityFile ${KEYFILE}
    IdentitiesOnly yes"

# remove sessão pré-existente (evita duplicar)
grep -q "Host ${HOST}\b" "$CFG" 2>/dev/null && \
  awk -v host="Host ${HOST}" '
    $0 == host {skip=1}
    skip && /^Host / {skip=0}
    !skip {print}
  ' "$CFG" > "${CFG}.tmp" && mv "${CFG}.tmp" "$CFG"

# adiciona nova entry
echo -e "\n$ENTRY" >> "$CFG"
chmod 600 "$CFG"
echo "💾 Atualizado ~/.ssh/config com a entrada para '${HOST}'."

echo "✅ Tudo pronto! Agora tente: ssh ${HOST}"
