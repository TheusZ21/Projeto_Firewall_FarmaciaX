# Projeto Firewall Linux — Farmácia X

## Sobre o projeto

Este projeto foi desenvolvido para a disciplina de Segurança da Informação. A ideia é montar uma simulação de rede utilizando Docker, com um firewall responsável por controlar o acesso entre o computador do funcionário, o servidor Web e o banco de dados.

O cenário escolhido foi o de uma farmácia, chamada Farmácia X. A proposta é demonstrar que o funcionário pode acessar a página Web, mas não deve conseguir se conectar diretamente ao banco de dados.

O TekFarma foi usado apenas como referência ao contexto profissional. A simulação não representa a estrutura real desse sistema.

## Como a rede foi montada

O ambiente foi dividido em três redes para separar os serviços:

| Rede | Sub-rede | Utilização |
|---|---|---|
| Rede do cliente | `10.90.10.0/24` | Acesso do funcionário |
| DMZ Web | `10.90.20.0/24` | Servidor da página Web |
| Rede de dados | `10.90.30.0/24` | Banco de dados PostgreSQL |

O firewall está conectado às três redes e controla o tráfego entre elas por meio de regras do iptables. A política padrão para os pacotes encaminhados é `DROP`, ou seja, as comunicações são bloqueadas quando não existe uma regra permitindo sua passagem.

A configuração também utiliza rotas explícitas nos containers para que a comunicação entre as redes passe pelo firewall.

## O que foi utilizado

- Docker Desktop
- Docker Compose
- Linux e iptables
- Nginx para o servidor Web
- PostgreSQL para o banco de dados

Os arquivos foram separados em pastas para facilitar a organização. Cada serviço possui seu próprio Dockerfile, enquanto o arquivo `docker-compose.yml` reúne as configurações necessárias para iniciar o ambiente.

## Como iniciar

Com o Docker Desktop aberto, entre pelo PowerShell na pasta onde está o arquivo `docker-compose.yml`.

Primeiro, confira se a configuração está correta:

```powershell
docker compose config --quiet
```

Depois, construa as imagens e inicie os serviços:

```powershell
docker compose up -d --build
```

Para verificar se os containers estão funcionando:

```powershell
docker compose ps
```

Os containers utilizados são:

- `farmacia_firewall`
- `farmacia_cliente`
- `farmacia_web`
- `farmacia_banco`

Se estiverem em execução, a página Web poderá ser acessada pelo navegador neste endereço:

http://localhost:8080

A porta 8080 do computador é direcionada para a porta 80 do container Web. A página exibida é a página padrão do Nginx, utilizada para verificar se o servidor Web está funcionando.

## Testes realizados

Os testes abaixo verificam se as regras configuradas estão funcionando como esperado.

### 1. Acesso do cliente à página Web

Para verificar se o cliente consegue acessar o servidor Web, execute:

```powershell
docker exec farmacia_cliente curl -I --connect-timeout 5 http://10.90.20.10
```

O resultado obtido foi `HTTP/1.1 200 OK`, indicando que a página respondeu normalmente.

### 2. Tentativa de acesso direto ao banco de dados

Neste teste, o cliente tenta acessar diretamente a porta do PostgreSQL:

```powershell
docker exec farmacia_cliente nc -z -v -w 3 10.90.30.10 5432
```

A tentativa terminou em timeout. Esse