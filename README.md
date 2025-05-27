# setup\_ssh\_key.sh

Script Bash para geração automática de chaves SSH, cópia para servidor remoto e configuração do arquivo `~/.ssh/config`, permitindo autenticação sem senha em conexões SSH (incluindo VSCode Remote-SSH).

## Sumário

* [Descrição](#descrição)
* [Pré-requisitos](#pré-requisitos)
* [Instalação](#instalação)
* [Uso](#uso)

  * [Opções](#opções)
  * [Exemplos](#exemplos)
* [Estrutura do Script](#estrutura-do-script)
* [Permissões](#permissões)

## Descrição

O `setup_ssh_key.sh` é um utilitário simples em Bash que:

1. Gera um par de chaves SSH (se ainda não existir).
2. Copia a chave pública para o servidor remoto (via `ssh-copy-id` ou método manual).
3. Atualiza o arquivo `~/.ssh/config` criando ou substituindo uma entrada para o host especificado.

Com isso, você poderá se conectar ao servidor remoto sem digitar senha, tanto pelo terminal quanto pelo VSCode Remote-SSH.

## Pré-requisitos

* `bash` (versão 4+ recomendada)
* `ssh` instalado no sistema local
* Acesso SSH ao servidor remoto
* (Opcional) `ssh-copy-id` para cópia automática da chave

## Instalação

1. Clone ou baixe este repositório.
2. Torne o script executável:

   ```bash
   chmod +x setup_ssh_key.sh
   ```

## Uso

Execute o script passando os parâmetros necessários:

```bash
./setup_ssh_key.sh -h HOST -u USER -e EMAIL [-k KEYFILE] [-t TYPE]
```

### Opções

| Opção | Descrição                                       | Padrão              |
| ----- | ----------------------------------------------- | ------------------- |
| `-h`  | Hostname ou IP da máquina remota (obrigatório)  | —                   |
| `-u`  | Usuário na máquina remota (obrigatório)         | —                   |
| `-e`  | Email para comentário da chave (obrigatório)    | —                   |
| `-k`  | Caminho/base do par de chaves                   | `~/.ssh/id_ed25519` |
| `-t`  | Tipo de chave (`ed25519`, `rsa`, `ecdsa`, etc.) | `ed25519`           |

### Exemplos

* Gerar chave padrão e copiar para `192.168.0.10`:

  ```bash
  ./setup_ssh_key.sh -h 192.168.0.10 -u pi -e me@exemplo.com
  ```

* Gerar chave RSA personalizada e copiar para `example.com`:

  ```bash
  ./setup_ssh_key.sh \
    -h example.com \
    -u joao \
    -e joao@exemplo.com \
    -k ~/.ssh/id_rsa_joao \
    -t rsa
  ```

## Estrutura do Script

* **Validação de parâmetros**: Verifica se `-h`, `-u` e `-e` foram informados.
* **Geração de chaves**: Usa `ssh-keygen -t TYPE -C EMAIL -f KEYFILE -N ""` se não existir.
* **Cópia da chave**: Tenta `ssh-copy-id`, caindo para método manual quando ausente.
* **Configuração do SSH**: Remove entradas duplicadas de `~/.ssh/config` e adiciona nova entrada para o host.

## Permissões

* `~/.ssh` deve ter permissão `700`
* `~/.ssh/authorized_keys` deve ter permissão `600`
* Arquivo de configuração `~/.ssh/config` deve ter permissão `600`
* Chave privada (`KEYFILE`) deve ter permissão `600`
