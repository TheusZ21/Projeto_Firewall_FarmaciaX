set -eu

echo "======================================"
echo " Firewall Linux - Farmácia X"
echo " Configurando roteamento e iptables"
echo "======================================"

# Aguarda um instante para o Docker configurar as interfaces.
sleep 2


# Limpa regras anteriores para que a configuração seja repetível.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Políticas padrão: tráfego encaminhado é bloqueado até ser permitido.
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# Permite o retorno de conexões iniciadas por fluxos autorizados.
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Cliente da rede interna pode acessar somente o servidor Web por HTTP.
iptables -A FORWARD -s 10.90.10.0/24 -d 10.90.20.10 -p tcp --dport 80 \
  -m conntrack --ctstate NEW -j ACCEPT

# Regra explícita para registrar/bloquear tentativa de acesso direto do cliente ao PostgreSQL.
iptables -A FORWARD -s 10.90.10.0/24 -d 10.90.30.10 -p tcp --dport 5432 \
  -j LOG --log-prefix "FARMACIA DB BLOQUEADO: " --log-level 4
iptables -A FORWARD -s 10.90.10.0/24 -d 10.90.30.10 -p tcp --dport 5432 -j DROP

# O servidor Web pode consultar o banco PostgreSQL quando necessário.
iptables -A FORWARD -s 10.90.20.10 -d 10.90.30.10 -p tcp --dport 5432 \
  -m conntrack --ctstate NEW -j ACCEPT

echo
echo "Regras ativas:"
iptables -L FORWARD -n -v
echo
echo "Rotas do firewall:"
ip route
echo "Firewall configurado. Mantendo o container ativo."

tail -f /dev/null
