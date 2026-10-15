# Trabalho — Firewall Linux, Arquitetura Netfilter e iptables

**Disciplina:** Segurança da Informação  
**Instituição:** IF Goiano — Campus Ceres  
**Aluno:** Victor Matheus Ribeiro Ramos  
**Professor:** Prof. Roitier Campos Gonçalves  
**Data de entrega:** 15/10/2026

# 1. Definição do caso

##  Contexto

Para este trabalho, foi escolhido um cenário baseado na rotina de uma farmácia, chamada aqui de Farmácia X. No dia a dia, esse tipo de estabelecimento utiliza sistemas para realizar vendas, registrar a entrada de mercadorias e consultar produtos.

Para representar essa situação, foi montado um ambiente de teste com uma página Web e um banco de dados PostgreSQL, cada um em seu próprio container Docker. A ideia não é reproduzir o sistema real utilizado pela farmácia, mas sim utilizar esse exemplo para estudar a segurança da rede.

O problema escolhido foi o acesso direto ao banco de dados por um funcionário que deveria utilizar o sistema somente pela interface Web.

# 2. Diagnóstico da situação

Em uma rede, nem todos os computadores precisam ter acesso a todos os serviços. Se não houver regras de controle, um computador utilizado por um funcionário pode conseguir tentar conexões com servidores internos que não fazem parte das suas atividades.

No cenário deste trabalho, o principal risco é o funcionário conseguir se conectar diretamente ao banco de dados, sem passar pela aplicação Web. Para evitar isso, foram separadas as redes e configurado um firewall para controlar as conexões.

Assim, o cliente pode acessar a página Web, mas não deve conseguir acessar diretamente o PostgreSQL. A comunicação com o banco fica permitida para o servidor Web, que representa a aplicação.

# 3. Arquitetura do projeto

O projeto foi montado utilizando Docker Compose, com quatro containers: cliente, firewall, servidor Web e banco de dados.

A rede foi dividida em três partes:

- **Rede Cliente — 10.90.10.0/24:** onde fica o container que representa o computador do funcionário.
- **DMZ Web — 10.90.20.0/24:** onde fica o servidor Nginx, utilizado para disponibilizar a página Web.
- **Rede de Dados — 10.90.30.0/24:** onde fica o banco de dados PostgreSQL.

O container do firewall está conectado às três redes e controla o tráfego entre elas. Também foram configurados o encaminhamento IPv4 e as rotas necessárias para que os pacotes entre as sub-redes passem pelo firewall.

##  Endereços IP utilizados

| Componente | Endereço IP |
|---|---|
| Firewall — Rede Cliente | 10.90.10.1 |
| Cliente | 10.90.10.10 |
| Firewall — DMZ Web | 10.90.20.1 |
| Servidor Web | 10.90.20.10 |
| Firewall — Rede de Dados | 10.90.30.1 |
| PostgreSQL | 10.90.30.10 |

# 4. Configuração do firewall

O firewall foi configurado com iptables, que permite criar regras para controlar o tráfego de rede. No projeto, a cadeia `FORWARD` foi definida com a política padrão `DROP`, ou seja, os pacotes encaminhados entre as redes são bloqueados quando não existe uma regra permitindo sua passagem.

Foram criadas regras para liberar o acesso do cliente ao servidor Web pela porta